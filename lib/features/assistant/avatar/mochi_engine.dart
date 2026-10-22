import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mochi_state.dart';
import 'mochi_palette.dart';

/// Easing curve implementations matching CHARACTER_AI spec §6.
double easeOut(double t) {
  final clamped = t.clamp(0.0, 1.0);
  return 1.0 - math.pow(1.0 - clamped, 3.0);
}

double easeInOut(double t) {
  final clamped = t.clamp(0.0, 1.0);
  return clamped < 0.5
      ? 4.0 * clamped * clamped * clamped
      : 1.0 - math.pow(-2.0 * clamped + 2.0, 3.0) / 2.0;
}

double easeBack(double t) {
  final clamped = t.clamp(0.0, 1.0);
  const c1 = 1.7;
  const c3 = c1 + 1.0;
  return 1.0 +
      c3 * math.pow(clamped - 1.0, 3.0) +
      c1 * math.pow(clamped - 1.0, 2.0);
}

/// Tween keyframe step: target value, duration in ms, easing function.
class _Keyframe {
  const _Keyframe(this.target, this.durationMs, this.ease);
  final double target;
  final double durationMs;
  final double Function(double) ease;
}

/// Active property tween runner.
class _Tween {
  _Tween({
    required this.property,
    required this.keys,
    required this.from,
    required this.startTime,
    this.onCompleted,
  });

  final String property;
  final List<_Keyframe> keys;
  double from;
  double startTime;
  int keyIndex = 0;
  final VoidCallback? onCompleted;
}

/// Physics, state machine, and animation engine for Mochi.
class MochiEngine {
  MochiEngine({math.Random? random}) : _random = random ?? math.Random() {
    _currentColor = MochiPalette.colorFor(_state);
    _targetColor = _currentColor;
    _nextBlinkTime = 2.0 + _random.nextDouble() * 3.0;
  }

  final math.Random _random;

  // Geometry and projection variables read by painter
  double yaw = 0.0;
  double pitch = 0.0;
  double roll = 0.0;
  double tilt = 0.0;
  double scaleX = 1.0;
  double scaleY = 1.0;
  double offsetX = 0.0;
  double offsetY = 0.0;
  double eyeOpen = 1.0;
  double eyeScale = 1.0;
  double blush = 0.0;
  double mouthOpen = 0.0;
  double badgeScale = 0.0;

  // State
  MochiState _state = MochiState.idle;
  MochiState get state => _state;
  MochiState _previousState = MochiState.idle;

  // Emote / Transient overlays
  EyeShape? _overrideEyeShape;
  double _overrideEyeUntil = 0.0;
  BadgeType _badgeType = BadgeType.none;
  BadgeType get currentBadge => _badgeType;
  Color _badgeColor = Colors.white;
  Color get badgeColor => _badgeColor;

  Color _currentColor = MochiPalette.idle;
  Color get currentColor => _currentColor;
  Color _targetColor = MochiPalette.idle;

  // Look target
  double _lookTargetX = 0.0;
  double _lookTargetY = 0.0;

  // Particles
  final List<MochiParticle> _particles = [];
  List<MochiParticle> get particles => List.unmodifiable(_particles);

  // Time & Timers
  double _elapsedTime = 0.0;
  double _nextBlinkTime = 2.5;
  bool _speaking = false;
  bool _reducedMotion = false;

  // Multi-tap detection for dizzy
  final List<double> _tapTimestamps = [];

  // Active property tweens
  final List<_Tween> _tweens = [];
  final Set<String> _lockedProperties = {};

