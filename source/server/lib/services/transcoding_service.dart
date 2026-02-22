import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

/// Represents an active transcoding session
class TranscodingSession {
  TranscodingSession({
    required this.streamId,
    required this.sourceUrl,
    required this.audioIndex,
    required this.outputDir,
    required this.totalDuration,
    this.subtitleIndex,
  })  : startedAt = DateTime.now(),
        lastHeartbeat = DateTime.now();

  final String streamId;
  final String sourceUrl;
  final int audioIndex;
  final int? subtitleIndex;
  final double totalDuration;
  final String outputDir;
  final DateTime startedAt;
  DateTime lastHeartbeat;
  Process? ffmpegProcess;
  Process? subtitleProcess; // Separate process for subtitle extraction
  bool isReady = false;
  bool isRestarting = false;
  String? error;

  int currentFfmpegStartSegment = -1;
  int lastRequestedSegment = 0;

  static const double segmentDuration = 4;

  String get playlistPath => '$outputDir/playlist.m3u8';
  String get subtitlesPath => '$outputDir/subtitles.vtt';

  void updateHeartbeat() {
    lastHeartbeat = DateTime.now();
  }

  bool get isExpired {
    // Session expires after 60 seconds without heartbeat
    return DateTime.now().difference(lastHeartbeat).inSeconds > 60;
  }
}

/// FFprobe result for media analysis
class MediaInfo {
  MediaInfo({required this.streams, this.format});

  final List<StreamInfo> streams;
  final FormatInfo? format;

  Map<String, dynamic> toJson() => {
        'streams': streams.map((s) => s.toJson()).toList(),
        if (format != null) 'format': format!.toJson(),
      };
}

class StreamInfo {
  StreamInfo({
    required this.index,
    required this.codecType,
    this.codecName,
    this.channels,
    this.channelLayout,
    this.bitRate,
    this.tags = const {},
  });

  final int index;
  final String codecType;
  final String? codecName;
  final int? channels;
  final String? channelLayout;
  final int? bitRate;
  final Map<String, String> tags;

  Map<String, dynamic> toJson() => {
        'index': index,
        'codec_type': codecType,
        if (codecName != null) 'codec_name': codecName,
        if (channels != null) 'channels': channels,
        if (channelLayout != null) 'channel_layout': channelLayout,
        if (bitRate != null) 'bit_rate': bitRate,
        'tags': tags,
      };
}

class FormatInfo {
  FormatInfo({this.filename, this.formatName, this.duration, this.bitRate});

  final String? filename;
  final String? formatName;
  final double? duration;
  final int? bitRate;

  Map<String, dynamic> toJson() => {
        if (filename != null) 'filename': filename,
        if (formatName != null) 'format_name': formatName,
        if (duration != null) 'duration': duration,
        if (bitRate != null) 'bit_rate': bitRate,
      };
}

