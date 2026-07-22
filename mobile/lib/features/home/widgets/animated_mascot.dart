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
  });

  final MascotExpression expression;
  final double blinkOpen;
  final double pupilDx;
  final double pupilDy;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    _drawShadow(canvas, s);
    _drawBody(canvas, s);
    _drawFace(canvas, s);
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

  void _drawBody(Canvas canvas, double s) {
    final bodyRect = Rect.fromLTRB(s * 0.24, s * 0.10, s * 0.76, s * 0.90);
    final body = RRect.fromRectAndCorners(
      bodyRect,
      topLeft: Radius.circular(s * 0.26),
      topRight: Radius.circular(s * 0.26),
      bottomLeft: Radius.circular(s * 0.14),
      bottomRight: Radius.circular(s * 0.14),
    );

    // Backpack nub for the Among-Us silhouette (slightly darker).
    final backpack = RRect.fromRectAndRadius(
      Rect.fromLTRB(s * 0.70, s * 0.40, s * 0.84, s * 0.70),
      Radius.circular(s * 0.06),
    );
    canvas.drawRRect(
      backpack,
      Paint()..color = _shade(expression.bodyColor, -0.12),
    );

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
    canvas.drawRRect(
      body,
      Paint()..shader = gradient.createShader(bodyRect),
    );
  }

  void _drawFace(Canvas canvas, double s) {
    final dark = Paint()..color = AppColors.textPrimary;
    final eyeY = s * 0.44;
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
      old.pupilDy != pupilDy;
}
