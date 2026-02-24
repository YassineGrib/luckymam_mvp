import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Full-screen video player for a single reel.
/// Auto-plays when [isActive], pauses when not.
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

class _ReelPlayerState extends State<ReelPlayer> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_initialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _showPlayIcon = true;
      } else {
        _controller.play();
        _showPlayIcon = false;
      }
    });

    if (!_controller.value.isPlaying) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && !_controller.value.isPlaying) {
          setState(() => _showPlayIcon = false);
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
          child: CircularProgressIndicator(color: Colors.white54),
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

          // Play/Pause icon overlay
          AnimatedOpacity(
            opacity: _showPlayIcon ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),

          // Progress bar at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: false,
              colors: const VideoProgressColors(
                playedColor: Colors.white,
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
