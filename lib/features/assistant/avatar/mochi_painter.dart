import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'mochi_engine.dart';
import 'mochi_palette.dart';
import 'mochi_state.dart';

/// 60 FPS Procedural 2D Canvas Drawing Engine for Mochi.
/// Implements superellipse body, 3D spherical projected eyes,
/// blush, badges, and atmospheric particles without any external assets.
class MochiPainter extends CustomPainter {
  MochiPainter(
    this.engine, {
    required Listenable repaint,
    this.isDark = false,
  }) : super(repaint: repaint);

  final MochiEngine engine;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final W = size.width;
    final H = size.height;
    final R = W * 0.30;
    final rx = R * 1.14;
    final ry = R * 0.88;

    final cx = W / 2 + engine.offsetX * R;
    final cy = H / 2 + engine.offsetY * R + R * 0.06;

    final baseTop = isDark ? MochiPalette.baseDarkTop : MochiPalette.baseLightTop;
    final baseBottom = isDark ? MochiPalette.baseDarkBottom : MochiPalette.baseLightBottom;
    final inkColor = isDark ? MochiPalette.inkDark : MochiPalette.inkLight;

    // 1. Soft radial glow halo behind the character
    final stateTint = MochiPalette.tintFor(engine.state);
    if (stateTint > 0.05) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            engine.currentColor.withValues(alpha: isDark ? 0.40 : 0.25),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: R * 1.35));
      canvas.drawCircle(Offset(cx, cy), R * 1.35, glowPaint);
    }

    // 2. Character body transformed container
    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(engine.tilt);
    canvas.scale(engine.scaleX, engine.scaleY);

    // Construct Lamé Superellipse Squircle Path (exponent n = 2.7)
    final bodyPath = Path();
    const samples = 64;
    for (int i = 0; i <= samples; i++) {
      final theta = (i / samples) * 2.0 * math.pi;
      final cosT = math.cos(theta);
      final sinT = math.sin(theta);
      final signCos = cosT.sign;
      final signSin = sinT.sign;
      final px = rx * signCos * math.pow(cosT.abs(), 2.0 / 2.7);
      final py = ry * signSin * math.pow(sinT.abs(), 2.0 / 2.7);
      if (i == 0) {
        bodyPath.moveTo(px, py);
      } else {
        bodyPath.lineTo(px, py);
      }
    }
    bodyPath.close();

    // 2.1 Base diagonal linear gradient
    final baseGradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [baseTop, baseBottom],
      ).createShader(Rect.fromLTRB(-rx, -ry, rx, ry));
    canvas.drawPath(bodyPath, baseGradientPaint);

    // 2.2 Dynamic state tint overlay
    if (stateTint > 0.01) {
      final tintPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            engine.currentColor.withValues(alpha: (0.85 * stateTint).clamp(0.0, 1.0)),
            engine.currentColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTRB(-rx, -ry * 0.25, rx, ry));
      canvas.drawPath(bodyPath, tintPaint);
    }


    // 3. Cheeks (blush follows gaze)
    final totalBlush = (engine.blush > 0.01 ? engine.blush : 0.35).clamp(0.0, 1.0);
    if (totalBlush > 0.01) {
      canvas.save();
      canvas.clipPath(bodyPath);
      final cheekYOffset = math.sin(engine.yaw) * rx * 0.8;
      final blushPaint = Paint()
        ..color = MochiPalette.blush.withValues(alpha: (0.45 * totalBlush).clamp(0.0, 1.0));
      for (final sd in [-1.0, 1.0]) {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(sd * rx * 0.55 + cheekYOffset, ry * 0.20),
            width: R * 0.34,
            height: R * 0.20,
          ),
          blushPaint,
        );
      }
      canvas.restore();
    }

    // 4. 3D Spherical projected eyes
    canvas.save();
    canvas.clipPath(bodyPath);

    final eyePaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.fill;
    final eyeStrokePaint = Paint()
      ..color = inkColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shape = engine.currentEyeShape;

    for (final sd in [-1.0, 1.0]) {
      final yaw = sd * 0.37 + engine.yaw;
      var pitch = -0.12 + engine.pitch + engine.roll;
      pitch = ((pitch + math.pi) % (2 * math.pi) + 2 * math.pi) % (2 * math.pi) - math.pi;

      final cosPitch = math.cos(pitch);
      // Horizon clipping: if the eye rolls behind the back of the head, clip it
      if (math.cos(yaw) * cosPitch < 0.04) continue;

      final px = math.sin(yaw) * cosPitch * rx;
      final py = -math.sin(pitch) * ry;

      final fx = math.max(0.18, math.cos(yaw));
      final fy = math.max(0.18, cosPitch);

      canvas.save();
      canvas.translate(px, py);
      canvas.scale(fx, fy);

      final ew = R * 0.25 * engine.eyeScale;
      final eh = R * 0.27 * engine.eyeScale;

      _drawEye(
        canvas: canvas,
        shape: shape,
        w: ew,
        h: eh,
        open: engine.eyeOpen,
        sd: sd,
        fillPaint: eyePaint,
        strokePaint: eyeStrokePaint,
      );

      canvas.restore();
    }
    canvas.restore();

    // 5. Speaking mouth (when speaking is active)
    if (engine.mouthOpen > 0.02) {
      final mw = R * 0.22;
      final mh = R * 0.16 * engine.mouthOpen;
      final mouthPaint = Paint()
        ..color = inkColor
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(math.sin(engine.yaw) * rx * 0.4, ry * 0.28),
            width: mw,
            height: mh,
          ),
          Radius.circular(mh / 2),
        ),
        mouthPaint,
      );
    }

    canvas.restore(); // end of transformed body

    // 6. Overhead Status Badges
    if (engine.currentBadge != BadgeType.none && engine.badgeScale > 0.01) {
      final bx = cx - rx * 0.76 * engine.scaleX;
      final by = cy - ry * 0.72 * engine.scaleY;

      canvas.save();
      canvas.translate(bx, by);
      canvas.scale(engine.badgeScale, engine.badgeScale);

      final badgeCol = engine.badgeColor;

      switch (engine.currentBadge) {
        case BadgeType.dots:
          final bw = R * 0.74;
          final bh = R * 0.42;
          // Black outline/shadow pill
          final bgPaint = Paint()..color = Colors.black.withValues(alpha: 0.85);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: bw + 4, height: bh + 4),
              Radius.circular((bh + 4) / 2),
            ),
            bgPaint,
          );
          // Color pill
          final pillPaint = Paint()..color = badgeCol;
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: bw, height: bh),
              Radius.circular(bh / 2),
            ),
            pillPaint,
          );
          // 3 Animated dots
          final dotPaint = Paint()..color = Colors.white;
          final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
          for (int i = 0; i < 3; i++) {
            final phase = ((time * 2.4 - i * 0.22) % 1.0 + 1.0) % 1.0;
            final dotR = R * 0.055 * (1.0 + 0.45 * math.max(0.0, math.sin(phase * math.pi * 2)));
            canvas.drawCircle(Offset((i - 1) * R * 0.19, 0), dotR, dotPaint);
          }
          break;

        case BadgeType.bang:
        case BadgeType.question:
          // Background circle
          canvas.drawCircle(Offset.zero, R * 0.26, Paint()..color = Colors.black.withValues(alpha: 0.85));
          canvas.drawCircle(Offset.zero, R * 0.22, Paint()..color = badgeCol);
          // Text icon
          final textPainter = TextPainter(
            text: TextSpan(
              text: engine.currentBadge == BadgeType.bang ? '!' : '?',
              style: TextStyle(
                color: Colors.white,
                fontSize: R * 0.30,
                fontWeight: FontWeight.w900,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(
            canvas,
            Offset(-textPainter.width / 2, -textPainter.height / 2),
          );
          break;

        case BadgeType.dot:
          canvas.drawCircle(Offset.zero, R * 0.18, Paint()..color = Colors.black.withValues(alpha: 0.85));
          canvas.drawCircle(Offset.zero, R * 0.14, Paint()..color = badgeCol);
          break;

        case BadgeType.none:
          break;
      }
      canvas.restore();
    }

    // 7. Atmospheric Floating Particles
    for (final p in engine.particles) {
      if (p.age < 0.0) continue;
      final k = (p.age / p.life).clamp(0.0, 1.0);
      final alpha = k < 0.2 ? (k / 0.2) : 1.0 - ((k - 0.2) / 0.8);
      final px = cx + (p.x + p.vx * p.age) * R * 1.3;
      final py = cy + (p.y + p.vy * p.age) * R * 1.3;
      final sz = R * p.sz * (1.0 + k * 0.4);

      canvas.save();
      canvas.translate(px, py);

      switch (p.type) {
        case ParticleType.heart:
          canvas.rotate(math.sin(p.age * 6.0) * 0.3);
          _drawHeart(canvas, sz, MochiPalette.emoteHeart.withValues(alpha: alpha.clamp(0.0, 1.0)));
          break;
        case ParticleType.star:
          canvas.rotate(p.rot + p.age * 2.0);
          _drawStar(canvas, sz, sz * 0.45, MochiPalette.emoteStar.withValues(alpha: alpha.clamp(0.0, 1.0)));
          break;
        case ParticleType.spark:
          canvas.rotate(p.rot);
          _drawStar(canvas, sz * 0.8, sz * 0.18, Colors.white.withValues(alpha: alpha.clamp(0.0, 1.0)));
          break;
        case ParticleType.sweat:
          final sweatPath = Path()
            ..moveTo(0, -sz)
            ..quadraticBezierTo(sz * 0.8, sz * 0.2, 0, sz * 0.6)
            ..quadraticBezierTo(-sz * 0.8, sz * 0.2, 0, -sz)
            ..close();
          canvas.drawPath(
            sweatPath,
            Paint()..color = MochiPalette.emoteSweat.withValues(alpha: alpha.clamp(0.0, 1.0)),
          );
          break;
        case ParticleType.z:
          final textPainter = TextPainter(
            text: TextSpan(
              text: 'Z',
              style: TextStyle(
                color: MochiPalette.emoteZzz.withValues(alpha: alpha.clamp(0.0, 1.0)),
                fontSize: sz * 1.8,
                fontWeight: FontWeight.w800,
              ),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          textPainter.paint(canvas, Offset(-textPainter.width / 2, -textPainter.height / 2));
          break;
      }

      canvas.restore();
    }
  }

  void _drawEye({
    required Canvas canvas,
    required EyeShape shape,
    required double w,
    required double h,
    required double open,
    required double sd,
    required Paint fillPaint,
    required Paint strokePaint,
  }) {
    switch (shape) {
      case EyeShape.wide:
        final ww = w * 1.16;
        final hh = math.max(h * 1.12 * open, ww * 0.30);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: ww, height: hh),
            Radius.circular(math.min(ww / 2, hh / 2)),
          ),
          fillPaint,
        );
        break;

      case EyeShape.pill:
        final hh = math.max(h * open, w * 0.30);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w, height: hh),
            Radius.circular(math.min(w / 2, hh / 2)),
          ),
          fillPaint,
        );
        break;

      case EyeShape.dot:
        canvas.drawCircle(Offset.zero, w * 0.45, fillPaint);
        break;

      case EyeShape.line:
      case EyeShape.flat:
        final hh = w * 0.35;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w * 1.4, height: hh),
            Radius.circular(hh / 2),
          ),
          fillPaint,
        );
        break;

      case EyeShape.happy:
        strokePaint.strokeWidth = w * 0.45;
        final arcRect = Rect.fromCenter(center: Offset(0, h * 0.18), width: w * 1.6, height: h * 1.2);
        canvas.drawArc(arcRect, math.pi * 1.12, math.pi * 0.76, false, strokePaint);
        break;

      case EyeShape.closed:
        strokePaint.strokeWidth = w * 0.35;
        final arcRect = Rect.fromCenter(center: Offset(0, -h * 0.08), width: w * 1.5, height: h * 1.2);
        canvas.drawArc(arcRect, math.pi * 0.15, math.pi * 0.70, false, strokePaint);
        break;

      case EyeShape.spiral:
        strokePaint.strokeWidth = w * 0.20;
        final spiralPath = Path();
        for (double a = 0.0; a < 4.4 * math.pi; a += 0.2) {
          final r = w * 0.06 + a * w * 0.058;
          final px = math.cos(a) * r;
          final py = math.sin(a) * r;
          if (a == 0.0) {
            spiralPath.moveTo(px, py);
          } else {
            spiralPath.lineTo(px, py);
          }
        }
        canvas.drawPath(spiralPath, strokePaint);
        break;

      case EyeShape.heart:
        _drawHeart(canvas, w * 1.2, MochiPalette.emoteHeart);
        break;

      case EyeShape.star:
        _drawStar(canvas, w * 1.05, w * 0.46, MochiPalette.emoteStar);
        break;

      case EyeShape.tired:
        final hh = h * 0.38;
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: w, height: hh),
            Radius.circular(hh / 2),
          ),
          fillPaint,
        );
        break;

      case EyeShape.wink:
        if (sd < 0) {
          final hh = math.max(h * open, w * 0.30);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset.zero, width: w, height: hh),
              Radius.circular(math.min(w / 2, hh / 2)),
            ),
            fillPaint,
          );
        } else {
          strokePaint.strokeWidth = w * 0.45;
          final arcRect = Rect.fromCenter(center: Offset(0, h * 0.18), width: w * 1.6, height: h * 1.2);
          canvas.drawArc(arcRect, math.pi * 1.12, math.pi * 0.76, false, strokePaint);
        }
        break;
    }
  }

  void _drawHeart(Canvas canvas, double size, Color color) {
    final path = Path();
    final s = size;
    path.moveTo(0, s * 0.38);
    path.cubicTo(-s * 1.05, -s * 0.15, -s * 0.50, -s * 0.95, 0, -s * 0.38);
    path.cubicTo(s * 0.50, -s * 0.95, s * 1.05, -s * 0.15, 0, s * 0.38);
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawStar(Canvas canvas, double rOuter, double rInner, Color color) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final r = i % 2 == 1 ? rInner : rOuter;
      final a = -math.pi / 2 + i * math.pi / 5;
      final px = math.cos(a) * r;
      final py = math.sin(a) * r;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant MochiPainter oldDelegate) => true;
}
