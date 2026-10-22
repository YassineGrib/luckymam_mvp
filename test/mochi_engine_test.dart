import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_state.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_palette.dart';
import 'package:lukymam_mvp/features/assistant/avatar/mochi_engine.dart';

void main() {
  group('MochiEngine Unit Tests', () {
    test('blink closes then reopens within 0.3 s', () {
      final engine = MochiEngine(random: math.Random(42));
      expect(engine.eyeOpen, 1.0);

      engine.debugBlinkNow();
      // Step forward ~0.07 s (close phase)
      for (int i = 0; i < 4; i++) {
        engine.update(1 / 60);
      }
      expect(engine.eyeOpen, lessThan(0.3));

      // Step forward to 0.3 s (open phase)
      for (int i = 0; i < 16; i++) {
        engine.update(1 / 60);
      }
      expect(engine.eyeOpen, greaterThan(0.95));
    });

    test('idle blinks eventually over 8 s simulation', () {
      final engine = MochiEngine(random: math.Random(10));
      bool dippedBelowHalf = false;

      // Simulate 8 seconds at 60 FPS
      for (int i = 0; i < 8 * 60; i++) {
        engine.update(1 / 60);
        if (engine.eyeOpen < 0.5) {
          dippedBelowHalf = true;
          break;
        }
      }
      expect(dippedBelowHalf, isTrue);
    });

    test('gaze is compressed with tanh and smoothed with lag', () {
      final engine = MochiEngine();
      engine.lookAt(10000, 0); // huge offset

      // After 2 seconds of updates, yaw should approach 0.62 but never exceed it
      for (int i = 0; i < 120; i++) {
        engine.update(1 / 60);
      }
      expect(engine.yaw, closeTo(0.62, 0.02));
      expect(engine.yaw, lessThanOrEqualTo(0.621));
    });

    test('speaking oscillates mouthOpen and settles on stop', () {
      final engine = MochiEngine();
      engine.setSpeaking(true);

      double minMouth = 1.0;
      double maxMouth = 0.0;
      for (int i = 0; i < 60; i++) {
        engine.update(1 / 60);
        if (engine.mouthOpen < minMouth) minMouth = engine.mouthOpen;
        if (engine.mouthOpen > maxMouth) maxMouth = engine.mouthOpen;
      }
      expect(minMouth, lessThan(0.3));
      expect(maxMouth, greaterThan(0.5));

      engine.setSpeaking(false);
      for (int i = 0; i < 30; i++) {
        engine.update(1 / 60);
      }
      expect(engine.mouthOpen, lessThan(0.05));
    });

    test('five quick taps trigger dizzy state then restore previous state', () {
      final engine = MochiEngine();
      expect(engine.state, MochiState.idle);

      // 5 rapid taps within 1.5 seconds
      for (int i = 0; i < 5; i++) {
        engine.tap();
        engine.update(0.1);
      }
      expect(engine.state, MochiState.dizzy);

      // Simulate 1.6 seconds to recover
      for (int i = 0; i < 100; i++) {
        engine.update(1 / 60);
      }
      expect(engine.state, MochiState.idle);
    });

    test('love emote emits heart particles and particles expire', () {
      final engine = MochiEngine();
      engine.emote(MochiEmote.love);

      // Step forward 0.5 s
      for (int i = 0; i < 30; i++) {
        engine.update(1 / 60);
      }
      expect(engine.particles.any((p) => p.type == ParticleType.heart), isTrue);

      // Simulate 6 seconds to let all particles expire
      for (int i = 0; i < 6 * 60; i++) {
        engine.update(1 / 60);
      }
      expect(engine.particles.isEmpty, isTrue);
    });

    test('reduced motion freezes the pose and clears particles', () {
      final engine = MochiEngine();
      engine.setReducedMotion(true);
      engine.lookAt(500, 500);
      engine.emote(MochiEmote.love);

      for (int i = 0; i < 60; i++) {
        engine.update(1 / 60);
      }
      expect(engine.yaw, 0.0);
      expect(engine.pitch, 0.0);
      expect(engine.roll, 0.0);
      expect(engine.tilt, 0.0);
      expect(engine.particles.isEmpty, isTrue);
      expect(engine.eyeOpen, 1.0);
    });

    test('MochiPalette provides correct state colors and base palette', () {
      expect(MochiPalette.working, const Color(0xFF3B9EFF));
      expect(MochiPalette.thinking, const Color(0xFF8B5CF6));
      expect(MochiPalette.searching, const Color(0xFF6366F1));
      expect(MochiPalette.finished, const Color(0xFF34D399));
      expect(MochiPalette.error, const Color(0xFFF4505E));
      expect(MochiPalette.blush, const Color(0xFFFF7896));
    });
  });
}