  EyeShape get currentEyeShape {
    if (_overrideEyeShape != null) return _overrideEyeShape!;
    switch (_state) {
      case MochiState.idle:
      case MochiState.working:
      case MochiState.thinking:
      case MochiState.searching:
      case MochiState.gentle:
        return EyeShape.pill;
      case MochiState.approval:
        return EyeShape.wide;
      case MochiState.question:
        return EyeShape.pill;
      case MochiState.error:
        return EyeShape.flat;
      case MochiState.finished:
        return EyeShape.happy;
      case MochiState.ratelimit:
        return EyeShape.tired;
      case MochiState.sleeping:
        return EyeShape.closed;
      case MochiState.dizzy:
        return EyeShape.spiral;
    }
  }

  void _anim(String property, List<_Keyframe> keys, [VoidCallback? onCompleted]) {
    if (_reducedMotion) return;
    _tweens.removeWhere((t) => t.property == property);
    _tweens.add(
      _Tween(
        property: property,
        keys: keys,
        from: _getProperty(property),
        startTime: _elapsedTime,
        onCompleted: onCompleted,
      ),
    );
    _lockedProperties.add(property);
  }

  double _getProperty(String name) {
    switch (name) {
      case 'yaw':
        return yaw;
      case 'pitch':
        return pitch;
      case 'roll':
        return roll;
      case 'tilt':
        return tilt;
      case 'scaleX':
        return scaleX;
      case 'scaleY':
        return scaleY;
      case 'offsetX':
        return offsetX;
      case 'offsetY':
        return offsetY;
      case 'eyeOpen':
        return eyeOpen;
      case 'eyeScale':
        return eyeScale;
      case 'blush':
        return blush;
      case 'mouthOpen':
        return mouthOpen;
      case 'badgeScale':
        return badgeScale;
      default:
        return 0.0;
    }
  }

  void _setProperty(String name, double value) {
    switch (name) {
      case 'yaw':
        yaw = value;
        break;
      case 'pitch':
        pitch = value;
        break;
      case 'roll':
        roll = value;
        break;
      case 'tilt':
        tilt = value;
        break;
      case 'scaleX':
        scaleX = value;
        break;
      case 'scaleY':
        scaleY = value;
        break;
      case 'offsetX':
        offsetX = value;
        break;
      case 'offsetY':
        offsetY = value;
        break;
      case 'eyeOpen':
        eyeOpen = value;
        break;
      case 'eyeScale':
        eyeScale = value;
        break;
      case 'blush':
        blush = value;
        break;
      case 'mouthOpen':
        mouthOpen = value;
        break;
      case 'badgeScale':
        badgeScale = value;
        break;
    }
  }

  /// Sets active state and triggers state-specific behaviors.
  void setState(MochiState newState, {bool force = false}) {
    if (_state == newState && !force) return;
    final oldState = _state;
    _previousState = oldState;
    _state = newState;

    _targetColor = MochiPalette.colorFor(newState);

    // Badges & Actions
    switch (newState) {
      case MochiState.idle:
        _setBadge(BadgeType.none, Colors.transparent);
        break;
      case MochiState.working:
        _setBadge(BadgeType.dots, MochiPalette.working);
        break;
      case MochiState.thinking:
        _setBadge(BadgeType.dots, MochiPalette.thinking);
        break;
      case MochiState.searching:
        _setBadge(BadgeType.dots, MochiPalette.searching);
        break;
      case MochiState.approval:
        _setBadge(BadgeType.bang, MochiPalette.approval);
        _anim('offsetY', [
          const _Keyframe(-0.2, 150, easeOut),
          const _Keyframe(0.0, 300, easeBack),
        ]);
        break;
      case MochiState.question:
        _setBadge(BadgeType.question, MochiPalette.question);
        blink();
        break;
      case MochiState.error:
        _setBadge(BadgeType.dot, MochiPalette.error);
        _anim('offsetX', [
          const _Keyframe(0.08, 50, easeOut),
          const _Keyframe(-0.08, 70, easeInOut),
          const _Keyframe(0.05, 70, easeInOut),
          const _Keyframe(0.0, 90, easeOut),
        ]);
        break;
      case MochiState.finished:
        _setBadge(BadgeType.dot, MochiPalette.finished);
        _roll(0.95, 1.0);
        emit(ParticleType.spark, 5);
        break;
      case MochiState.ratelimit:
        _setBadge(BadgeType.dot, MochiPalette.ratelimit);
        emit(ParticleType.sweat, 2);
        break;
      case MochiState.sleeping:
        _setBadge(BadgeType.none, Colors.transparent);
        emit(ParticleType.z, 2);
        break;
      case MochiState.dizzy:
        _setBadge(BadgeType.none, Colors.transparent);
        _roll(1.3, 2.0, () {
          _state = _previousState;
          _targetColor = MochiPalette.colorFor(_state);
        });
        break;
      case MochiState.gentle:
        _setBadge(BadgeType.none, Colors.transparent);
        break;
    }
  }

