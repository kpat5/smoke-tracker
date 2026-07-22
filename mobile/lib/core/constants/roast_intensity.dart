/// How much wit the mascot applies within its chosen [Personality].
///
/// [wireValue] matches the `roastIntensity` field in the `Users` table.
enum RoastIntensity {
  mild('mild'),
  medium('medium'),
  savage('savage');

  const RoastIntensity(this.wireValue);

  final String wireValue;

  static RoastIntensity fromWire(String value) =>
      RoastIntensity.values.firstWhere(
        (r) => r.wireValue == value,
        orElse: () => RoastIntensity.medium,
      );
}
