import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:http/http.dart' as http;
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;
import 'package:path/path.dart' as p;

class DownloadService {
  DownloadService._internal();
  static final DownloadService instance = DownloadService._internal();

  final String _torrServerUrl = 'http://torrserver:8090';
  final String _hlsDir = '/app/library/hls';

  final Map<String, Process> _activeDownloads = {};

  void init() {
    final dir = Directory(_hlsDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Start processing pending items
    _processPendingQueue();
  }

  Future<void> _processPendingQueue() async {
    // Periodically check for pending items
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_activeDownloads.length >= 2) {
        // Max 2 concurrent downloads/transcodes
        return;
      }

      final pendingItems = await (DataSource.instance.db
              .select(DataSource.instance.db.libraryItems)
            ..where((t) => t.status.equals('pending'))
            ..limit(1))
          .get();

      if (pendingItems.isNotEmpty) {
        unawaited(_startDownload(pendingItems.first));
      }
    });
  }

  Future<void> _startDownload(db.LibraryItem item) async {
    try {
      // Update status to downloading
      await DataSource.instance.db.updateLibraryItem(
        item.copyWith(status: 'downloading', progress: 0),
      );

      // 1. Add torrent to TorrServer
      final addResponse = await http.post(
        Uri.parse('$_torrServerUrl/torrents'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'add',
          'link': item.magnetUri,
          'title': item.title,
          'save_to_db': true,
        }),
      );

      if (addResponse.statusCode != 200) {
        throw Exception(
          'Failed to add torrent to TorrServer: ${addResponse.statusCode} ${addResponse.body}',
        );
      }

      final addData = jsonDecode(addResponse.body) as Map<String, dynamic>;
      final hash = addData['hash'] as String?;

      if (hash == null) {
        throw Exception('No hash returned from TorrServer');
      }

      // Wait a bit for TorrServer to fetch metadata
      Map<String, dynamic>? torrentInfo;
      for (var i = 0; i < 10; i++) {
        await Future<void>.delayed(const Duration(seconds: 2));

        final getResponse = await http.post(
          Uri.parse('$_torrServerUrl/torrents'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'action': 'get',
            'hash': hash,
          }),
        );

        if (getResponse.statusCode == 200) {
          final decoded = jsonDecode(getResponse.body);

          // TorrServer might return a single object or a list depending on the version/action
          List<dynamic>? torrents;
          if (decoded is List) {
            torrents = decoded;
          } else if (decoded is Map<String, dynamic>) {
            // Sometimes it returns a single torrent object directly
            torrents = [decoded];
          }

          if (torrents != null && torrents.isNotEmpty) {
            final t = torrents.first as Map<String, dynamic>;
            if (t['file_stats'] != null &&
                (t['file_stats'] as List).isNotEmpty) {
              torrentInfo = t;
              break;
            }
          }
        }
      }

      if (torrentInfo == null) {
        throw Exception('Failed to get torrent metadata from TorrServer');
      }

      // 2. Find the correct file index
      final fileStats = torrentInfo['file_stats'] as List<dynamic>;
      var fileIndex = 1;
      var fileSize = 0;
      var fileName = '';

      if (item.type == 'movie') {
        // Find largest file
        for (final f in fileStats) {
          final stat = f as Map<String, dynamic>;
          final length = stat['length'] as int? ?? 0;
          if (length > fileSize) {
            fileSize = length;
            fileIndex = stat['id'] as int? ?? 1;
            fileName = stat['path'] as String? ?? '';
          }
        }
      } else if (item.type == 'tv') {
        // Try to match season and episode
        final s = item.season?.toString().padLeft(2, '0');
        final e = item.episode?.toString().padLeft(2, '0');

        var found = false;
        for (final f in fileStats) {
          final stat = f as Map<String, dynamic>;
          final path = (stat['path'] as String? ?? '').toLowerCase();

          // Simple regex matching for SxxEyy
          if (s != null && e != null) {
            if (path.contains('s$s') && path.contains('e$e') ||
                path.contains('s${s}e$e') ||
                path.contains('${s}x$e')) {
              fileIndex = stat['id'] as int? ?? 1;
              fileSize = stat['length'] as int? ?? 0;
              fileName = path;
              found = true;
              break;
            }
          }
        }

        if (!found) {
          // Fallback to largest file if not found
          for (final f in fileStats) {
            final stat = f as Map<String, dynamic>;
            final length = stat['length'] as int? ?? 0;
            if (length > fileSize) {
              fileSize = length;
              fileIndex = stat['id'] as int? ?? 1;
              fileName = stat['path'] as String? ?? '';
            }
          }
        }
      }

      // 3. Transcode the file on the fly
      final streamUrl =
          '$_torrServerUrl/stream?link=${Uri.encodeComponent(item.magnetUri)}&index=$fileIndex&play=true';

      print('[DownloadService] Starting on-the-fly transcode from: $streamUrl');

      // Create output directory
      final outDir = Directory(p.join(_hlsDir, item.id));
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }

      final outPlaylist = p.join(outDir.path, 'playlist.m3u8');

      // Get video duration for progress calculation
      final duration = await _getVideoDuration(streamUrl);
      print('[DownloadService] Video duration: $duration seconds');

      // Start FFmpeg
      final process = await Process.start('ffmpeg', [
        '-i', streamUrl,
        '-map', '0:v:0', // Map first video stream
        '-map', '0:a:0', // Map first audio stream
        '-map',
        '0:s:0?', // Map FIRST subtitle stream if it exists (HLS doesn't support multiple without master playlist)
        '-c:v', 'copy', // Copy video stream without re-encoding
        '-c:a', 'aac', // Convert audio to AAC for browser compatibility
        '-b:a', '128k',
        '-c:s', 'webvtt', // Convert subtitles to WebVTT
        '-f', 'hls',
        '-hls_time', '10',
        '-hls_list_size', '0', // Keep all segments
        '-hls_segment_filename', p.join(outDir.path, 'segment_%03d.ts'),
        outPlaylist,
      ]);

      _activeDownloads[item.id] = process;

      var lastUpdate = DateTime.now().millisecondsSinceEpoch;

      process.stderr.transform(utf8.decoder).listen((data) {
        // Print FFmpeg output for debugging
        print('[FFmpeg] $data');

        // Parse time=00:00:00.00 to calculate progress
        final timeMatch =
            RegExp(r'time=(\d{2}):(\d{2}):(\d{2})\.\d{2}').firstMatch(data);
        if (timeMatch != null && duration > 0) {
          final h = int.parse(timeMatch.group(1)!);
          final m = int.parse(timeMatch.group(2)!);
          final s = int.parse(timeMatch.group(3)!);
          final currentSeconds = h * 3600 + m * 60 + s;

          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastUpdate > 2000) {
            lastUpdate = now;
            final progress = (currentSeconds / duration) * 100;
            unawaited(
              DataSource.instance.db.updateLibraryItem(
                item.copyWith(progress: progress.clamp(0, 100)),
              ),
            );
          }
        }
      });

      final exitCode = await process.exitCode;
      _activeDownloads.remove(item.id);
      print('[DownloadService] FFmpeg exited with code $exitCode');

      if (exitCode == 0) {
        // Success
        await DataSource.instance.db.updateLibraryItem(
          item.copyWith(status: 'ready', progress: 100),
        );
      } else {
        throw Exception('FFmpeg exited with code $exitCode');
      }
    } catch (e) {
      print(
          '[DownloadService] Error downloading/transcoding item ${item.id}: $e');
      _activeDownloads.remove(item.id);
      await DataSource.instance.db.updateLibraryItem(
        item.copyWith(
          status: 'error',
          errorMessage: drift.Value(e.toString()),
        ),
      );
    }
  }

  Future<double> _getVideoDuration(String url) async {
    try {
      print('[DownloadService] Getting duration for: $url');
      final result = await Process.run('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
        url,
      ]);

      print('[DownloadService] ffprobe exit code: ${result.exitCode}');
      print('[DownloadService] ffprobe stdout: ${result.stdout}');
      print('[DownloadService] ffprobe stderr: ${result.stderr}');

      if (result.exitCode == 0) {
        return double.tryParse(result.stdout.toString().trim()) ?? 0.0;
      }
    } catch (e) {
      print('[DownloadService] Error getting duration: $e');
    }
    return 0.0;
  }

  void cancelDownload(String id) {
    final process = _activeDownloads[id];
    if (process != null) {
      process.kill();
      _activeDownloads.remove(id);
    }
  }

  void deleteFiles(String id) {
    try {
      final hlsDir = Directory('/app/library/hls/$id');
      if (hlsDir.existsSync()) {
        hlsDir.deleteSync(recursive: true);
      }
    } catch (e) {
      print('[DownloadService] Error deleting files for $id: $e');
    }
  }
}