/// Service for transcoding media streams on-the-fly using FFmpeg
class TranscodingService {
  TranscodingService({
    required String outputDir,
    required String baseUrl,
  })  : _outputBaseDir = outputDir,
        _baseUrl = baseUrl {
    // Create output directory
    Directory(_outputBaseDir).createSync(recursive: true);

    // Start cleanup timer
    _cleanupTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _cleanupExpiredSessions(),
    );
  }

  final String _outputBaseDir;
  final String _baseUrl;
  final Map<String, TranscodingSession> _sessions = {};
  Timer? _cleanupTimer;

  /// Analyze media file using ffprobe
  Future<MediaInfo> ffprobe(String mediaUrl) async {
    print('[Transcoding] FFprobe: $mediaUrl');

    final result = await Process.run(
      'ffprobe',
      [
        '-v',
        'quiet',
        '-print_format',
        'json',
        '-show_streams',
        '-show_format',
        '-fflags',
        '+genpts+discardcorrupt',
        mediaUrl,
      ],
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    );

    if (result.exitCode != 0) {
      throw Exception('FFprobe failed: ${result.stderr}');
    }

    final json = jsonDecode(result.stdout as String) as Map<String, dynamic>;

    final streams = <StreamInfo>[];
    final rawStreams = json['streams'] as List<dynamic>? ?? [];

    for (final s in rawStreams) {
      final stream = s as Map<String, dynamic>;
      final tags = <String, String>{};

      if (stream['tags'] != null) {
        final rawTags = stream['tags'] as Map<String, dynamic>;
        for (final entry in rawTags.entries) {
          tags[entry.key] = entry.value.toString();
        }
      }

      streams.add(
        StreamInfo(
          index: stream['index'] as int,
          codecType: stream['codec_type'] as String? ?? 'unknown',
          codecName: stream['codec_name'] as String?,
          channels: stream['channels'] as int?,
          channelLayout: stream['channel_layout'] as String?,
          bitRate: int.tryParse(stream['bit_rate']?.toString() ?? ''),
          tags: tags,
        ),
      );
    }

    FormatInfo? format;
    if (json['format'] != null) {
      final f = json['format'] as Map<String, dynamic>;
      format = FormatInfo(
        filename: f['filename'] as String?,
        formatName: f['format_name'] as String?,
        duration: double.tryParse(f['duration']?.toString() ?? ''),
        bitRate: int.tryParse(f['bit_rate']?.toString() ?? ''),
      );
    }

    print('[Transcoding] FFprobe found ${streams.length} streams');
    return MediaInfo(streams: streams, format: format);
  }

  /// Start a new transcoding session
  Future<TranscodingSession> startSession({
    required String sourceUrl,
    required int audioIndex,
    int? subtitleIndex,
  }) async {
    final streamId = const Uuid().v4();
    final outputDir = '$_outputBaseDir/$streamId';

    // Create output directory
    await Directory(outputDir).create(recursive: true);

    // Get media info to find duration
    final mediaInfo = await ffprobe(sourceUrl);
    final duration = mediaInfo.format?.duration ?? 0.0;

    if (duration <= 0) {
      throw Exception('Could not determine video duration');
    }

    final session = TranscodingSession(
      streamId: streamId,
      sourceUrl: sourceUrl,
      audioIndex: audioIndex,
      subtitleIndex: subtitleIndex,
      totalDuration: duration,
      outputDir: outputDir,
    );

    _sessions[streamId] = session;

    print('[Transcoding] Starting VOD session $streamId');
    print('[Transcoding] Source: $sourceUrl');
    print('[Transcoding] Duration: $duration seconds');

    // Generate static playlist
    _generateStaticPlaylist(session);

    // Start separate subtitle extraction process if requested
    if (session.subtitleIndex != null) {
      final subArgs = _buildSubtitleArgs(session);
      print('[Transcoding] Subtitle FFmpeg args: ${subArgs.join(' ')}');

      session.subtitleProcess = await Process.start('ffmpeg', subArgs);

      // Log subtitle process stderr
      session.subtitleProcess!.stderr.transform(utf8.decoder).listen((line) {
        // print('[FFmpeg-Subs] $line');
      });

      print('[Transcoding] Subtitle extraction started (runs in background)');
    }

    session.isReady = true;
    print('[Transcoding] Session $streamId is ready');

    return session;
  }

  void _generateStaticPlaylist(TranscodingSession session) {
    final file = File(session.playlistPath);
    final buffer = StringBuffer();

    buffer.writeln('#EXTM3U');
    buffer.writeln('#EXT-X-VERSION:3');
    buffer.writeln(
      '#EXT-X-TARGETDURATION:${TranscodingSession.segmentDuration.ceil()}',
    );
    buffer.writeln('#EXT-X-MEDIA-SEQUENCE:0');
    buffer.writeln('#EXT-X-PLAYLIST-TYPE:VOD');

    final totalSegments =
        (session.totalDuration / TranscodingSession.segmentDuration).ceil();

    for (var i = 0; i < totalSegments; i++) {
      final isLast = i == totalSegments - 1;
      final duration = isLast
          ? session.totalDuration - (i * TranscodingSession.segmentDuration)
          : TranscodingSession.segmentDuration;

      buffer.writeln('#EXTINF:${duration.toStringAsFixed(6)},');
      buffer.writeln('segment_${i.toString().padLeft(5, '0')}.ts');
    }

    buffer.writeln('#EXT-X-ENDLIST');
    file.writeAsStringSync(buffer.toString());
  }

  Future<void> ensureSegmentAvailable(
    String streamId,
    int segmentNumber,
  ) async {
    final session = _sessions[streamId];
    if (session == null) return;

    session.lastRequestedSegment = segmentNumber;

    final segmentFile = File(
      '${session.outputDir}/segment_${segmentNumber.toString().padLeft(5, '0')}.ts',
    );

    if (segmentFile.existsSync()) {
      return;
    }

    // Wait if a restart is already in progress
    while (session.isRestarting) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (segmentFile.existsSync()) return;
    }

    var needsRestart = false;

    if (session.ffmpegProcess == null) {
      needsRestart = true;
    } else {
      var highestSegment = _getHighestSegmentOnDisk(session);
      if (highestSegment == -1) {
        highestSegment = session.currentFfmpegStartSegment;
      }

      if (segmentNumber < session.currentFfmpegStartSegment) {
        needsRestart = true;
      } else if (segmentNumber > highestSegment + 10) {
        needsRestart = true;
      }
    }

    if (needsRestart) {
      session.isRestarting = true;
      try {
        await _restartFfmpeg(session, segmentNumber);
      } finally {
        session.isRestarting = false;
      }
    }

    await _waitForSegment(segmentFile);
  }

  int _getHighestSegmentOnDisk(TranscodingSession session) {
    final dir = Directory(session.outputDir);
    var highest = -1;
    if (!dir.existsSync()) return highest;

    try {
      for (final entity in dir.listSync()) {
        if (entity is File && entity.path.endsWith('.ts')) {
          final match = RegExp(r'segment_(\d+)\.ts').firstMatch(entity.path);
          if (match != null) {
            final num = int.parse(match.group(1)!);
            if (num > highest) highest = num;
          }
        }
      }
    } catch (e) {
      print('[Transcoding] Error listing segments: $e');
    }
    return highest;
  }

  Future<void> _restartFfmpeg(
    TranscodingSession session,
    int startSegment,
  ) async {
    print(
      '[Transcoding] Restarting FFmpeg for session ${session.streamId} at segment $startSegment',
    );

    if (session.ffmpegProcess != null) {
      session.ffmpegProcess!.kill();
      try {
        await session.ffmpegProcess!.exitCode
            .timeout(const Duration(seconds: 2));
      } catch (_) {
        session.ffmpegProcess!.kill(ProcessSignal.sigkill);
      }
      session.ffmpegProcess = null;
    }

    session.currentFfmpegStartSegment = startSegment;

    final startTime = startSegment * TranscodingSession.segmentDuration;

    final args = <String>['-y'];

    args.addAll(['-ss', startTime.toStringAsFixed(3)]);
    args.addAll(['-fflags', '+genpts+discardcorrupt']);
    args.addAll(['-err_detect', 'ignore_err']);
    args.addAll(['-i', session.sourceUrl]);

    args.addAll(['-copyts']); // Keep original timestamps for HLS

    args.addAll(['-map', '0:v:0']);
    args.addAll(['-map', '0:${session.audioIndex}']);
    args.addAll(['-c:v', 'copy']);
    args.addAll(['-c:a', 'aac', '-b:a', '192k', '-ac', '2']);

    args.addAll(['-f', 'hls']);
    args.addAll(
      ['-hls_time', TranscodingSession.segmentDuration.toInt().toString()],
    );
    args.addAll(['-hls_list_size', '0']);
    args.addAll(['-hls_flags', 'independent_segments+temp_file']);

    args.addAll(
      ['-hls_segment_filename', '${session.outputDir}/segment_%05d.ts'],
    );
    args.addAll(['-start_number', startSegment.toString()]);

    args.add('${session.outputDir}/dummy_playlist.m3u8');

    print('[Transcoding] FFmpeg args: ${args.join(' ')}');

    session.ffmpegProcess = await Process.start('ffmpeg', args);
    final currentProcess = session.ffmpegProcess;

    session.ffmpegProcess!.stderr.transform(utf8.decoder).listen((line) {
      // print('[FFmpeg] $line');
    });

    unawaited(
      session.ffmpegProcess!.exitCode.then((code) {
        print('[Transcoding] FFmpeg exited with code $code');
        if (session.ffmpegProcess == currentProcess) {
          session.ffmpegProcess = null;
        }
      }),
    );
  }

  Future<void> _waitForSegment(File segmentFile) async {
    var attempts = 0;
    const maxAttempts = 60; // 30 seconds

    while (attempts < maxAttempts) {
      if (segmentFile.existsSync()) {
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      attempts++;
    }
    throw Exception('Timeout waiting for segment');
  }

  /// Build FFmpeg arguments for extracting subtitles
  List<String> _buildSubtitleArgs(TranscodingSession session) {
    final args = <String>[
      '-y',
    ];

    args.addAll([
      '-fflags',
      '+genpts+discardcorrupt',
      '-err_detect',
      'ignore_err',
      '-i',
      session.sourceUrl,
      '-map',
      '0:${session.subtitleIndex}',
      '-c:s',
      'webvtt',
      '-flush_packets',
      '1',
      session.subtitlesPath,
    ]);

    return args;
  }

  /// Get session by ID
  TranscodingSession? getSession(String streamId) {
    return _sessions[streamId];
  }

  /// Update session heartbeat
  void heartbeat(String streamId) {
    final session = _sessions[streamId];
    if (session != null) {
      session.updateHeartbeat();
      print('[Transcoding] Heartbeat for $streamId');
    }
  }

  /// Stop a transcoding session
  Future<void> stopSession(String streamId) async {
    final session = _sessions.remove(streamId);
    if (session == null) return;

    print('[Transcoding] Stopping session $streamId');

    // Kill FFmpeg process
    if (session.ffmpegProcess != null) {
      session.ffmpegProcess!.kill();
      await session.ffmpegProcess!.exitCode.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          session.ffmpegProcess!.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    }

    // Kill subtitle extraction process
    if (session.subtitleProcess != null) {
      session.subtitleProcess!.kill();
      await session.subtitleProcess!.exitCode.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          session.subtitleProcess!.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    }

    // Clean up output directory
    try {
      final dir = Directory(session.outputDir);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (e) {
      print('[Transcoding] Error cleaning up: $e');
    }
  }

  /// Get playlist URL for a session
  String getPlaylistUrl(String streamId) {
    return '$_baseUrl/api/transcoding/$streamId/playlist.m3u8';
  }

  /// Get subtitles URL for a session
  String getSubtitlesUrl(String streamId) {
    return '$_baseUrl/api/transcoding/$streamId/subtitles.vtt';
  }

  /// Cleanup expired sessions
  void _cleanupExpiredSessions() {
    final expired = <String>[];

    for (final entry in _sessions.entries) {
      if (entry.value.isExpired) {
        expired.add(entry.key);
      } else {
        _cleanupOldSegments(entry.value);
      }
    }

    for (final streamId in expired) {
      print('[Transcoding] Session $streamId expired, cleaning up');
      stopSession(streamId);
    }
  }

  void _cleanupOldSegments(TranscodingSession session) {
    final dir = Directory(session.outputDir);
    if (!dir.existsSync()) return;

    final current = session.lastRequestedSegment;
    // Keep segments within a window of [-20, +50] from the current segment
    final minKeep = current - 20;
    final maxKeep = current + 50;

    try {
      for (final entity in dir.listSync()) {
        if (entity is File && entity.path.endsWith('.ts')) {
          final match = RegExp(r'segment_(\d+)\.ts').firstMatch(entity.path);
          if (match != null) {
            final num = int.parse(match.group(1)!);
            if (num < minKeep || num > maxKeep) {
              try {
                entity.deleteSync();
              } catch (e) {
                // Ignore deletion errors
              }
            }
          }
        }
      }
    } catch (e) {
      print('[Transcoding] Error cleaning up segments: $e');
    }
  }

  /// Dispose the service
  void dispose() {
    _cleanupTimer?.cancel();

    // Stop all sessions
    for (final streamId in _sessions.keys.toList()) {
      stopSession(streamId);
    }
  }
}