  void _setBadge(BadgeType type, Color col) {
    if (_badgeType == type && _badgeColor == col) return;
    _anim('badgeScale', [const _Keyframe(0.0, 80, easeInOut)], () {
      _badgeType = type;
      _badgeColor = col;
      if (type != BadgeType.none) {
        _anim('badgeScale', [const _Keyframe(1.0, 250, easeBack)]);
      }
    });
  }

  void blink() {
    if (_lockedProperties.contains('eyeOpen') || _reducedMotion) return;
    _anim('eyeOpen', [
      const _Keyframe(0.06, 70, easeInOut),
      const _Keyframe(1.0, 130, easeOut),
    ]);
  }

  void debugBlinkNow() => blink();

  void squash() {
    if (_reducedMotion) return;
    _anim('scaleY', [
      const _Keyframe(0.78, 70, easeOut),
      const _Keyframe(1.10, 130, easeOut),
      const _Keyframe(1.00, 170, easeInOut),
    ]);
    _anim('scaleX', [
      const _Keyframe(1.16, 70, easeOut),
      const _Keyframe(0.95, 130, easeOut),
      const _Keyframe(1.00, 170, easeInOut),
    ]);
  }

  void _roll(double durationSeconds, double turns, [VoidCallback? onCompleted]) {
    if (_reducedMotion) {
      onCompleted?.call();
      return;
    }
    roll = 0.0;
    _anim('roll', [
      _Keyframe(math.pi * 2 * turns, durationSeconds * 1000, easeInOut),
    ], () {
      roll = 0.0;
      onCompleted?.call();
    });
  }

  /// Triggers user poke / tap reaction.
  void tap() {
    final now = _elapsedTime;
    _tapTimestamps.add(now);
    _tapTimestamps.removeWhere((t) => now - t > 1.5);

    if (_tapTimestamps.length >= 5) {
      _tapTimestamps.clear();
      setState(MochiState.dizzy);
      return;
    }
    squash();
    if (_state == MochiState.sleeping) {
      setState(MochiState.idle);
    }
  }

