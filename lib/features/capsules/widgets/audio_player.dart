import 'dart:async';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';

/// SoundCloud-style audio player — no box, bigger waveform, floating style.
class CapsuleAudioPlayer extends StatefulWidget {
  const CapsuleAudioPlayer({
    super.key,
    required this.audioUrl,
    required this.duration,
    this.onPlayingChanged,
  });

  final String audioUrl;
  final int duration;

  /// Called whenever play/pause state changes.
  final ValueChanged<bool>? onPlayingChanged;

  @override
  State<CapsuleAudioPlayer> createState() => _CapsuleAudioPlayerState();
}

class _CapsuleAudioPlayerState extends State<CapsuleAudioPlayer>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  bool _isLoading = false;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _stateSubscription;

  late final AnimationController _pulseController;
  late final List<double> _waveformBars;

  static const int _barCount = 50;

  @override
  void initState() {
    super.initState();
    _initPlayer();
    _generateWaveform();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  void _generateWaveform() {
    final random = Random(widget.audioUrl.hashCode);
    _waveformBars = List.generate(_barCount, (i) {
      final envelope = sin(i / _barCount * pi);
      final noise = 0.3 + random.nextDouble() * 0.7;
      return (envelope * noise).clamp(0.15, 1.0);
    });
  }

  void _initPlayer() {
    _positionSubscription = _player.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });

    _stateSubscription = _player.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      final playing = state == PlayerState.playing;
      setState(() {
        _isPlaying = playing;
        if (state == PlayerState.completed) {
          _position = Duration.zero;
          _pulseController.stop();
        }
        if (_isPlaying) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
        }
      });
      // Notify parent
      widget.onPlayingChanged?.call(playing);
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _stateSubscription?.cancel();
    _pulseController.dispose();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    if (_isLoading) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      setState(() => _isLoading = true);
      try {
        if (_position == Duration.zero) {
          await _player.play(UrlSource(widget.audioUrl));
        } else {
          await _player.resume();
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _seekToPosition(double tapX, double totalWidth) async {
    final fraction = (tapX / totalWidth).clamp(0.0, 1.0);
    final totalMs = widget.duration * 1000;
    final seekMs = (fraction * totalMs).toInt();
    await _player.seek(Duration(milliseconds: seekMs));
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = Duration(seconds: widget.duration);
    final progress = totalDuration.inMilliseconds > 0
        ? (_position.inMilliseconds / totalDuration.inMilliseconds).clamp(
            0.0,
            1.0,
          )
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Play/Pause button
          _buildPlayButton(),
          const SizedBox(width: 14),

          // Waveform + time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildWaveform(progress),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_position),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatDuration(totalDuration),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = _isPlaying
              ? 1.0 + (_pulseController.value * 0.06)
              : 1.0;
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.magentaPink, AppColors.coral],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.magentaPink.withValues(alpha: 0.5),
                    blurRadius: _isPlaying ? 20 : 10,
                    spreadRadius: _isPlaying ? 3 : 0,
                  ),
                ],
              ),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : _isPlaying
                  // Pause icon when playing
                  ? const Icon(
                      Icons.pause_rounded,
                      color: Colors.white,
                      size: 28,
                    )
                  // App logo when paused/stopped
                  : Padding(
                      padding: const EdgeInsets.all(10),
                      child: SvgPicture.asset(
                        'assets/logo/logo svg.svg',
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWaveform(double progress) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        return GestureDetector(
          onTapDown: (details) =>
              _seekToPosition(details.localPosition.dx, totalWidth),
          onHorizontalDragUpdate: (details) =>
              _seekToPosition(details.localPosition.dx, totalWidth),
          child: SizedBox(
            height: 44,
            child: CustomPaint(
              size: Size(totalWidth, 44),
              painter: _WaveformPainter(
                bars: _waveformBars,
                progress: progress,
                activeColor: AppColors.magentaPink,
                inactiveColor: Colors.white.withValues(alpha: 0.22),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WaveformPainter extends CustomPainter {
  _WaveformPainter({
    required this.bars,
    required this.progress,
    required this.activeColor,
    required this.inactiveColor,
  });

  final List<double> bars;
  final double progress;
  final Color activeColor;
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final barCount = bars.length;
    const gap = 2.0;
    final barWidth = (size.width - (barCount - 1) * gap) / barCount;
    final centerY = size.height / 2;

    final activePaint = Paint()..style = PaintingStyle.fill;
    final inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < barCount; i++) {
      final x = i * (barWidth + gap);
      final barProgress = (i + 1) / barCount;
      final isActive = barProgress <= progress;

      final barHeight = bars[i] * size.height * 0.9;
      final halfH = barHeight / 2;

      final paint = isActive ? activePaint : inactivePaint;
      if (isActive) {
        final intensity =
            1.0 - ((progress - barProgress).abs() * 2).clamp(0.0, 0.5);
        paint.color = Color.lerp(
          activeColor.withValues(alpha: 0.65),
          activeColor,
          intensity,
        )!;
      }

      final rect = RRect.fromRectAndRadius(
        Rect.fromLTRB(x, centerY - halfH, x + barWidth, centerY + halfH),
        const Radius.circular(2),
      );
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
