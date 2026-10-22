import 'package:flutter/material.dart';
import 'mochi_state.dart';

/// Color palette, volumetric gradients, and state tinting for the Mochi avatar.
abstract final class MochiPalette {
  // Base body dough gradient colors (light)
  static const Color baseLightTop = Color(0xFFFFFFFF);
  static const Color baseLightBottom = Color(0xFFFFE8ED);

  // Base body dough gradient colors (dark)
  static const Color baseDarkTop = Color(0xFF322E3B);
  static const Color baseDarkBottom = Color(0xFF1D1A24);

  // Ink color for eyes, pupils, and outlines
  static const Color inkLight = Color(0xFF1A1412);
  static const Color inkDark = Color(0xFFF5F4F8);

  // Cheeks blushing color
  static const Color blush = Color(0xFFFF7896);

  // State colors
  static const Color idle = Color(0xFFE6E9EE);
  static const Color working = Color(0xFF3B9EFF);
  static const Color thinking = Color(0xFF8B5CF6);
  static const Color searching = Color(0xFF6366F1);
  static const Color approval = Color(0xFFF5A524);
  static const Color question = Color(0xFF22D3EE);
  static const Color error = Color(0xFFF4505E);
  static const Color finished = Color(0xFF34D399);
  static const Color ratelimit = Color(0xFFFB923C);
  static const Color sleeping = Color(0xFF94A3B8);
  static const Color dizzy = Color(0xFFF472B6);
  static const Color gentle = Color(0xFFA78BFA);

  // Emote colors
  static const Color emoteHeart = Color(0xFFFF4D6D);
  static const Color emoteStar = Color(0xFFF7B32B);
  static const Color emoteSweat = Color(0xFF7CC7FF);
  static const Color emoteZzz = Color(0xFFD2DCEB);

  /// Returns the corresponding accent color for a given state.
  static Color colorFor(MochiState state) {
    switch (state) {
      case MochiState.idle:
        return idle;
      case MochiState.working:
        return working;
      case MochiState.thinking:
        return thinking;
      case MochiState.searching:
        return searching;
      case MochiState.approval:
        return approval;
      case MochiState.question:
        return question;
      case MochiState.error:
        return error;
      case MochiState.finished:
        return finished;
      case MochiState.ratelimit:
        return ratelimit;
      case MochiState.sleeping:
        return sleeping;
      case MochiState.dizzy:
        return dizzy;
      case MochiState.gentle:
        return gentle;
    }
  }

  /// Returns tint level (0.0 to 1.0) applied to the volumetric overlay.
  static double tintFor(MochiState state) {
    switch (state) {
      case MochiState.idle:
        return 0.0;
      case MochiState.working:
        return 0.72;
      case MochiState.thinking:
        return 0.72;
      case MochiState.searching:
        return 0.72;
      case MochiState.approval:
        return 0.78;
      case MochiState.question:
        return 0.75;
      case MochiState.error:
        return 0.78;
      case MochiState.finished:
        return 0.35;
      case MochiState.ratelimit:
        return 0.72;
      case MochiState.sleeping:
        return 0.32;
      case MochiState.dizzy:
        return 0.70;
      case MochiState.gentle:
        return 0.25;
    }
  }
}
