/// Optional reason tagged to a log entry.
///
/// [wireValue] matches the `triggerTag` field in the `LogEntries` table
/// (nullable in the schema; [none] represents an untagged entry).
enum TriggerTag {
  stress('stress'),
  boredom('boredom'),
  social('social'),
  afterMeal('after_meal'),
  coffee('coffee'),
  alcohol('alcohol'),
  custom('custom'),
  none('none');

  const TriggerTag(this.wireValue);

  final String wireValue;

  /// Tags offered as selectable chips in the quick-log / edit UI.
  static const List<TriggerTag> selectable = [
    TriggerTag.stress,
    TriggerTag.boredom,
    TriggerTag.social,
    TriggerTag.afterMeal,
    TriggerTag.coffee,
    TriggerTag.alcohol,
    TriggerTag.custom,
  ];

  static TriggerTag fromWire(String? value) {
    if (value == null) return TriggerTag.none;
    return TriggerTag.values.firstWhere(
      (t) => t.wireValue == value,
      orElse: () => TriggerTag.none,
    );
  }
}
