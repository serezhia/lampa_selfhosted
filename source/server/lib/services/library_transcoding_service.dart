import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:lampa_server/data_source.dart';
import 'package:lampa_server/database/database.dart' as db;
import 'package:path/path.dart' as p;

class LibraryTranscodingService {
  LibraryTranscodingService._internal();
  static final LibraryTranscodingService instance =
      LibraryTranscodingService._internal();

  final String _rawDir = '/app/library/raw';
  final String _hlsDir = '/app/library/hls';

  final Map<String, Process> _activeTranscodes = {};

  void init() {
    final dir = Directory(_hlsDir);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    // Start processing transcoding queue
    _processTranscodingQueue();
  }

  Future<void> _processTranscodingQueue() async {
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (_activeTranscodes.isNotEmpty) {
        // Max 1 concurrent transcode to avoid CPU overload
        return;
      }

      final items = await (DataSource.instance.db
              .select(DataSource.instance.db.libraryItems)
            ..where((t) => t.status.equals('transcoding'))
            ..limit(1))
          .get();

      if (items.isNotEmpty) {
        unawaited(_startTranscoding(items.first));
      }
    });
  }

  Future<void> _startTranscoding(db.LibraryItem item) async {
    try {
      // Find the raw file
      final rawDir = Directory(_rawDir);
      File? rawFile;
      if (rawDir.existsSync()) {
        for (final file in rawDir.listSync()) {
          if (file is File &&
              p.basenameWithoutExtension(file.path) == item.id) {
            rawFile = file;
            break;
          }
        }
      }

      if (rawFile == null || !rawFile.existsSync()) {
        throw Exception('Raw file not found for item ${item.id}');
      }

      // Create output directory
      final outDir = Directory(p.join(_hlsDir, item.id));
      if (!outDir.existsSync()) {
        outDir.createSync(recursive: true);
      }

      final outPlaylist = p.join(outDir.path, 'playlist.m3u8');

      // Get video duration for progress calculation
      final duration = await _getVideoDuration(rawFile.path);

      // Start FFmpeg
      final process = await Process.start('ffmpeg', [
        '-i', rawFile.path,
        '-c:v', 'libx264',
        '-preset', 'fast',
        '-crf', '23',
        '-c:a', 'aac',
        '-b:a', '128k',
        '-f', 'hls',
        '-hls_time', '10',
        '-hls_list_size', '0', // Keep all segments
        '-hls_segment_filename', p.join(outDir.path, 'segment_%03d.ts'),
        outPlaylist,
      ]);

      _activeTranscodes[item.id] = process;

      var lastUpdate = DateTime.now().millisecondsSinceEpoch;

      process.stderr.transform(utf8.decoder).listen((data) {
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
      _activeTranscodes.remove(item.id);

      if (exitCode == 0) {
        // Success
        await DataSource.instance.db.updateLibraryItem(
          item.copyWith(status: 'ready', progress: 100),
        );

        // Delete raw file
        try {
          rawFile.deleteSync();
        } catch (e) {
          print('[LibraryTranscodingService] Failed to delete raw file: $e');
        }
      } else {
        throw Exception('FFmpeg exited with code $exitCode');
      }
    } catch (e) {
      print(
        '[LibraryTranscodingService] Error transcoding item ${item.id}: $e',
      );
      _activeTranscodes.remove(item.id);
      await DataSource.instance.db.updateLibraryItem(
        item.copyWith(
          status: 'error',
          errorMessage: drift.Value(e.toString()),
        ),
      );
    }
  }

  Future<double> _getVideoDuration(String path) async {
    try {
      final result = await Process.run('ffprobe', [
        '-v',
        'error',
        '-show_entries',
        'format=duration',
        '-of',
        'default=noprint_wrappers=1:nokey=1',
        path,
      ]);

      if (result.exitCode == 0) {
        return double.tryParse(result.stdout.toString().trim()) ?? 0.0;
      }
    } catch (e) {
      print('[LibraryTranscodingService] Error getting duration: $e');
    }
    return 0.0;
  }

  void cancelTranscoding(String id) {
    final process = _activeTranscodes[id];
    if (process != null) {
      process.kill();
      _activeTranscodes.remove(id);
    }
  }
}
