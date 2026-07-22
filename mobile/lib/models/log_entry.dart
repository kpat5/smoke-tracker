import '../core/constants/trigger_tag.dart';

/// How an entry was created — internal analytics only.
enum CreatedVia {
  quick('quick'),
  backdated('backdated');

  const CreatedVia(this.wireValue);

  final String wireValue;

  static CreatedVia fromWire(String? value) => CreatedVia.values.firstWhere(
    (v) => v.wireValue == value,
    orElse: () => CreatedVia.quick,
  );
}

/// A single logged cigarette — mirrors the `LogEntries` table.
///
/// Immutable; JSON keys match the documented DynamoDB field names.
class LogEntry {
  const LogEntry({
    required this.logId,
    required this.userId,
    required this.occurredAt,
    required this.loggedAt,
    required this.costSnapshot,
    required this.currencySnapshot,
    this.triggerTag = TriggerTag.none,
    this.customTagLabel,
    this.note,
    this.createdVia = CreatedVia.quick,
  });

  final String logId;
  final String userId;

  /// When the user actually smoked — editable, can be backdated.
  final DateTime occurredAt;

  /// When the entry was actually recorded in the app.
  final DateTime loggedAt;

  /// Price-per-cigarette at the moment of logging (never recomputed later).
  final double costSnapshot;

  /// Currency symbol captured alongside [costSnapshot].
  final String currencySnapshot;

  final TriggerTag triggerTag;

  /// Only meaningful when [triggerTag] is [TriggerTag.custom].
  final String? customTagLabel;

  final String? note;
  final CreatedVia createdVia;

  LogEntry copyWith({
    DateTime? occurredAt,
    double? costSnapshot,
    String? currencySnapshot,
    TriggerTag? triggerTag,
    String? customTagLabel,
    bool clearCustomTagLabel = false,
    String? note,
    bool clearNote = false,
    CreatedVia? createdVia,
  }) {
    return LogEntry(
      logId: logId,
      userId: userId,
      occurredAt: occurredAt ?? this.occurredAt,
      loggedAt: loggedAt,
      costSnapshot: costSnapshot ?? this.costSnapshot,
      currencySnapshot: currencySnapshot ?? this.currencySnapshot,
      triggerTag: triggerTag ?? this.triggerTag,
      customTagLabel:
          clearCustomTagLabel ? null : (customTagLabel ?? this.customTagLabel),
      note: clearNote ? null : (note ?? this.note),
      createdVia: createdVia ?? this.createdVia,
    );
  }

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      logId: json['logId'] as String,
      userId: json['userId'] as String,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      loggedAt: DateTime.parse(json['loggedAt'] as String),
      costSnapshot: (json['costSnapshot'] as num).toDouble(),
      currencySnapshot: json['currencySnapshot'] as String,
      triggerTag: TriggerTag.fromWire(json['triggerTag'] as String?),
      customTagLabel: json['customTagLabel'] as String?,
      note: json['note'] as String?,
      createdVia: CreatedVia.fromWire(json['createdVia'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logId': logId,
      'userId': userId,
      'occurredAt': occurredAt.toIso8601String(),
      'loggedAt': loggedAt.toIso8601String(),
      'costSnapshot': costSnapshot,
      'currencySnapshot': currencySnapshot,
      'triggerTag': triggerTag == TriggerTag.none ? null : triggerTag.wireValue,
      'customTagLabel': customTagLabel,
      'note': note,
      'createdVia': createdVia.wireValue,
    };
  }
}
