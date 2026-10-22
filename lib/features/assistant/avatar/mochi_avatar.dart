import 'package:flutter/material.dart';
import 'mochi_engine.dart';
import 'mochi_painter.dart';
import 'mochi_state.dart';

/// Interactive procedural Mochi avatar widget.
/// Runs a 60 FPS animation ticker, manages physics, handles touch gestures,
/// and responds to user focus and reduced-motion settings.
class MochiAvatar extends StatefulWidget {
  const MochiAvatar({
    super.key,
    required this.state,
    this.speaking = false,
    this.size = 140,
    this.animated = true,
    this.onTap,
    this.customEngine,
  });

  final MochiState state;
  final bool speaking;
  final double size;
  final bool animated;
  final VoidCallback? onTap;
  final MochiEngine? customEngine;

  @override
  State<MochiAvatar> createState() => MochiAvatarState();
}

class MochiAvatarState extends State<MochiAvatar>
    with SingleTickerProviderStateMixin {
  late final MochiEngine _engine;
  late final AnimationController _animController;
  int _lastTimestampMs = 0;

  @visibleForTesting
  MochiEngine get debugEngine => _engine;

  @override
  void initState() {
    super.initState();
    _engine = widget.customEngine ?? MochiEngine();
    _engine.setState(widget.state, force: true);
    _engine.setSpeaking(widget.speaking);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _lastTimestampMs = DateTime.now().millisecondsSinceEpoch;
    _animController.addListener(() {
      final now = DateTime.now().millisecondsSinceEpoch;
      final dt = (now - _lastTimestampMs) / 1000.0;
      _lastTimestampMs = now;
      _engine.update(dt);
    });

    if (widget.animated) {
      _animController.repeat();
    } else {
      _engine.update(0.016);
    }
  }

  @override
  void didUpdateWidget(covariant MochiAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _engine.setState(widget.state);
    }
    if (oldWidget.speaking != widget.speaking) {
      _engine.setSpeaking(widget.speaking);
    }
    if (oldWidget.animated != widget.animated) {
      if (widget.animated) {
        if (!_animController.isAnimating) _animController.repeat();
      } else {
        _animController.stop();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations = MediaQuery.of(context).disableAnimations;
    _engine.setReducedMotion(disableAnimations);
    if (disableAnimations || !widget.animated) {
      if (_animController.isAnimating) _animController.stop();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handlePan(Offset localPosition) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final delta = localPosition - center;
    _engine.lookAt(delta.dx, delta.dy);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      label: 'Lucky',
      container: true,
      button: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _engine.tap();
          widget.onTap?.call();
        },
        onPanUpdate: (details) => _handlePan(details.localPosition),
        onPanEnd: (_) => _engine.lookAt(0.0, 0.0),
        child: MouseRegion(
          onHover: (event) => _handlePan(event.localPosition),
          onExit: (_) => _engine.lookAt(0.0, 0.0),
          child: RepaintBoundary(
            child: SizedBox(
              width: widget.size,
              height: widget.size,
              child: CustomPaint(
                painter: MochiPainter(
                  _engine,
                  repaint: _animController,
                  isDark: isDark,
                ),
                size: Size(widget.size, widget.size),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
