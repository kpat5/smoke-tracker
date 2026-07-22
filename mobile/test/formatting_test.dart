import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/formatting.dart';

void main() {
  group('Formatting.cost', () {
    test('whole amounts render without decimals', () {
      expect(Formatting.cost(45, '₹'), '₹45');
      expect(Formatting.cost(315, '₹'), '₹315');
    });

    test('fractional amounts keep up to two decimals', () {
      expect(Formatting.cost(4.5, r'$'), r'$4.5');
      expect(Formatting.cost(4.25, r'$'), r'$4.25');
    });
  });

  group('Formatting.entryTimestamp', () {
    final now = DateTime(2026, 7, 20, 18, 0);

    // DateFormat.jm() separates the time from AM/PM with a narrow no-break
    // space; normalize to a plain space so assertions stay readable.
    String norm(String s) => s.replaceAll(RegExp(r'\s'), ' ');

    test('today shows time only', () {
      final occurred = DateTime(2026, 7, 20, 16, 33);
      expect(
        norm(Formatting.entryTimestamp(occurred,
            yesterdayLabel: 'Yesterday', now: now)),
        '4:33 PM',
      );
    });

    test('yesterday is prefixed with the localized label', () {
      final occurred = DateTime(2026, 7, 19, 16, 3);
      expect(
        norm(Formatting.entryTimestamp(occurred,
            yesterdayLabel: 'Yesterday', now: now)),
        'Yesterday, 4:03 PM',
      );
    });

    test('older dates include the month and day', () {
      final occurred = DateTime(2026, 7, 18, 16, 3);
      final result = Formatting.entryTimestamp(
        occurred,
        yesterdayLabel: 'Yesterday',
        now: now,
      );
      expect(result.contains('Jul 18'), isTrue);
    });
  });
}
