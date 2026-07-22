import '../core/constants/personality.dart';
import '../core/constants/roast_intensity.dart';

/// The user's profile — mirrors the `Users` table in the backend schema.
///
/// Immutable; use [copyWith] to derive updated copies. JSON keys match the
/// documented DynamoDB field names so the future HTTP repository can map
/// directly with no translation layer.
class UserProfile {
  const UserProfile({
    required this.currencyCode,
    required this.currencySymbol,
    required this.packPrice,
    required this.cigarettesPerPack,
    required this.personality,
    required this.roastIntensity,
    required this.timezone,
    required this.createdAt,
  });

  final String currencyCode;
  final String currencySymbol;
  final double packPrice;
  final int cigarettesPerPack;
  final Personality personality;
  final RoastIntensity roastIntensity;
  final String timezone;
  final DateTime createdAt;

  /// Current price of a single cigarette, used to snapshot cost at log time.
  double get costPerCigarette =>
      cigarettesPerPack == 0 ? 0 : packPrice / cigarettesPerPack;

  UserProfile copyWith({
    String? currencyCode,
    String? currencySymbol,
    double? packPrice,
    int? cigarettesPerPack,
    Personality? personality,
    RoastIntensity? roastIntensity,
    String? timezone,
    DateTime? createdAt,
  }) {
    return UserProfile(
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      packPrice: packPrice ?? this.packPrice,
      cigarettesPerPack: cigarettesPerPack ?? this.cigarettesPerPack,
      personality: personality ?? this.personality,
      roastIntensity: roastIntensity ?? this.roastIntensity,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      currencyCode: json['currencyCode'] as String,
      currencySymbol: json['currencySymbol'] as String,
      packPrice: (json['packPrice'] as num).toDouble(),
      cigarettesPerPack: (json['cigarettesPerPack'] as num).toInt(),
      personality: Personality.fromWire(json['personality'] as String),
      roastIntensity: RoastIntensity.fromWire(json['roastIntensity'] as String),
      timezone: json['timezone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currencyCode': currencyCode,
      'currencySymbol': currencySymbol,
      'packPrice': packPrice,
      'cigarettesPerPack': cigarettesPerPack,
      'personality': personality.wireValue,
      'roastIntensity': roastIntensity.wireValue,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