  /// Plays transient emotion.
  void emote(MochiEmote e, {Duration duration = const Duration(milliseconds: 1800)}) {
    if (_reducedMotion) return;
    final durSec = duration.inMilliseconds / 1000.0;
    _overrideEyeUntil = _elapsedTime + durSec;

    switch (e) {
      case MochiEmote.love:
        _overrideEyeShape = EyeShape.heart;
        _anim('blush', [
          const _Keyframe(1.0, 300, easeOut),
          _Keyframe(1.0, (durSec * 1000) - 600, (t) => t),
          const _Keyframe(0.0, 300, easeInOut),
        ]);
        emit(ParticleType.heart, 4);
        _anim('offsetY', [
          const _Keyframe(-0.1, 160, easeOut),
          const _Keyframe(0.0, 300, easeBack),
        ]);
        break;
      case MochiEmote.surprised:
        _overrideEyeShape = EyeShape.dot;
        _anim('offsetY', [
          const _Keyframe(-0.3, 140, easeOut),
          const _Keyframe(0.0, 380, easeBack),
        ]);
        _anim('eyeScale', [
          const _Keyframe(1.25, 120, easeOut),
          const _Keyframe(1.0, 500, easeInOut),
        ]);
        break;
      case MochiEmote.proud:
        _overrideEyeShape = EyeShape.star;
        emit(ParticleType.star, 5);
        _anim('tilt', [
          const _Keyframe(-0.14, 220, easeOut),
          _Keyframe(-0.14, (durSec * 1000) - 500, (t) => t),
          const _Keyframe(0.0, 280, easeInOut),
        ]);
        break;
      case MochiEmote.wink:
        _overrideEyeShape = EyeShape.wink;
        _anim('tilt', [
          const _Keyframe(0.12, 160, easeOut),
          _Keyframe(0.12, (durSec * 1000) - 400, (t) => t),
          const _Keyframe(0.0, 240, easeInOut),
        ]);
        break;
      case MochiEmote.yawn:
        _anim('scaleY', [
          const _Keyframe(1.12, 500, easeInOut),
          const _Keyframe(1.0, 500, easeInOut),
        ]);
        _anim('scaleX', [
          const _Keyframe(0.94, 500, easeInOut),
          const _Keyframe(1.0, 500, easeInOut),
        ]);
        _overrideEyeShape = EyeShape.tired;
        emit(ParticleType.z, 2);
        break;
      case MochiEmote.happy:
        _overrideEyeShape = EyeShape.happy;
        _anim('blush', [
          const _Keyframe(0.6, 200, easeOut),
          const _Keyframe(0.0, 600, easeInOut),
        ]);
        break;
      case MochiEmote.annoyed:
        _overrideEyeShape = EyeShape.line;
        squash();
        break;
    }
  }

  void greet() {
    emote(MochiEmote.happy, duration: const Duration(milliseconds: 1500));
    _anim('offsetY', [
      const _Keyframe(-0.2, 200, easeOut),
      const _Keyframe(0.0, 300, easeBack),
    ]);
  }

  /// Sets gaze tracking coordinates (delta x, delta y from character center).
  void lookAt(double dx, double dy) {
    if (_reducedMotion) {
      _lookTargetX = 0.0;
      _lookTargetY = 0.0;
      return;
    }
    // Tanh non-linear compression matching SPEC §3.1
    _lookTargetX = (math.exp(dx / 260.0) - math.exp(-dx / 260.0)) /
        (math.exp(dx / 260.0) + math.exp(-dx / 260.0));
    _lookTargetY = (math.exp(dy / 200.0) - math.exp(-dy / 200.0)) /
        (math.exp(dy / 200.0) + math.exp(-dy / 200.0));
  }

  /// Emits particles into the scene.
  void emit(ParticleType type, int count) {
    if (_reducedMotion) return;
    for (int i = 0; i < count; i++) {
      final isZ = type == ParticleType.z;
      _particles.add(
        MochiParticle(
          type: type,
          x: (_random.nextDouble() - 0.5) * 0.9 + (isZ ? 0.55 : 0.0),
          y: -0.7 - _random.nextDouble() * 0.2,
          vx: (_random.nextDouble() - 0.5) * 0.35 + (isZ ? 0.18 : 0.0),
          vy: -(0.45 + _random.nextDouble() * 0.35),
          life: 1.3 + _random.nextDouble() * 0.5,
          age: -i * 0.14,
          rot: _random.nextDouble() * 6.0,
          sz: 0.15 + _random.nextDouble() * 0.08,
        ),
      );
    }
  }

  void setSpeaking(bool isSpeaking) {
    _speaking = isSpeaking;
  }

  void setReducedMotion(bool value) {
    _reducedMotion = value;
    if (value) {
      yaw = 0.0;
      pitch = 0.0;
      roll = 0.0;
      tilt = 0.0;
      scaleX = 1.0;
      scaleY = 1.0;
      offsetX = 0.0;
      offsetY = 0.0;
      eyeOpen = 1.0;
      mouthOpen = 0.0;
      _particles.clear();
      _tweens.clear();
      _lockedProperties.clear();
    }
  }

