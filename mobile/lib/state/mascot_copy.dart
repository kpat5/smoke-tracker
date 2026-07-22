import '../core/constants/personality.dart';
import '../core/constants/roast_intensity.dart';

/// The situation the mascot is reacting to on Home.
enum MascotScenario { zeroToday, someToday, manyToday }

/// The mascot copy bank and the line-selection logic.
///
/// This is content selected by logic (personality × scenario), not fixed UI
/// chrome, which is why it lives here as a structured, localization-ready map
/// rather than in the `.arb` files (gen-l10n is awkward for randomly-picked
/// arrays of lines). Lines are templates: the `{count}` token is interpolated,
/// so there are no hardcoded numbers baked into the copy.
///
/// Per the neutral-stance rule, no line ever judges smoking more or less — it
/// only reacts to the number.
abstract final class MascotCopy {
  const MascotCopy._();

  /// Picks a line for Home based on today's [count].
  ///
  /// [intensity] nudges which line is chosen so changing the roast slider in
  /// Settings produces visibly different copy.
  static String homeLine({
    required Personality personality,
    required RoastIntensity intensity,
    required int count,
  }) {
    final scenario = scenarioFor(count);
    final lines = _bank[personality]![scenario]!;
    final index = (count + intensity.index) % lines.length;
    return lines[index].replaceAll('{count}', '$count');
  }

  /// Buckets today's [count] into the scenario the mascot reacts to. Shared by
  /// the copy selection and the mascot's expression/idle energy.
  static MascotScenario scenarioFor(int count) {
    if (count == 0) return MascotScenario.zeroToday;
    if (count >= 10) return MascotScenario.manyToday;
    return MascotScenario.someToday;
  }

  static const Map<Personality, Map<MascotScenario, List<String>>> _bank = {
    // Ash — nonchalant. Extra lines; maximally unbothered.
    Personality.nonchalant: {
      MascotScenario.zeroToday: [
        "Zero. Or not. Whatever works.",
        "Nothing logged. I'm not fussed either way.",
        "Empty. Cool. Or not cool. Hard to care.",
        "Still zero. Anyway.",
        "No logs yet. Sure. Fine. Exists, I guess.",
      ],
      MascotScenario.someToday: [
        "{count}. Sure. Whatever.",
        "That's {count}, I guess. Not that it matters.",
        "{count} logged. Cool story.",
        "Oh. {count}. Neat. Or not. Meh.",
        "{count}. Noted. Barely.",
      ],
      MascotScenario.manyToday: [
        "{count}. Huh. Anyway.",
        "{count} today. I'd react but... effort.",
        "That's {count}. And? Moving on.",
        "{count}. Wild. Or normal. Couldn't tell you.",
        "{count} logged. Cool. Whatever this is.",
      ],
    },
    // Ember — caring and shy.
    Personality.caring: {
      MascotScenario.zeroToday: [
        "Nothing yet... and that's totally okay, no pressure.",
        "A quiet start. I'm just really glad you're here.",
        "Zero so far. Take all the time you need, honestly.",
      ],
      MascotScenario.someToday: [
        "{count} logged. Thank you for telling me, truly.",
        "Oh, {count}. I hope you're being gentle with yourself today.",
        "That's {count}. I'm right here either way, okay?",
      ],
      MascotScenario.manyToday: [
        "{count} today. Um... I just want you to know I'm around.",
        "{count}. However your day is going, I'm quietly rooting for you.",
        "That's {count}. Sending you a little kindness. Softly.",
      ],
    },
    // Blaze — excited, loses the thread mid-sentence.
    Personality.excited: {
      MascotScenario.zeroToday: [
        "ZERO!! A totally blank day and honestly?! THRILLING!!",
        "Nothing yet and ANYTHING could happen!! I love when— wait—",
        "Zero logs!! A FRESH START!! I love fresh— sorry, got excited.",
      ],
      MascotScenario.someToday: [
        "{count}!!! WE'RE DOING NUMBERS!! This is the best— what was I—",
        "OH IT'S {count}!! Amazing!! Incredible!! I forgot my point!!",
        "{count}?!! LET'S GOOO!! Wait— going where— doesn't matter, {count}!!",
      ],
      MascotScenario.manyToday: [
        "{count}!!! DOUBLE DIGITS!! I'm SO— hold on, I lost it—",
        "WHOA, {count}!! That is SO MANY!! I'm too excited to— what?",
        "{count} TODAY?!! Somebody get a BANNER!! Or a— I forgot!!",
      ],
    },
    // Cinder — angry and irritated, cares very little.
    Personality.irritable: {
      MascotScenario.zeroToday: [
        "Zero. Great. Can I go now?",
        "Nothing logged. Don't make me say more.",
        "Empty. Thrilled. Obviously.",
      ],
      MascotScenario.someToday: [
        "{count}. There. Happy?",
        "It's {count}. Was that worth interrupting me for?",
        "{count}. Ugh. Fine. Noted.",
      ],
      MascotScenario.manyToday: [
        "{count}. Yeah. And? Leave it.",
        "{count} today. Stop looking at me.",
        "It's {count}. Wow. Amazing. Whatever.",
      ],
    },
    // Winston — classy gentleman, impeccable grammar, dry wit.
    Personality.gentleman: {
      MascotScenario.zeroToday: [
        "Nothing as yet. A blank ledger has its own quiet dignity.",
        "Zero entries. We begin, as always, impeccably.",
        "The tally stands at nil. Splendidly uneventful.",
      ],
      MascotScenario.someToday: [
        "{count} thus far. Duly and elegantly recorded.",
        "Ah, {count}. A most respectable figure to report.",
        "That would be {count}. Noted with the utmost precision.",
      ],
      MascotScenario.manyToday: [
        "{count} today — a positively bustling ledger, if I may say.",
        "We have reached {count}. One does keep marvellous records.",
        "{count}, precisely. The numbers are, as ever, in fine order.",
      ],
    },
  };
}
