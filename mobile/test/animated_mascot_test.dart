import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/constants/personality.dart';
import 'package:mobile/features/home/widgets/animated_mascot.dart';

void main() {
  Widget wrap(Widget child, {bool disableAnimations = false}) {
    return MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Center(child: child),
      ),
    );
  }

  testWidgets('builds for every personality without throwing', (tester) async {
    for (final personality in Personality.values) {
      await tester.pumpWidget(
        wrap(AnimatedMascot(personality: personality, count: 3)),
      );
      expect(find.byType(AnimatedMascot), findsOneWidget);
      // Let a couple of idle frames run.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('holds static (settles) under reduce-motion', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AnimatedMascot(personality: Personality.irritable, count: 0),
        disableAnimations: true,
      ),
    );
    // With no repeating controller there are no pending timers, so this
    // completes instead of timing out.
    await tester.pumpAndSettle();
    expect(find.byType(AnimatedMascot), findsOneWidget);
  });

  testWidgets('reacts to a count increase without throwing', (tester) async {
    await tester.pumpWidget(
      wrap(const AnimatedMascot(personality: Personality.caring, count: 3)),
    );
    await tester.pumpWidget(
      wrap(const AnimatedMascot(personality: Personality.caring, count: 4)),
    );
    await tester.pump(const Duration(milliseconds: 260));
    expect(tester.takeException(), isNull);
  });
}
