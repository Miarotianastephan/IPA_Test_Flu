import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'vip_level.g.dart';

/// VIP subscription level/tier configuration
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class VipLevel {
  /// VIP level ID
  final int id;

  /// Level name (e.g., "VIP Gold", "VIP Diamond")
  final String name;

  /// Duration in days
  @JsonKey(fromJson: parseInt)
  final int durationDays;

  /// Price for this VIP level
  @JsonKey(fromJson: parseDouble)
  final double price;

  /// Discount rate (0.0 - 1.0, e.g., 0.20 = 20% discount)
  @JsonKey(fromJson: parseDouble)
  final double discountRate;

  /// List of benefits/features
  final List<String> benefits;

  /// Display order/priority
  @JsonKey(defaultValue: 0, fromJson: parseInt)
  final int displayOrder;

  /// Whether this level is active
  @JsonKey(defaultValue: true, fromJson: parseBool)
  final bool isActive;

  /// Badge icon URL (optional)
  final String? badgeIcon;

  /// Background color hex code (optional)
  final String? backgroundColor;

  /// Created timestamp
  final DateTime createdAt;

  /// Updated timestamp
  final DateTime updatedAt;

  VipLevel({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
    required this.discountRate,
    required this.benefits,
    this.displayOrder = 0,
    this.isActive = true,
    this.badgeIcon,
    this.backgroundColor,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VipLevel.fromJson(Map<String, dynamic> json) =>
      _$VipLevelFromJson(json);

  Map<String, dynamic> toJson() => _$VipLevelToJson(this);

  /// Get duration in human-readable format
  String get durationText {
    if (durationDays >= 365) {
      final years = (durationDays / 365).floor();
      return '$years ${years == 1 ? 'Year' : 'Years'}';
    } else if (durationDays >= 30) {
      final months = (durationDays / 30).floor();
      return '$months ${months == 1 ? 'Month' : 'Months'}';
    } else {
      return '$durationDays ${durationDays == 1 ? 'Day' : 'Days'}';
    }
  }

  /// Get discount percentage (e.g., 20%)
  int get discountPercentage => (discountRate * 100).round();

  VipLevel copyWith({
    int? id,
    String? name,
    int? durationDays,
    double? price,
    double? discountRate,
    List<String>? benefits,
    int? displayOrder,
    bool? isActive,
    String? badgeIcon,
    String? backgroundColor,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VipLevel(
      id: id ?? this.id,
      name: name ?? this.name,
      durationDays: durationDays ?? this.durationDays,
      price: price ?? this.price,
      discountRate: discountRate ?? this.discountRate,
      benefits: benefits ?? this.benefits,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      badgeIcon: badgeIcon ?? this.badgeIcon,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