  /// Update loop executed each frame (60 FPS tick).
  void update(double dtSeconds) {
    _elapsedTime += dtSeconds;
    final dt = dtSeconds.clamp(0.0, 0.05);

    if (_reducedMotion) {
      yaw = 0.0;
      pitch = 0.0;
      roll = 0.0;
      tilt = 0.0;
      eyeOpen = 1.0;
      mouthOpen = 0.0;
      return;
    }

    // Step active property tweens
    final activeTweens = List<_Tween>.from(_tweens);
    for (final tw in activeTweens) {
      final key = tw.keys[tw.keyIndex];
      final elapsedKey = (_elapsedTime - tw.startTime) * 1000.0;
      final progress = (elapsedKey / key.durationMs).clamp(0.0, 1.0);
      final eased = key.ease(progress);
      final currentVal = tw.from + (key.target - tw.from) * eased;
      _setProperty(tw.property, currentVal);

      if (progress >= 1.0) {
        tw.from = key.target;
        tw.keyIndex++;
        tw.startTime = _elapsedTime;
        if (tw.keyIndex >= tw.keys.length) {
          _tweens.remove(tw);
          _lockedProperties.remove(tw.property);
          tw.onCompleted?.call();
        }
      }
    }

    // Compute target gaze coordinates
    double targetYaw = _lookTargetX * 0.62;
    double targetPitch = _lookTargetY * 0.50;

    switch (_state) {
      case MochiState.thinking:
        targetYaw = targetYaw * 0.35 + 0.55 * 0.55;
        targetPitch = targetPitch * 0.30 + 0.55 * 0.50;
        break;
      case MochiState.searching:
        targetYaw = math.sin(_elapsedTime * 2.6) * 0.60;
        targetPitch = -0.06;
        break;
      case MochiState.sleeping:
        targetYaw = 0.0;
        targetPitch = -0.14;
        break;
      case MochiState.dizzy:
        targetYaw = math.sin(_elapsedTime * 9.0) * 0.25;
        break;
      default:
        break;
    }

    // Exponential smoothing for gaze & posture
    final kLook = 1.0 - math.pow(0.0025, dt);

    if (!_lockedProperties.contains('yaw')) {
      yaw += (targetYaw - yaw) * kLook;
    }
    if (!_lockedProperties.contains('pitch')) {
      pitch += (targetPitch - pitch) * kLook;
    }

    // Idle breathing
    if (!_lockedProperties.contains('scaleY')) {
      final breath = math.sin(_elapsedTime * 1.8);
      scaleY = 1.0 + breath * 0.035;
      scaleX = 1.0 - breath * 0.020;
    }

    // Speaking mouth oscillation
    if (_speaking) {
      final osc = math.max(0.0, math.sin(_elapsedTime * 16.0));
      mouthOpen += (osc - mouthOpen) * 0.35;
    } else {
      mouthOpen += (0.0 - mouthOpen) * 0.20;
    }

    // Smooth color mixing
    _currentColor = Color.lerp(_currentColor, _targetColor, 1.0 - math.pow(0.002, dt)) ??
        _targetColor;

    // Autonomous blink timer
    if (_elapsedTime > _nextBlinkTime) {
      if (_state != MochiState.sleeping && _state != MochiState.dizzy) {
        blink();
      }
      _nextBlinkTime = _elapsedTime + 2.2 + _random.nextDouble() * 3.2;
    }

    // Expire override emote eyes
    if (_overrideEyeShape != null && _elapsedTime > _overrideEyeUntil) {
      _overrideEyeShape = null;
    }

    // Update particles
    for (final p in _particles) {
      p.age += dt;
    }
    _particles.removeWhere((p) => p.age >= p.life);
  }
}
