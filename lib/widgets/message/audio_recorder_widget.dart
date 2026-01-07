import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'waveform_widget.dart';

class AudioRecorderWidget extends StatefulWidget {
  final VoidCallback onCancel;
  final Future<void> Function(String path) onSend;
  const AudioRecorderWidget({
    super.key,
    required this.onCancel,
    required this.onSend,
  });
  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  bool _isSending = false;
  String? _filePath;
  Timer? _timer;
  int _recordDuration = 0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  @override
  void initState() {
    super.initState();
    _startRecording();
    _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _position = Duration.zero;
        });
      }
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) {
        setState(() {
          _position = p;
        });
      }
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) {
        setState(() {
          _duration = d;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path =
            '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        await _audioRecorder.start(const RecordConfig(), path: path);
        setState(() {
          _isRecording = true;
          _recordDuration = 0;
          _filePath = path;
        });
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _recordDuration++;
          });
        });
      } else {
        debugPrint("No permission to record");
      }
    } catch (e) {
      debugPrint("Error starting record: $e");
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    final path = await _audioRecorder.stop();
    setState(() {
      _isRecording = false;
      _filePath = path;
    });
  }

  Future<void> _playRecording() async {
    if (_filePath == null) return;
    try {
      // DeviceFileSource is best for local files
      Source source = DeviceFileSource(_filePath!);
      await _audioPlayer.play(source);
      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  Future<void> _pausePlayback() async {
    await _audioPlayer.pause();
    setState(() {
      _isPlaying = false;
    });
  }

  Future<void> _deleteRecording() async {
    // If recording, stop first
    if (_isRecording) {
      await _audioRecorder.stop();
    }
    _timer?.cancel();
    // File cleanup is optional here, OS handles temp eventually.
    // widget.onCancel(); // Caller handles UI dismissal
  }

  Future<void> _handleSend() async {
    if (_filePath == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      await widget.onSend(_filePath!);
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  String _formatDuration(int seconds) {
    final int min = seconds ~/ 60;
    final int sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String _formatDurationFromDuration(Duration duration) {
    final int min = duration.inMinutes;
    final int sec = duration.inSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (_isRecording) _buildRecordingIndicator(),
              const SizedBox(width: 12),

              Text(
                _isRecording ? "Recording..." : "Voice Message",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const Spacer(),

              Text(
                _formatDuration(_recordDuration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar (Messenger Style Waveform)
          if (!_isRecording && _filePath != null)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: WaveformSlider(
                    progress: _duration.inMilliseconds > 0
                        ? (_position.inMilliseconds / _duration.inMilliseconds)
                              .clamp(0.0, 1.0)
                        : 0.0,
                    height: 50,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white12,
                    onSeek: (progress) {
                      final seekTo = _duration.inMilliseconds * progress;
                      _audioPlayer.seek(Duration(milliseconds: seekTo.toInt()));
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDurationFromDuration(_position),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _formatDurationFromDuration(_duration),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Delete / Cancel
              IconButton(
                onPressed: _isSending
                    ? null
                    : () {
                        _deleteRecording();
                        widget.onCancel();
                      },
                icon: Icon(
                  Icons.delete,
                  color: _isSending
                      ? Colors.grey.withOpacity(0.3)
                      : Colors.grey,
                  size: 28,
                ),
              ),
              // Action (Stop / Play / Pause)
              if (_isRecording)
                IconButton(
                  onPressed: _stopRecording,
                  icon: const Icon(
                    Icons.stop_circle_outlined,
                    color: Colors.white,
                    size: 58,
                  ),
                )
              else
                IconButton(
                  onPressed: _isPlaying ? _pausePlayback : _playRecording,
                  icon: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 58,
                  ),
                ),
              // Send
              if (_isSending)
                const SizedBox(
                  width: 28,
                  height: 28,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                )
              else
                IconButton(
                  onPressed: (_filePath != null && !_isRecording && !_isSending)
                      ? _handleSend
                      : null,
                  icon: Icon(
                    Icons.send_rounded,
                    color: (_filePath != null && !_isRecording && !_isSending)
                        ? Colors.white
                        : Colors.grey.withOpacity(0.3),
                    size: 28,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}
