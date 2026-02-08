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
    this.segmentDuration = 4.0,
  })  : startedAt = DateTime.now(),
        lastHeartbeat = DateTime.now(),
        _generatedSegments = <int>{};

  final String streamId;
  final String sourceUrl;
  final int audioIndex;
  final int? subtitleIndex;
  final double? duration;
  final double segmentDuration;
  final String outputDir;
  final DateTime startedAt;
  DateTime lastHeartbeat;
  Process? ffmpegProcess;
  Process? subtitleProcess; // Separate process for subtitle extraction
  bool isReady = false;
  String? error;

  /// Current segment FFmpeg started transcoding from
  int currentStartSegment = 0;

  /// Timestamp when current FFmpeg process started
  DateTime? ffmpegStartedAt;

  /// Set of segment numbers that have been generated
  final Set<int> _generatedSegments;

  String get playlistPath => '$outputDir/playlist.m3u8';
  String get subtitlesPath => '$outputDir/subtitles.vtt';

  /// Total number of segments based on duration
  int get totalSegments =>
      duration != null ? (duration! / segmentDuration).ceil() : 0;

  void updateHeartbeat() {
    lastHeartbeat = DateTime.now();
  }

  bool get isExpired {
    // Session expires after 60 seconds without heartbeat
    return DateTime.now().difference(lastHeartbeat).inSeconds > 60;
  }

  /// Check if a segment file exists
  bool isSegmentGenerated(int segmentNumber) {
    if (_generatedSegments.contains(segmentNumber)) return true;

    final segmentFile = File(
      '$outputDir/segment_${segmentNumber.toString().padLeft(3, '0')}.ts',
    );
    if (segmentFile.existsSync()) {
      _generatedSegments.add(segmentNumber);
      return true;
    }
    return false;
  }

  /// Get segment number for a given time position
  int getSegmentForTime(double time) {
    return (time / segmentDuration).floor();
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
    print('[Transcoding] Duration: $duration seconds');
    print('[Transcoding] Audio index: $audioIndex');
    if (subtitleIndex != null) {
      print('[Transcoding] Subtitle index: $subtitleIndex');
    }

    // Generate VOD playlist upfront if duration is known
    if (duration != null && duration > 0) {
      final vodPlaylist = _generateVodPlaylist(session);
      await File(session.playlistPath).writeAsString(vodPlaylist);
      print(
        '[Transcoding] VOD playlist written with ${session.totalSegments} segments',
      );
    }

    // Build FFmpeg command starting from segment 0
    final args = _buildFfmpegArgs(session, startSegment: 0);
    session.currentStartSegment = 0;
    session.ffmpegStartedAt = DateTime.now();

    print('[Transcoding] FFmpeg args: ${args.join(' ')}');

    // Start FFmpeg process
    try {
      session.ffmpegProcess = await Process.start('ffmpeg', args);

      // Log stderr
      session.ffmpegProcess!.stderr.transform(utf8.decoder).listen((line) {
        print('[FFmpeg] $line');
      });

      // Start separate subtitle extraction process if requested
      if (session.subtitleIndex != null) {
        final subArgs = _buildSubtitleArgs(session);
        print('[Transcoding] Subtitle FFmpeg args: ${subArgs.join(' ')}');

        session.subtitleProcess = await Process.start('ffmpeg', subArgs);

        // Log subtitle process stderr
        session.subtitleProcess!.stderr.transform(utf8.decoder).listen((line) {
          print('[FFmpeg-Subs] $line');
        });

        print('[Transcoding] Subtitle extraction started (runs in background)');
      }

      // Don't wait for first segment here - let the player request it
      // This makes start instant, segment will be waited for on first request
      session.isReady = true;

      print('[Transcoding] Session $streamId started (segments generating)');
    } catch (e) {
      session.error = e.toString();
      print('[Transcoding] Error starting FFmpeg: $e');
      await stopSession(streamId);
      rethrow;
    }

    return session;
  }

  /// Build FFmpeg arguments for HLS transcoding with optional seek
  List<String> _buildFfmpegArgs(
    TranscodingSession session, {
    int startSegment = 0,
  }) {
    final seekTime = startSegment * session.segmentDuration;

    final args = <String>['-y'];

    // Input seeking - MUST be before -i for fast seek to keyframe
    if (seekTime > 0) {
      args.addAll(['-ss', seekTime.toStringAsFixed(3)]);
    }

    args
      ..addAll(['-i', session.sourceUrl])
      // Map video stream (copy, no re-encoding)
      ..addAll(['-map', '0:v:0'])
      // Map selected audio stream using absolute stream index
      ..addAll(['-map', '0:${session.audioIndex}'])
      // Video: copy (no transcoding)
      ..addAll(['-c:v', 'copy'])
      // Audio: transcode to AAC for browser compatibility
      ..addAll(['-c:a', 'aac', '-b:a', '192k', '-ac', '2']);

    // HLS output settings
    args
      ..addAll(['-f', 'hls'])
      ..addAll(['-hls_time', session.segmentDuration.toStringAsFixed(0)])
      ..addAll(['-hls_list_size', '0'])
      // Remove delete_segments - keep all segments for seeking back
      ..addAll(['-hls_flags', 'append_list+independent_segments'])
      ..addAll(
        ['-hls_segment_filename', '${session.outputDir}/segment_%03d.ts'],
      )
      ..addAll(['-start_number', startSegment.toString()])
      ..add(session.playlistPath);

    // Note: Subtitles are extracted in a separate process
    // to avoid buffering issues with streaming sources

    return args;
  }

  /// Generate a complete VOD playlist with all segment references
  String _generateVodPlaylist(TranscodingSession session) {
    if (session.duration == null || session.duration! <= 0) {
      throw Exception('Duration required for VOD playlist');
    }

    final duration = session.duration!;
    final segmentDuration = session.segmentDuration;
    final segmentCount = (duration / segmentDuration).ceil();

    final buffer = StringBuffer()
      ..writeln('#EXTM3U')
      ..writeln('#EXT-X-VERSION:3')
      ..writeln('#EXT-X-TARGETDURATION:${segmentDuration.ceil()}')
      ..writeln('#EXT-X-MEDIA-SEQUENCE:0')
      ..writeln('#EXT-X-PLAYLIST-TYPE:VOD');

    for (var i = 0; i < segmentCount; i++) {
      final isLast = i == segmentCount - 1;
      final segDur =
          isLast ? duration - (i * segmentDuration) : segmentDuration;

      buffer
        ..writeln('#EXTINF:${segDur.toStringAsFixed(3)},')
        ..writeln('segment_${i.toString().padLeft(3, '0')}.ts');
    }

    buffer.writeln('#EXT-X-ENDLIST');

    print('[Transcoding] Generated VOD playlist with $segmentCount segments');
    return buffer.toString();
  }

  /// Build FFmpeg arguments for extracting subtitles
  List<String> _buildSubtitleArgs(TranscodingSession session) {
    return [
      '-y',
      '-i',
      session.sourceUrl,
      '-map',
      '0:${session.subtitleIndex}',
      '-c:s',
      'webvtt',
      '-flush_packets',
      '1',
      session.subtitlesPath,
    ];
  }

  /// Wait for a specific segment to be generated
  Future<bool> _waitForSegment(
    TranscodingSession session,
    int segmentNumber, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    const checkInterval = Duration(milliseconds: 300);
    final deadline = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(deadline)) {
      if (session.isSegmentGenerated(segmentNumber)) {
        print('[Transcoding] Segment $segmentNumber is ready');
        return true;
      }
      await Future<void>.delayed(checkInterval);
    }

    print('[Transcoding] Timeout waiting for segment $segmentNumber');
    return false;
  }

  /// Seek to a specific segment, restarting FFmpeg if needed
  Future<bool> seekToSegment(String streamId, int segmentNumber) async {
    final session = _sessions[streamId];
    if (session == null) return false;

    print('[Transcoding] Seek request to segment $segmentNumber');

    // Check if segment already exists
    if (session.isSegmentGenerated(segmentNumber)) {
      print('[Transcoding] Segment $segmentNumber already exists');
      return true;
    }

    // Check if FFmpeg is generating nearby segments
    // Estimate current segment based on time elapsed since FFmpeg started
    final currentlyGenerating = session.currentStartSegment;
    var estimatedCurrent = currentlyGenerating;
    if (session.ffmpegStartedAt != null) {
      final elapsed = DateTime.now().difference(session.ffmpegStartedAt!);
      estimatedCurrent = currentlyGenerating +
          (elapsed.inMilliseconds / (session.segmentDuration * 1000)).floor();
    }

    // If segment is just ahead of current generation (within 5 segments), wait
    if (segmentNumber >= currentlyGenerating &&
        segmentNumber <= estimatedCurrent + 5) {
      print(
        '[Transcoding] Segment $segmentNumber is being generated '
        '(estimated current: $estimatedCurrent), waiting...',
      );
      return _waitForSegment(session, segmentNumber);
    }

    // Need to restart FFmpeg from new position
    print('[Transcoding] Restarting FFmpeg from segment $segmentNumber');

    // Kill current FFmpeg
    if (session.ffmpegProcess != null) {
      session.ffmpegProcess!.kill();
      await session.ffmpegProcess!.exitCode.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          session.ffmpegProcess!.kill(ProcessSignal.sigkill);
          return -1;
        },
      );
    }

    // Start new FFmpeg from segment position
    session.currentStartSegment = segmentNumber;
    session.ffmpegStartedAt = DateTime.now();

    final args = _buildFfmpegArgs(session, startSegment: segmentNumber);
    print('[Transcoding] New FFmpeg args: ${args.join(' ')}');

    try {
      session.ffmpegProcess = await Process.start('ffmpeg', args);

      session.ffmpegProcess!.stderr.transform(utf8.decoder).listen((line) {
        print('[FFmpeg] $line');
      });

      // Wait for the requested segment
      return _waitForSegment(session, segmentNumber);
    } catch (e) {
      print('[Transcoding] Error restarting FFmpeg: $e');
      session.error = e.toString();
      return false;
    }
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
