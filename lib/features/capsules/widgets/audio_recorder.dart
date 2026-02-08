import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Hold-to-record audio widget with visual feedback.
class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.maxDuration = 25,
  });

  final void Function(File audioFile, int durationSeconds) onRecordingComplete;
  final int maxDuration;

  @override
  State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
}

class _AudioRecorderWidgetState extends State<AudioRecorderWidget>
    with SingleTickerProviderStateMixin {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (await _recorder.hasPermission()) {
      HapticFeedback.mediumImpact();

      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
      });

      _pulseController.repeat(reverse: true);

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordingSeconds++;
        });

        if (_recordingSeconds >= widget.maxDuration) {
          _stopRecording();
        }
      });
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    final path = await _recorder.stop();

    if (path != null && _recordingSeconds >= 1) {
      HapticFeedback.lightImpact();
      widget.onRecordingComplete(File(path), _recordingSeconds);
    }

    setState(() {
      _isRecording = false;
    });
  }

  String get _formattedTime {
    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎤 Message vocal (optionnel)',
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        GestureDetector(
          onLongPressStart: (_) => _startRecording(),
          onLongPressEnd: (_) => _stopRecording(),
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: _isRecording
                      ? AppColors.error.withValues(
                          alpha: 0.1 + (_pulseController.value * 0.1),
                        )
                      : (isDark
                            ? AppColors.inputBackgroundDark
                            : AppColors.inputBackgroundLight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isRecording
                        ? AppColors.error
                        : (isDark
                              ? AppColors.inputBorderDark
                              : AppColors.inputBorderLight),
                    width: _isRecording ? 2 : 1,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _isRecording ? Icons.mic_rounded : Icons.mic_none_rounded,
                      size: 32,
                      color: _isRecording ? AppColors.error : primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isRecording
                          ? _formattedTime
                          : 'Maintenir pour enregistrer',
                      style: GoogleFonts.outfit(
                        fontSize: _isRecording ? 20 : 14,
                        fontWeight: _isRecording
                            ? FontWeight.bold
                            : FontWeight.w400,
                        color: _isRecording
                            ? AppColors.error
                            : textColor.withValues(alpha: 0.7),
                      ),
                    ),
                    if (_isRecording) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Max ${widget.maxDuration}s',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: textColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.xs),
        Text(
          'Relâchez pour arrêter l\'enregistrement',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: textColor.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

/// Recorded audio preview widget.
class RecordedAudioPreview extends StatelessWidget {
  const RecordedAudioPreview({
    super.key,
    required this.duration,
    required this.onDelete,
  });

  final int duration;
  final VoidCallback onDelete;

  String get _formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Message vocal enregistré',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                Text(
                  'Durée: $_formattedDuration',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: textColor.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
          ),
        ],
      ),
    );
  }
}
