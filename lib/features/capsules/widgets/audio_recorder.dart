import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Hold-to-record audio widget with live pulsating waveform animation.
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
      duration: const Duration(milliseconds: 650),
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return GestureDetector(
      onLongPressStart: (_) => _startRecording(),
      onLongPressEnd: (_) => _stopRecording(),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, _) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: _isRecording ? 18 : 16,
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              gradient: _isRecording
                  ? LinearGradient(
                      colors: [
                        AppColors.error.withValues(
                          alpha: isDark ? 0.22 : 0.12,
                        ),
                        AppColors.coral.withValues(
                          alpha: isDark ? 0.15 : 0.08,
                        ),
                      ],
                    )
                  : LinearGradient(
                      colors: isDark
                          ? [const Color(0xFF221F28), const Color(0xFF1E1C24)]
                          : [const Color(0xFFFBF8FD), const Color(0xFFF5EEF9)],
                    ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _isRecording
                    ? AppColors.error.withValues(
                        alpha: 0.6 + (_pulseController.value * 0.35),
                      )
                    : (isDark
                        ? AppColors.dividerDark
                        : AppColors.primaryLight.withValues(alpha: 0.18)),
                width: _isRecording ? 1.8 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isRecording
                      ? AppColors.error.withValues(
                          alpha: 0.2 + (_pulseController.value * 0.15),
                        )
                      : Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                  blurRadius: _isRecording ? 12 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _isRecording
                ? _buildActiveRecordingUI(textColor)
                : _buildIdleUI(primary, textColor, secondaryText, l10n),
          );
        },
      ),
    );
  }

  Widget _buildIdleUI(
    Color primary,
    Color textColor,
    Color secondaryText,
    dynamic l10n,
  ) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryLight.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.mic_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.capsuleHoldToRecord,
                style: AppTypography.fromContext(
                  context,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.capsuleMaxDuration(widget.maxDuration),
                style: AppTypography.fromContext(
                  context,
                  fontSize: 11.5,
                  color: secondaryText,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.maxDuration}s max',
            style: AppTypography.fromContext(
              context,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveRecordingUI(Color textColor) {
    return Column(
      children: [
        // Top row: Pulsing red dot + Recording timer
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(
                      alpha: 0.4 + (_pulseController.value * 0.4),
                    ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_formattedTime / 00:${widget.maxDuration}',
              style: AppTypography.fromContext(
                context,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.error,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Live Animated Waveform Bars
        SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(15, (index) {
              // Sine wave with phase shift for organic fluid motion
              final phase = index * 0.48;
              final factor = (math.sin(
                (_pulseController.value * 2 * math.pi) + phase,
              ).abs());
              final barHeight = 6.0 + (factor * 26.0);

              return Container(
                width: 3.5,
                height: barHeight,
                margin: const EdgeInsets.symmetric(horizontal: 2.5),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.error,
                      AppColors.coral.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
        ),

        const SizedBox(height: 10),

        // Release to stop label
        Text(
          context.l10n.capsuleReleaseToStop,
          style: AppTypography.fromContext(
            context,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.error.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

/// Recorded audio preview widget with playback waveform aesthetics.
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
    final l10n = context.l10n;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.onSurfaceLight;
    final secondaryText = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.mic_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.capsuleVoiceRecorded,
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.capsuleDuration(_formattedDuration),
                  style: AppTypography.fromContext(
                    context,
                    fontSize: 11.5,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 21),
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }
}
