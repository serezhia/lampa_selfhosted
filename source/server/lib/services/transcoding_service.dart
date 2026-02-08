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
    this.subtitleIndex,
    this.duration,
  })  : startedAt = DateTime.now(),
        lastHeartbeat = DateTime.now();

  final String streamId;
  final String sourceUrl;
  final int audioIndex;
  final int? subtitleIndex;
  final double? duration;
  final String outputDir;
  final DateTime startedAt;
  DateTime lastHeartbeat;
  Process? ffmpegProcess;
  bool isReady = false;
  String? error;

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
    double? duration,
  }) async {
    final streamId = const Uuid().v4();
    final outputDir = '$_outputBaseDir/$streamId';

    // Create output directory
    await Directory(outputDir).create(recursive: true);

    final session = TranscodingSession(
      streamId: streamId,
      sourceUrl: sourceUrl,
      audioIndex: audioIndex,
      subtitleIndex: subtitleIndex,
      duration: duration,
      outputDir: outputDir,
    );

    _sessions[streamId] = session;

    print('[Transcoding] Starting session $streamId');
    print('[Transcoding] Source: $sourceUrl');
    print('[Transcoding] Audio index: $audioIndex');
    if (subtitleIndex != null) {
      print('[Transcoding] Subtitle index: $subtitleIndex');
    }

    // Build FFmpeg command
    final args = _buildFfmpegArgs(session);

    print('[Transcoding] FFmpeg args: ${args.join(' ')}');

    // Start FFmpeg process
    try {
      session.ffmpegProcess = await Process.start('ffmpeg', args);

      // Log stderr
      session.ffmpegProcess!.stderr.transform(utf8.decoder).listen((line) {
        print('[FFmpeg] $line');
      });

      // Wait for first segment to be ready
      await _waitForPlaylist(session);

      // Wait for subtitles file if subtitles were requested
      if (session.subtitleIndex != null) {
        await _waitForSubtitles(session);
      }

      session.isReady = true;

      print('[Transcoding] Session $streamId is ready');
    } catch (e) {
      session.error = e.toString();
      print('[Transcoding] Error starting FFmpeg: $e');
      await stopSession(streamId);
      rethrow;
    }

    return session;
  }

  /// Build FFmpeg arguments for HLS transcoding
  List<String> _buildFfmpegArgs(TranscodingSession session) {
    final args = <String>[
      '-y',
      '-i',
      session.sourceUrl,
    ]

      // Map video stream (copy, no re-encoding)
      ..addAll(['-map', '0:v:0'])
      // Map selected audio stream using absolute stream index
      ..addAll(['-map', '0:${session.audioIndex}'])
      // Video: copy (no transcoding)
      ..addAll(['-c:v', 'copy'])
      // Audio: transcode to AAC for browser compatibility
      ..addAll(['-c:a', 'aac', '-b:a', '192k', '-ac', '2']);

    // HLS output settings (first output)
    args
      ..addAll(['-f', 'hls'])
      ..addAll(['-hls_time', '4'])
      ..addAll(['-hls_list_size', '0'])
      ..addAll(['-hls_flags', 'delete_segments+append_list'])
      ..addAll(
        ['-hls_segment_filename', '${session.outputDir}/segment_%03d.ts'],
      )
      ..addAll(['-start_number', '0'])
      ..add(session.playlistPath);

    // Extract subtitles as a separate output (must come AFTER HLS output)
    if (session.subtitleIndex != null) {
      args.addAll([
        '-map',
        '0:${session.subtitleIndex}',
        '-c:s',
        'webvtt',
        session.subtitlesPath,
      ]);
    }

    return args;
  }

  /// Wait for the playlist file to be created
  Future<void> _waitForPlaylist(TranscodingSession session) async {
    final playlistFile = File(session.playlistPath);
    var attempts = 0;
    const maxAttempts = 60; // 30 seconds

    while (attempts < maxAttempts) {
      if (playlistFile.existsSync()) {
        final content = playlistFile.readAsStringSync();
        // Wait for at least one segment
        if (content.contains('.ts')) {
          return;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    throw Exception('Timeout waiting for HLS playlist');
  }

  /// Wait for subtitles file to be created and have content
  Future<void> _waitForSubtitles(TranscodingSession session) async {
    final subtitlesFile = File(session.subtitlesPath);
    var attempts = 0;
    const maxAttempts = 20; // 10 seconds

    print('[Transcoding] Waiting for subtitles: ${session.subtitlesPath}');

    while (attempts < maxAttempts) {
      if (subtitlesFile.existsSync()) {
        final content = subtitlesFile.readAsStringSync();
        // VTT must have WEBVTT header and at least one cue
        if (content.contains('WEBVTT') && content.contains('-->')) {
          print('[Transcoding] Subtitles ready, ${content.length} bytes');
          return;
        }
      }
      await Future<void>.delayed(const Duration(milliseconds: 500));
      attempts++;
    }

    // Don't throw - subtitles are optional, just log warning
    print('[Transcoding] Warning: Subtitles not ready after 10s');
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
      }
    }

    for (final streamId in expired) {
      print('[Transcoding] Session $streamId expired, cleaning up');
      stopSession(streamId);
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
