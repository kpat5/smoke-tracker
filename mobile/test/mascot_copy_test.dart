import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/personality.dart';
import 'package:mobile/core/constants/roast_intensity.dart';
import 'package:mobile/state/mascot_copy.dart';

void main() {
  group('MascotCopy.homeLine', () {
    test('returns a non-empty line for every personality and scenario', () {
      for (final personality in Personality.values) {
        for (final intensity in RoastIntensity.values) {
          for (final count in [0, 3, 12]) {
            final line = MascotCopy.homeLine(
              personality: personality,
              intensity: intensity,
              count: count,
            );
            expect(line, isNotEmpty);
            // No template token should leak into the rendered line.
            expect(line.contains('{count}'), isFalse);
          }
        }
      }
    });

    test('interpolates the count when the template uses it', () {
      final line = MascotCopy.homeLine(
        personality: Personality.excited,
        intensity: RoastIntensity.mild,
        count: 7,
      );
      expect(line.contains('7'), isTrue);
    });
  });
}
