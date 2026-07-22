import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/app.dart';

void main() {
  testWidgets('tapping "I just smoked" increments today\'s count', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: SmokeTrackerApp()));
    // The mascot idles forever, so pumpAndSettle would hang — advance with
    // fixed pumps instead to let the async mock providers resolve.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    // Seed data logs 3 entries for today.
    expect(find.text('3'), findsOneWidget);

    await tester.tap(find.text('I just smoked'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // One more log ⇒ today's count becomes 4.
    expect(find.text('4'), findsOneWidget);
  });
}
