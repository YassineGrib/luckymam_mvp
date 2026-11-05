import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:record/record.dart';

import '../../../core/extensions/l10n_extension.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

/// Hold-to-record audio widget with live pulsating waveform animation.
class AudioRecorderWidget extends StatefulWidget {
  const AudioRecorderWidget({
    super.key,
    required this.onRecordingComplete,
    this.onError,
    this.maxDuration = 25,
  });

  final void Function(File audioFile, int durationSeconds) onRecordingComplete;
  final void Function(String errorMessage)? onError;
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
    try {
      final hasPermission = await _recorder.hasPermission();
      if (!hasPermission) {
        if (mounted) {
          widget.onError?.call(context.l10n.capsuleAudioMicPermissionError);
        }
        return;
      }

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
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    }
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _pulseController.stop();
    _pulseController.reset();

    try {
      final path = await _recorder.stop();

      if (path != null) {
        final file = File(path);
        final exists = await file.exists();
        final length = exists ? await file.length() : 0;
        if (exists && length > 0 && _recordingSeconds >= 1) {
          HapticFeedback.lightImpact();
          widget.onRecordingComplete(file, _recordingSeconds);
        } else {
          if (exists) {
            try {
              await file.delete();
            } catch (_) {}
          }
          if (mounted) {
            widget.onError?.call(context.l10n.capsuleAudioTooShortError);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        widget.onError?.call(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }
    }
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

/// Recorded audio preview and modification player (LM-CAP-004).
/// Allows listening, pause, resume, scrubbing, re-recording, deletion,
/// and explicit confirmation before associating with the capsule.
class RecordedAudioPreview extends StatefulWidget {
  const RecordedAudioPreview({
    super.key,
    this.audioFile,
    this.audioUrl,
    required this.duration,
    required this.onDelete,
    this.onReRecord,
    this.onValidate,
    this.isValidated = false,
  });

  final File? audioFile;
  final String? audioUrl;
  final int duration;
  final VoidCallback onDelete;
  final VoidCallback? onReRecord;
  final VoidCallback? onValidate;
  final bool isValidated;

  @override
  State<RecordedAudioPreview> createState() => _RecordedAudioPreviewState();
}

class _RecordedAudioPreviewState extends State<RecordedAudioPreview> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  StreamSubscription? _posSub;
  StreamSubscription? _stateSub;

  @override
  void initState() {
    super.initState();
    _posSub = _player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _stateSub = _player.onPlayerStateChanged.listen((s) {
      if (mounted) {
        setState(() {
          _isPlaying = (s == PlayerState.playing);
          if (s == PlayerState.completed) {
            _position = Duration.zero;
            _isPlaying = false;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _stateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;
    HapticFeedback.selectionClick();
    if (_isPlaying) {
      await _player.pause();
    } else {
      setState(() => _isLoading = true);
      try {
        if (_position == Duration.zero) {
          if (widget.audioFile != null) {
            await _player.play(DeviceFileSource(widget.audioFile!.path));
          } else if (widget.audioUrl != null && widget.audioUrl!.isNotEmpty) {
            await _player.play(UrlSource(widget.audioUrl!));
          }
        } else {
          await _player.resume();
        }
      } catch (e) {
        debugPrint('Audio playback error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seek(double fraction) async {
    final totalMs = widget.duration * 1000;
    final seekMs = (fraction * totalMs).toInt();
    await _player.seek(Duration(milliseconds: seekMs));
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
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

    final totalDuration = Duration(seconds: math.max(widget.duration, 1));
    final progress = (totalDuration.inMilliseconds > 0)
        ? (_position.inMilliseconds / totalDuration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: widget.isValidated
            ? AppColors.success.withValues(alpha: isDark ? 0.12 : 0.06)
            : Colors.amber.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isValidated
              ? AppColors.success.withValues(alpha: 0.45)
              : Colors.amber.withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header Status Row ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.isValidated
                      ? AppColors.success.withValues(alpha: 0.2)
                      : Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isValidated
                          ? Icons.check_circle_rounded
                          : Icons.access_time_rounded,
                      size: 13,
                      color: widget.isValidated
                          ? AppColors.success
                          : (isDark ? Colors.amberAccent : Colors.orange.shade800),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.isValidated
                          ? l10n.capsuleAudioValidatedBadge
                          : l10n.capsuleAudioPendingBadge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: widget.isValidated
                            ? AppColors.success
                            : (isDark ? Colors.amberAccent : Colors.orange.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${_formatDuration(_position)} / ${_formatDuration(totalDuration)}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: secondaryText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Player & Scrubber Row ──
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlayPause,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            _isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: primary,
                    inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                    thumbColor: primary,
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: (val) => _seek(val),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Action Buttons Row ──
          Row(
            children: [
              // Recommencer
              OutlinedButton.icon(
                onPressed: () async {
                  await _player.stop();
                  widget.onReRecord?.call();
                },
                icon: const Icon(Icons.refresh_rounded, size: 15),
                label: Text(l10n.capsuleAudioReRecord),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: BorderSide(
                    color: isDark ? Colors.white24 : Colors.black12,
                  ),
                  foregroundColor: textColor,
                ),
              ),

              const SizedBox(width: 8),

              // Supprimer
              IconButton(
                onPressed: () async {
                  await _player.stop();
                  widget.onDelete();
                },
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                tooltip: l10n.capsuleAudioDelete,
                style: IconButton.styleFrom(visualDensity: VisualDensity.compact),
              ),

              const Spacer(),

              // Valider Button (if not already validated)
              if (!widget.isValidated && widget.onValidate != null)
                ElevatedButton.icon(
                  onPressed: () {
                    widget.onValidate!();
                  },
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(l10n.capsuleAudioValidate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
