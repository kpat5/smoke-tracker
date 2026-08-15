import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/constants/personality.dart';
import '../../../core/theme/app_colors.dart';
import '../../../state/mascot_copy.dart';
import 'mascot_expression.dart';

/// The animated Smoke Tracker mascot: an Among-Us-style bean character drawn and
/// animated entirely in Flutter (no art asset). It idles (breathes, blinks, eyes
/// drift), wears a per-[personality] expression, and does a quick squash-pop when
/// [count] increases.
///
/// The `(personality, count, size)` API is intentionally small so this widget's
/// internals can later be swapped for a Rive state machine without touching Home.
class AnimatedMascot extends StatefulWidget {
  const AnimatedMascot({
    super.key,
    required this.personality,
    required this.count,
    this.size = 150,
  });

  final Personality personality;

  /// Today's log count — drives idle energy and the reaction on increase.
  final int count;

  final double size;

  @override
  State<AnimatedMascot> createState() => _AnimatedMascotState();
}

class _AnimatedMascotState extends State<AnimatedMascot>
    with TickerProviderStateMixin {
  // Idle motion tuning (named to avoid magic numbers in the build body).
  static const Duration _idlePeriod = Duration(seconds: 4);
  static const Duration _reactionDuration = Duration(milliseconds: 520);
  static const double _bobFraction = 0.035; // of size, at full energy
  static const double _breatheAmount = 0.04; // vertical scale wobble

  late final AnimationController _idle;
  late final AnimationController _reaction;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(vsync: this, duration: _idlePeriod);
    _reaction = AnimationController(vsync: this, duration: _reactionDuration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (_reduceMotion) {
      _idle.stop();
    } else if (!_idle.isAnimating) {
      _idle.repeat();
    }
  }

  @override
  void didUpdateWidget(AnimatedMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_reduceMotion && widget.count > oldWidget.count) {
      _reaction.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _reaction.dispose();
    super.dispose();
  }

  /// Idle liveliness: personality baseline nudged by how busy today is.
  double get _energy {
    final base = MascotExpression.of(widget.personality).baseEnergy;
    final scenarioBoost = switch (MascotCopy.scenarioFor(widget.count)) {
      MascotScenario.zeroToday => 0.7,
      MascotScenario.someToday => 1.0,
      MascotScenario.manyToday => 1.3,
    };
    return (base * scenarioBoost).clamp(0.0, 1.5);
  }

  @override
  Widget build(BuildContext context) {
    final expression = MascotExpression.of(widget.personality);

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_idle, _reaction]),
        builder: (context, _) {
          final energy = _energy;
          final phase = _reduceMotion ? 0.0 : _idle.value * 2 * math.pi;

          // Idle: gentle bob + breathing scale, plus roaming eyes and a blink.
          final bob = math.sin(phase) * widget.size * _bobFraction * energy;
          final breatheY = 1 + math.sin(phase) * _breatheAmount * energy;
          final blinkOpen = _reduceMotion ? 1.0 : _blinkOpen(_idle.value);
          final pupilDx = _reduceMotion ? 0.0 : math.sin(phase) * 0.18;
          final pupilDy = _reduceMotion ? 0.0 : math.cos(phase * 0.7) * 0.12;

          // Reaction: a stretch-then-squash pop that returns to rest.
          final bump = math.sin(_reaction.value * math.pi);
          final reactScaleX = 1 + bump * 0.12;
          final reactScaleY = 1 - bump * 0.10;
          final hop = -bump * widget.size * 0.06;

          return Transform.translate(
            offset: Offset(0, bob + hop),
            child: Transform(
              alignment: Alignment.bottomCenter,
              transform: Matrix4.diagonal3Values(
                reactScaleX,
                breatheY * reactScaleY,
                1,
              ),
              child: CustomPaint(
                painter: _MascotPainter(
                  expression: expression,
                  blinkOpen: blinkOpen,
                  pupilDx: pupilDx,
                  pupilDy: pupilDy,
                  idleT: _reduceMotion ? 0.0 : _idle.value,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Eye-open factor (1 open, 0 shut) — a single quick blink late in each cycle.
  double _blinkOpen(double t) {
    const start = 0.9;
    const duration = 0.06;
    if (t < start || t > start + duration) return 1;
    final p = (t - start) / duration; // 0..1 across the blink
    return 1 - math.sin(p * math.pi); // 1 → 0 → 1
  }
}

class _MascotPainter extends CustomPainter {
  const _MascotPainter({
    required this.expression,
    required this.blinkOpen,
    required this.pupilDx,
    required this.pupilDy,
    required this.idleT,
  });

  final MascotExpression expression;
  final double blinkOpen;
  final double pupilDx;
  final double pupilDy;

  /// Idle-cycle progress, 0..1 (0 while reduce-motion is on). Drives the
  /// signature particle and background dust motes as pure functions of time,
  /// with no spawned/mutable particle state to manage.
  final double idleT;

  // Fixed seed points for the background dust motes (fractions of `s`).
  static const List<Offset> _moteSeeds = [
    Offset(0.10, 0.22),
    Offset(0.86, 0.18),
    Offset(0.18, 0.78),
    Offset(0.90, 0.62),
    Offset(0.55, 0.08),
    Offset(0.34, 0.88),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    _drawShadow(canvas, s);
    _drawDustMotes(canvas, s);
    _drawBody(canvas, s);
    _drawLimbsAndProps(canvas, s);
    _drawFace(canvas, s);
    _drawParticle(canvas, s);
  }

  void _drawShadow(Canvas canvas, double s) {
    final shadow = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.92),
        width: s * 0.5,
        height: s * 0.12,
      ),
      shadow,
    );
  }

  void _drawDustMotes(Canvas canvas, double s) {
    final paint = Paint();
    for (var i = 0; i < _moteSeeds.length; i++) {
      final seed = _moteSeeds[i];
      final phase = idleT * 2 * math.pi + i * 1.7;
      final dx = seed.dx * s + math.sin(phase) * s * 0.02;
      final dy = seed.dy * s - ((idleT + i * 0.15) % 1.0) * s * 0.16;
      final alpha = (0.08 + math.sin(phase) * 0.05).clamp(0.0, 0.16);
      paint.color = AppColors.textMuted.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dx, dy), s * 0.006, paint);
    }
  }

  /// The blob/slime body silhouette: a rounded top with a wider, tapered
  /// base, anchored on a waist line so limbs can be placed relative to it.
  Path _blobPath(double s) {
    final cx = s * 0.5;
    final waistY = s * 0.68;
    const w = 0.58;
    const h = 0.56;
    return Path()
      ..moveTo(cx - s * w / 2, waistY)
      ..cubicTo(
        cx - s * w / 2,
        waistY - s * h * 0.78,
        cx - s * w * 0.36,
        waistY - s * h,
        cx,
        waistY - s * h,
      )
      ..cubicTo(
        cx + s * w * 0.36,
        waistY - s * h,
        cx + s * w / 2,
        waistY - s * h * 0.78,
        cx + s * w / 2,
        waistY,
      )
      ..cubicTo(
        cx + s * w / 2,
        waistY + s * h * 0.24,
        cx + s * w * 0.32,
        waistY + s * h * 0.34,
        cx,
        waistY + s * h * 0.34,
      )
      ..cubicTo(
        cx - s * w * 0.32,
        waistY + s * h * 0.34,
        cx - s * w / 2,
        waistY + s * h * 0.24,
        cx - s * w / 2,
        waistY,
      )
      ..close();
  }

  void _drawBody(Canvas canvas, double s) {
    final body = _blobPath(s);
    final bounds = body.getBounds();

    // Body with a soft top-light gradient for a 3D read.
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        _shade(expression.bodyColor, 0.14),
        expression.bodyColor,
        _shade(expression.bodyColor, -0.10),
      ],
      stops: const [0, 0.55, 1],
    );
    canvas.drawPath(body, Paint()..shader = gradient.createShader(bounds));
  }

  void _limb(Canvas canvas, Offset a, Offset b, double width, Color color) {
    canvas.drawLine(
      a,
      b,
      Paint()
        ..color = color
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paw(
    Canvas canvas,
    Offset center,
    double r,
    Color color, {
    double rotation = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 1.2),
      Paint()..color = color,
    );
    canvas.restore();
  }

  void _drawLimbsAndProps(Canvas canvas, double s) {
    final limbColor = _shade(expression.bodyColor, -0.18);
    final pawColor = _shade(expression.bodyColor, -0.10);
    final width = s * 0.045;

    switch (expression.pose) {
      case SlimePose.lounging:
        // One arm propped lazily up and out; legs loosely crossed.
        _limb(canvas, Offset(s * 0.62, s * 0.34), Offset(s * 0.76, s * 0.20), width, limbColor);
        _paw(canvas, Offset(s * 0.76, s * 0.20), s * 0.032, pawColor);
        _paw(canvas, Offset(s * 0.44, s * 0.82), s * 0.045, pawColor, rotation: -0.2);
        _paw(canvas, Offset(s * 0.57, s * 0.80), s * 0.045, pawColor, rotation: 0.3);
      case SlimePose.caringHold:
        // Hands clasped together at chest height.
        _limb(canvas, Offset(s * 0.36, s * 0.58), Offset(s * 0.48, s * 0.65), width, limbColor);
        _limb(canvas, Offset(s * 0.64, s * 0.58), Offset(s * 0.52, s * 0.65), width, limbColor);
        _paw(canvas, Offset(s * 0.50, s * 0.66), s * 0.038, pawColor);
        _paw(canvas, Offset(s * 0.40, s * 0.82), s * 0.04, pawColor);
        _paw(canvas, Offset(s * 0.60, s * 0.82), s * 0.04, pawColor);
      case SlimePose.bouncy:
        // Arms flung wide, feet planted for a bounce.
        _limb(canvas, Offset(s * 0.34, s * 0.50), Offset(s * 0.18, s * 0.32), width, limbColor);
        _limb(canvas, Offset(s * 0.66, s * 0.50), Offset(s * 0.82, s * 0.32), width, limbColor);
        _paw(canvas, Offset(s * 0.18, s * 0.32), s * 0.036, pawColor);
        _paw(canvas, Offset(s * 0.82, s * 0.32), s * 0.036, pawColor);
        _paw(canvas, Offset(s * 0.42, s * 0.83), s * 0.042, pawColor);
        _paw(canvas, Offset(s * 0.58, s * 0.83), s * 0.042, pawColor);
      case SlimePose.crossedArms:
        // Arms crossed tight over the chest, one foot tapping.
        _limb(canvas, Offset(s * 0.34, s * 0.52), Offset(s * 0.62, s * 0.60), width, limbColor);
        _limb(canvas, Offset(s * 0.66, s * 0.52), Offset(s * 0.38, s * 0.60), width, limbColor);
        _paw(canvas, Offset(s * 0.40, s * 0.82), s * 0.042, pawColor, rotation: -0.15);
        _paw(canvas, Offset(s * 0.59, s * 0.79), s * 0.042, pawColor, rotation: 0.35);
      case SlimePose.dapper:
        // One hand behind the back; a monocle over one eye.
        _limb(canvas, Offset(s * 0.64, s * 0.55), Offset(s * 0.70, s * 0.68), width, limbColor);
        _paw(canvas, Offset(s * 0.70, s * 0.68), s * 0.034, pawColor);
        _paw(canvas, Offset(s * 0.44, s * 0.83), s * 0.04, pawColor);
        _paw(canvas, Offset(s * 0.56, s * 0.83), s * 0.04, pawColor);
        if (expression.monocle) _drawMonocle(canvas, s);
    }
  }

  Offset _rightEyeCenter(double s) => Offset(s * 0.5 + s * 0.115, s * 0.42);

  void _drawMonocle(Canvas canvas, double s) {
    final center = _rightEyeCenter(s);
    canvas.drawCircle(
      center,
      s * 0.075,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.014
        ..color = AppColors.textPrimary,
    );
    canvas.drawLine(
      Offset(center.dx + s * 0.06, center.dy + s * 0.05),
      Offset(center.dx + s * 0.10, center.dy + s * 0.15),
      Paint()
        ..color = AppColors.textPrimary
        ..strokeWidth = s * 0.008
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Each persona's signature idle flourish, timed as a pure function of
  /// [idleT] so no particle list needs to be spawned or retired.
  void _drawParticle(Canvas canvas, double s) {
    const start = 0.5;
    const span = 0.45;
    if (idleT < start) return;
    final k = ((idleT - start) / span).clamp(0.0, 1.0);
    final fade = math.sin(k * math.pi);
    if (fade <= 0.02) return;

    switch (expression.particle) {
      case SlimeParticle.shrug:
        final pos = Offset(s * 0.72, s * 0.28 - k * s * 0.05);
        final tp = TextPainter(
          text: TextSpan(
            text: '…',
            style: TextStyle(
              color: AppColors.textMuted.withValues(alpha: fade),
              fontSize: s * 0.11,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, pos);
      case SlimeParticle.warmthWisp:
        final baseX = s * 0.30;
        final baseY = s * 0.30 - k * s * 0.20;
        final path = Path()
          ..moveTo(baseX, baseY + s * 0.06)
          ..quadraticBezierTo(baseX + s * 0.04, baseY, baseX, baseY - s * 0.05)
          ..quadraticBezierTo(
            baseX - s * 0.03,
            baseY - s * 0.09,
            baseX + s * 0.01,
            baseY - s * 0.13,
          );
        canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.012
            ..strokeCap = StrokeCap.round
            ..color = _shade(
              expression.bodyColor,
              0.25,
            ).withValues(alpha: fade * 0.8),
        );
      case SlimeParticle.spark:
        final center = Offset(s * 0.78, s * 0.24 - k * s * 0.04);
        final r = s * 0.02 + fade * s * 0.02;
        final path = Path();
        for (var i = 0; i < 4; i++) {
          final ang = i * math.pi / 2;
          path.lineTo(
            center.dx + math.cos(ang) * r * 2.1,
            center.dy + math.sin(ang) * r * 2.1,
          );
          path.quadraticBezierTo(
            center.dx,
            center.dy,
            center.dx + math.cos(ang + math.pi / 4) * r * 0.5,
            center.dy + math.sin(ang + math.pi / 4) * r * 0.5,
          );
        }
        path.close();
        canvas.drawPath(
          path,
          Paint()..color = expression.bodyColor.withValues(alpha: fade),
        );
      case SlimeParticle.steamHuff:
        // A soft cartoon "steaming mad" cue above the head — deliberately
        // not drawn at the mouth, to avoid any cigarette-smoke association
        // in a smoking-cessation app.
        final baseY = s * 0.12 - k * s * 0.10;
        final mist = _shade(
          expression.bodyColor,
          0.28,
        ).withValues(alpha: fade * 0.5);
        for (final dx in [-s * 0.05, s * 0.05]) {
          canvas.drawCircle(
            Offset(s * 0.5 + dx, baseY),
            s * 0.02 * (1 - k * 0.4),
            Paint()..color = mist,
          );
        }
      case SlimeParticle.monocleGlint:
        final center = _rightEyeCenter(s);
        canvas.drawLine(
          Offset(center.dx - s * 0.05 + k * s * 0.10, center.dy - s * 0.05),
          Offset(center.dx - s * 0.03 + k * s * 0.10, center.dy + s * 0.03),
          Paint()
            ..color = Colors.white.withValues(alpha: fade * 0.9)
            ..strokeWidth = s * 0.012
            ..strokeCap = StrokeCap.round,
        );
    }
  }

  void _drawFace(Canvas canvas, double s) {
    final dark = Paint()..color = AppColors.textPrimary;
    final eyeY = s * 0.42;
    final eyeDx = s * 0.115;
    final leftEye = Offset(s * 0.5 - eyeDx, eyeY);
    final rightEye = Offset(s * 0.5 + eyeDx, eyeY);
    final eyeW = s * 0.13;
    final eyeH = s * 0.17 * blinkOpen;

    for (final eye in [leftEye, rightEye]) {
      if (blinkOpen < 0.12) {
        // Closed: a short lid line.
        canvas.drawLine(
          Offset(eye.dx - eyeW * 0.5, eye.dy),
          Offset(eye.dx + eyeW * 0.5, eye.dy),
          Paint()
            ..color = AppColors.textPrimary
            ..strokeWidth = s * 0.02
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      // White of the eye.
      canvas.drawOval(
        Rect.fromCenter(center: eye, width: eyeW, height: eyeH),
        Paint()..color = AppColors.card,
      );
      // Pupil, drifting a little within the eye.
      final pupil = Offset(
        eye.dx + pupilDx * eyeW * 0.5,
        eye.dy + pupilDy * eyeH * 0.5,
      );
      canvas.drawCircle(pupil, s * 0.035, dark);
    }

    _drawBrows(canvas, s, leftEye, rightEye);
    _drawMouth(canvas, s);
  }

  void _drawBrows(Canvas canvas, double s, Offset leftEye, Offset rightEye) {
    final brow = Paint()
      ..color = AppColors.textPrimary
      ..strokeWidth = s * 0.022
      ..strokeCap = StrokeCap.round;
    final browW = s * 0.11;
    final browY = leftEye.dy - s * 0.14;
    final tilt = expression.browTilt * s * 0.05;

    // Left brow: inner end is toward the right.
    canvas.drawLine(
      Offset(leftEye.dx - browW * 0.5, browY - tilt * 0.4),
      Offset(leftEye.dx + browW * 0.5, browY + tilt),
      brow,
    );
    // Right brow mirrors it.
    canvas.drawLine(
      Offset(rightEye.dx - browW * 0.5, browY + tilt),
      Offset(rightEye.dx + browW * 0.5, browY - tilt * 0.4),
      brow,
    );
  }

  void _drawMouth(Canvas canvas, double s) {
    final center = Offset(s * 0.5, s * 0.62);
    final stroke = Paint()
      ..color = AppColors.textPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.028
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = AppColors.textPrimary;

    switch (expression.mouth) {
      case MascotMouth.flatLine:
        canvas.drawLine(
          Offset(center.dx - s * 0.08, center.dy),
          Offset(center.dx + s * 0.08, center.dy),
          stroke,
        );
      case MascotMouth.softSmile:
        final rect = Rect.fromCenter(
          center: Offset(center.dx, center.dy - s * 0.04),
          width: s * 0.20,
          height: s * 0.16,
        );
        canvas.drawArc(rect, 0.15, math.pi - 0.3, false, stroke);
      case MascotMouth.serene:
        final rect = Rect.fromCenter(
          center: Offset(center.dx, center.dy - s * 0.02),
          width: s * 0.14,
          height: s * 0.10,
        );
        canvas.drawArc(rect, 0.3, math.pi - 0.6, false, stroke);
      case MascotMouth.frown:
        // Upward-opening arc placed low → a downturned mouth.
        final rect = Rect.fromCenter(
          center: Offset(center.dx, center.dy + s * 0.06),
          width: s * 0.18,
          height: s * 0.14,
        );
        canvas.drawArc(rect, math.pi + 0.15, math.pi - 0.3, false, stroke);
      case MascotMouth.openGrin:
        final path = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: center,
                width: s * 0.20,
                height: s * 0.14,
              ),
              Radius.circular(s * 0.06),
            ),
          );
        canvas.drawPath(path, fill);
        // A little tongue for extra life.
        canvas.drawCircle(
          Offset(center.dx, center.dy + s * 0.03),
          s * 0.03,
          Paint()..color = AppColors.accentDeep,
        );
    }

    if (expression.mustache) _drawMustache(canvas, s, center);
  }

  /// A tidy handlebar moustache above the mouth for the gentleman.
  void _drawMustache(Canvas canvas, double s, Offset center) {
    final my = center.dy - s * 0.075;
    final half = s * 0.12;
    final path = Path()
      ..moveTo(center.dx, my)
      // Left lobe.
      ..quadraticBezierTo(
        center.dx - half * 0.5,
        my - s * 0.03,
        center.dx - half,
        my + s * 0.004,
      )
      ..quadraticBezierTo(
        center.dx - half * 0.4,
        my + s * 0.03,
        center.dx,
        my + s * 0.014,
      )
      // Right lobe (mirror).
      ..quadraticBezierTo(
        center.dx + half * 0.4,
        my + s * 0.03,
        center.dx + half,
        my + s * 0.004,
      )
      ..quadraticBezierTo(
        center.dx + half * 0.5,
        my - s * 0.03,
        center.dx,
        my,
      )
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.textPrimary);
  }

  /// Lightens ([amount] > 0) or darkens ([amount] < 0) a colour.
  Color _shade(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  @override
  bool shouldRepaint(_MascotPainter old) =>
      old.expression != expression ||
      old.blinkOpen != blinkOpen ||
      old.pupilDx != pupilDx ||
      old.pupilDy != pupilDy ||
      old.idleT != idleT;
}
