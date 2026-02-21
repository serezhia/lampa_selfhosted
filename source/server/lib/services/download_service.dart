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
  final String _rawDir = '/app/library/raw';

  final Map<String, StreamSubscription<List<int>>> _activeDownloads = {};

  void init() {
    final dir = Directory(_rawDir);
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
        // Max 2 concurrent downloads
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

      // 3. Download the file
      final ext =
          p.extension(fileName).isNotEmpty ? p.extension(fileName) : '.mkv';
      final savePath = p.join(_rawDir, '${item.id}$ext');
      final file = File(savePath);

      final streamUrl =
          '$_torrServerUrl/stream?link=${Uri.encodeComponent(item.magnetUri)}&index=$fileIndex&play';

      final request = http.Request('GET', Uri.parse(streamUrl));
      final response = await http.Client().send(request);

      if (response.statusCode != 200) {
        throw Exception('Failed to start stream: ${response.statusCode}');
      }

      final sink = file.openWrite();
      var downloadedBytes = 0;
      var lastUpdate = DateTime.now().millisecondsSinceEpoch;

      final completer = Completer<void>();

      _activeDownloads[item.id] = response.stream.listen(
        (chunk) {
          sink.add(chunk);
          downloadedBytes += chunk.length;

          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastUpdate > 2000 && fileSize > 0) {
            // Update every 2 seconds
            lastUpdate = now;
            final progress = (downloadedBytes / fileSize) * 100;
            unawaited(
              DataSource.instance.db.updateLibraryItem(
                item.copyWith(progress: progress),
              ),
            );
          }
        },
        onDone: () async {
          await sink.close();
          _activeDownloads.remove(item.id);

          // Update status to transcoding
          await DataSource.instance.db.updateLibraryItem(
            item.copyWith(status: 'transcoding', progress: 100),
          );

          completer.complete();
        },
        onError: (Object e) async {
          await sink.close();
          _activeDownloads.remove(item.id);
          throw Exception('Download stream error: $e');
        },
        cancelOnError: true,
      );

      await completer.future;
    } catch (e) {
      print('[DownloadService] Error downloading item ${item.id}: $e');
      _activeDownloads.remove(item.id);
      await DataSource.instance.db.updateLibraryItem(
        item.copyWith(
          status: 'error',
          errorMessage: drift.Value(e.toString()),
        ),
      );
    }
  }

  void cancelDownload(String id) {
    final sub = _activeDownloads[id];
    if (sub != null) {
      sub.cancel();
      _activeDownloads.remove(id);
    }
  }

  void deleteFiles(String id) {
    try {
      final rawDir = Directory(_rawDir);
      if (rawDir.existsSync()) {
        for (final file in rawDir.listSync()) {
          if (file is File && p.basenameWithoutExtension(file.path) == id) {
            file.deleteSync();
          }
        }
      }

      final hlsDir = Directory('/app/library/hls/$id');
      if (hlsDir.existsSync()) {
        hlsDir.deleteSync(recursive: true);
      }
    } catch (e) {
      print('[DownloadService] Error deleting files for $id: $e');
    }
  }
}
