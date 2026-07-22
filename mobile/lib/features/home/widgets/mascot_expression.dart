import 'package:flutter/material.dart';

import '../../../core/constants/personality.dart';
import '../../../core/theme/app_colors.dart';

/// Mouth shapes the mascot can wear. Rendered by the painter in
/// `animated_mascot.dart`.
enum MascotMouth { flatLine, openGrin, softSmile, serene, frown }

/// The per-personality visual identity of the mascot: body colour, mouth shape,
/// brow tilt, idle liveliness and optional accessories. Centralizing this here
/// keeps tuning values out of the painter body (no scattered magic constants)
/// and makes each character visibly distinct.
class MascotExpression {
  const MascotExpression({
    required this.bodyColor,
    required this.mouth,
    required this.browTilt,
    required this.baseEnergy,
    this.mustache = false,
  });

  /// Fill colour of the character's body.
  final Color bodyColor;

  final MascotMouth mouth;

  /// Inner-end vertical tilt of the brows, roughly -1..1.
  /// Negative raises the inner ends (friendly/relaxed); positive lowers them
  /// (intense/angry); 0 is flat.
  final double browTilt;

  /// Baseline idle liveliness, 0..1 — scales bob amplitude and blink rate.
  final double baseEnergy;

  /// Whether to draw a gentleman's moustache (Winston).
  final bool mustache;

  static MascotExpression of(Personality personality) => _map[personality]!;

  // Character body colours, named so they stay out of the painter.
  static const Color _ashSlate = Color(0xFF8E9AA3); // cool, detached
  static const Color _emberCoral = Color(0xFFE68A6B); // warm, kind
  static const Color _cinderRed = Color(0xFFB94A2E); // hot, irritable
  static const Color _winstonGold = Color(0xFFB8944E); // refined

  static const Map<Personality, MascotExpression> _map = {
    // Ash — nonchalant: flat face, barely moves.
    Personality.nonchalant: MascotExpression(
      bodyColor: _ashSlate,
      mouth: MascotMouth.flatLine,
      browTilt: 0.0,
      baseEnergy: 0.2,
    ),
    // Ember — caring & shy: soft smile, gentle raised brows.
    Personality.caring: MascotExpression(
      bodyColor: _emberCoral,
      mouth: MascotMouth.softSmile,
      browTilt: -0.5,
      baseEnergy: 0.5,
    ),
    // Blaze — excited: big open grin, high brows, maximum bounce.
    Personality.excited: MascotExpression(
      bodyColor: AppColors.accent,
      mouth: MascotMouth.openGrin,
      browTilt: -0.7,
      baseEnergy: 1.0,
    ),
    // Cinder — angry & irritated: frown, furrowed brows.
    Personality.irritable: MascotExpression(
      bodyColor: _cinderRed,
      mouth: MascotMouth.frown,
      browTilt: 1.0,
      baseEnergy: 0.45,
    ),
    // Winston — classy gentleman: composed, moustachioed.
    Personality.gentleman: MascotExpression(
      bodyColor: _winstonGold,
      mouth: MascotMouth.serene,
      browTilt: -0.1,
      baseEnergy: 0.35,
      mustache: true,
    ),
  };
}
