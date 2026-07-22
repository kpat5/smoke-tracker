/// The selectable mascot personalities. Each is a named character with its own
/// voice and look:
///   - [nonchalant] — "Ash": aloof, unbothered, doesn't care either way.
///   - [caring]     — "Ember": kind, warm-hearted and a little shy.
///   - [excited]    — "Blaze": all enthusiasm, loses the thread mid-sentence.
///   - [irritable]  — "Cinder": curt and rude, cares vanishingly little.
///   - [gentleman]  — "Winston": polite, impeccable grammar, dryly witty.
///
/// [wireValue] is the string persisted in the `Users` table (`personality`
/// field) and sent over the wire.
enum Personality {
  nonchalant('nonchalant'),
  caring('caring'),
  excited('excited'),
  irritable('irritable'),
  gentleman('gentleman');

  const Personality(this.wireValue);

  final String wireValue;

  static Personality fromWire(String value) => Personality.values.firstWhere(
    (p) => p.wireValue == value,
    orElse: () => Personality.nonchalant,
  );
}
