import 'package:uuid/uuid.dart';

import '../../core/constants/personality.dart';
import '../../core/constants/roast_intensity.dart';
import '../../core/constants/trigger_tag.dart';
import '../../models/log_entry.dart';
import '../../models/user_profile.dart';

/// Stand-in user id used until Cognito auth is wired up.
const String mockUserId = 'mock-user';

const _uuid = Uuid();

/// Default profile seeded before onboarding exists.
///
/// packPrice 300 / 20 per pack ⇒ ₹15 per cigarette, matching the mockup.
UserProfile buildSeedProfile({DateTime? now}) {
  final current = now ?? DateTime.now();
  return UserProfile(
    currencyCode: 'INR',
    currencySymbol: '₹',
    packPrice: 300,
    cigarettesPerPack: 20,
    personality: Personality.excited,
    roastIntensity: RoastIntensity.medium,
    timezone: 'Asia/Kolkata',
    createdAt: current.subtract(const Duration(days: 30)),
  );
}

// (dayOffset from today, hour, minute, trigger) — 3 logs/day across a week.
// Totals: 21 logs, and by-trigger counts matching the Stats mockup
// (stress 4, social 4, coffee 4, boredom 3, after-meal 3, alcohol 3).
const List<(int, int, int, TriggerTag)> _schedule = [
  (0, 9, 3, TriggerTag.social),
  (0, 14, 3, TriggerTag.stress),
  (0, 16, 33, TriggerTag.coffee),
  (1, 10, 0, TriggerTag.coffee),
  (1, 16, 3, TriggerTag.boredom),
  (1, 20, 0, TriggerTag.alcohol),
  (2, 9, 0, TriggerTag.afterMeal),
  (2, 13, 0, TriggerTag.stress),
  (2, 18, 0, TriggerTag.social),
  (3, 8, 30, TriggerTag.coffee),
  (3, 15, 0, TriggerTag.boredom),
  (3, 21, 0, TriggerTag.alcohol),
  (4, 9, 0, TriggerTag.afterMeal),
  (4, 12, 0, TriggerTag.social),
  (4, 19, 0, TriggerTag.stress),
  (5, 10, 0, TriggerTag.coffee),
  (5, 14, 0, TriggerTag.boredom),
  (5, 22, 0, TriggerTag.alcohol),
  (6, 9, 0, TriggerTag.afterMeal),
  (6, 13, 0, TriggerTag.social),
  (6, 17, 0, TriggerTag.stress),
];

/// Seed log entries spread over the past week so Home/Entries/Stats are
/// populated on first launch.
List<LogEntry> buildSeedLogs(UserProfile profile, {DateTime? now}) {
  final current = now ?? DateTime.now();
  final startOfToday =
      DateTime(current.year, current.month, current.day);
  final cost = profile.costPerCigarette;

  return _schedule.map((row) {
    final (dayOffset, hour, minute, tag) = row;
    final occurredAt = startOfToday
        .subtract(Duration(days: dayOffset))
        .add(Duration(hours: hour, minutes: minute));
    return LogEntry(
      logId: _uuid.v4(),
      userId: mockUserId,
      occurredAt: occurredAt,
      loggedAt: occurredAt,
      costSnapshot: cost,
      currencySnapshot: profile.currencySymbol,
      triggerTag: tag,
      createdVia: CreatedVia.quick,
    );
  }).toList();
}
