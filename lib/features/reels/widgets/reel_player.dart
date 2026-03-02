import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

/// Full-screen video player for a single reel.
/// Auto-plays when [isActive], pauses when not.
/// Features: rose gradient play button + LuckyMam logo watermark.
class ReelPlayer extends StatefulWidget {
  const ReelPlayer({
    super.key,
    required this.assetPath,
    required this.isActive,
  });

  final String assetPath;
  final bool isActive;

  @override
  State<ReelPlayer> createState() => _ReelPlayerState();
}

class _ReelPlayerState extends State<ReelPlayer>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  late AnimationController _pulseAnim;
  late Animation<double> _scaleAnim;
  bool _initialized = false;
  bool _showPlayOverlay = false;

  @override
  void initState() {
    super.initState();
    _pulseAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.88,
    ).animate(CurvedAnimation(parent: _pulseAnim, curve: Curves.easeOut));
    _initController();
  }

  Future<void> _initController() async {
    _controller = VideoPlayerController.asset(widget.assetPath);
    await _controller.initialize();
    _controller.setLooping(true);
    _controller.setVolume(1.0);

    if (mounted) {
      setState(() => _initialized = true);
      if (widget.isActive) _controller.play();
    }
  }

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) return;

    if (widget.isActive && !oldWidget.isActive) {
      _controller.seekTo(Duration.zero);
      _controller.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_initialized) return;

    _pulseAnim.forward().then((_) => _pulseAnim.reverse());

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showPlayOverlay = true;
      } else {
        _controller.play();
        _showPlayOverlay = false;
      }
    });

    // Auto-hide after 2s if paused
    if (!_controller.value.isPlaying) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_controller.value.isPlaying) {
          setState(() => _showPlayOverlay = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.magentaPink,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Black fill
          Container(color: Colors.black),

          // Video — cover the screen
          SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // LuckyMam logo watermark (top-right, semi-transparent)
          Positioned(
            top: 90,
            right: 16,
            child: Opacity(
              opacity: 0.25,
              child: SvgPicture.asset(
                'assets/logo/logo svg.svg',
                width: 36,
                height: 36,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),

          // ── Rose gradient play/pause overlay ─────────────────────
          AnimatedOpacity(
            opacity: _showPlayOverlay ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.magentaPink, AppColors.coral],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.magentaPink.withValues(alpha: 0.5),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
            ),
          ),

          // Progress bar at bottom — rose tinted
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.magentaPink,
                bufferedColor: Colors.white24,
                backgroundColor: Colors.white10,
              ),
              padding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}
