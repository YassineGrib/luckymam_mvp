import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../reel_messages.dart';
import 'package:video_player/video_player.dart';

import '../../../core/theme/app_colors.dart';

/// Full-screen video player for a single reel.
/// Auto-plays when [isActive], pauses when not.
/// Features: rose gradient play button + Luckymam logo watermark.
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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late VideoPlayerController _controller;
  late AnimationController _pulseAnim;
  late Animation<double> _scaleAnim;
  Timer? _playbackWatchdog;
  Duration _lastPosition = Duration.zero;
  int _stalledTicks = 0;
  bool _initialized = false;
  bool _failed = false;
  bool _foreground = true;
  bool _routeCurrent = true;
  int _generation = 0;
  bool get _canPlay => widget.isActive && _foreground && _routeCurrent;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeCurrent = ModalRoute.isCurrentOf(context) ?? true;
    if (_initialized) {
      if (_canPlay) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_initialized) {
      if (_canPlay) {
        _controller.play();
      } else {
        _controller.pause();
      }
    }
  }

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
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  Future<void> _initController() async {
    final path = widget.assetPath;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(path));
    } else {
      _controller = VideoPlayerController.asset(path);
    }
    final controller = _controller;
    final generation = ++_generation;
    try {
      await controller.initialize().timeout(const Duration(seconds: 15));
      if (!mounted || generation != _generation) return;
      await controller.setLooping(true);
      await controller.setVolume(1.0);
      if (!mounted || generation != _generation) return;
      setState(() => _initialized = true);
      controller.addListener(_onVideoChanged);
      _playbackWatchdog?.cancel();
      _lastPosition = controller.value.position;
      _stalledTicks = 0;
      _playbackWatchdog = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted ||
            generation != _generation ||
            !_initialized ||
            !_canPlay ||
            (!controller.value.isPlaying && !controller.value.isBuffering)) {
          _stalledTicks = 0;
          return;
        }
        final position = controller.value.position;
        _stalledTicks = position == _lastPosition ? _stalledTicks + 1 : 0;
        _lastPosition = position;
        if (_stalledTicks >= 3) _showFailure();
      });
      if (_canPlay) await controller.play();
    } catch (_) {
      if (mounted && generation == _generation) {
        controller.removeListener(_onVideoChanged);
        controller.pause();
        setState(() {
          _failed = true;
          _initialized = false;
        });
      }
    }
  }

  void _showFailure() {
    if (!mounted || _failed) return;
    _playbackWatchdog?.cancel();
    setState(() {
      _failed = true;
      _initialized = false;
    });
    _controller.pause().catchError((Object _) {});
  }

  void _onVideoChanged() {
    if (_controller.value.hasError) _showFailure();
  }

  Future<void> _retry() async {
    _generation++;
    _playbackWatchdog?.cancel();
    final previous = _controller;
    previous.removeListener(_onVideoChanged);
    setState(() {
      _failed = false;
      _initialized = false;
    });
    // Platform disposal may wait for a stalled native creation. Retry independently.
    previous.dispose();
    if (mounted) await _initController();
  }

  @override
  void didUpdateWidget(covariant ReelPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_initialized) return;

    if (_canPlay && !oldWidget.isActive) {
      _controller.seekTo(Duration.zero);
      _controller.play();
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _generation++;
    _playbackWatchdog?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onVideoChanged);
    _controller.dispose();
    _pulseAnim.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    if (!_initialized || !_canPlay) return;

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
        if (mounted && _initialized && !_controller.value.isPlaying) {
          setState(() => _showPlayOverlay = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.wifi_off_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                Text(
                  reelMessage(
                    Localizations.localeOf(context).languageCode,
                    'error',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: _retry,
                  child: Text(context.l10n.retry),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
