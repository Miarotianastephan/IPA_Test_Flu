import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'time_package.g.dart';

/// Represents a time package for short video viewing
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class TimePackage {
  @JsonKey(fromJson: parseInt)
  final int id;

  /// Time duration in minutes (e.g., 30, 60, 180)
  @JsonKey(fromJson: parseInt, name: 'duration_seconds')
  final int durationSeconds;

  /// Package price in base currency (RMB)
  @JsonKey(fromJson: parseDouble, name: 'price')
  final double price;

  /// Currency code
  @JsonKey(name: 'currency')
  final String currency;

  /// Whether this is a daily pass (unlimited time until midnight)
  @JsonKey(defaultValue: false, fromJson: parseBool, name: 'is_daily_pass')
  final bool isDailyPass;

  /// Whether this package is popular/recommended
  @JsonKey(defaultValue: false, fromJson: parseBool, name: 'is_popular')
  final bool isPopular;

  /// Display label (e.g., "Most Popular", "Best Value")
  @JsonKey(name: 'label')
  final String? label;

  /// Sort order for display
  @JsonKey(defaultValue: 0, fromJson: parseInt, name: 'sort_order')
  final int sortOrder;

  /// Associated agent ID
  @JsonKey(fromJson: parseInt, name: 'agent_id')
  final int agentId;

  /// Whether this package is currently active
  @JsonKey(defaultValue: true, fromJson: parseBool, name: 'is_active')
  final bool isActive;

  /// Price per second (calculated)
  double get pricePerSecond => isDailyPass ? 0 : price / durationSeconds;

  /// Price per minute (calculated)
  double get pricePerMinute => isDailyPass ? 0 : price / (durationSeconds / 60);

  /// Display duration text
  String get durationText {
    if (isDailyPass) return 'Daily Pass';
    final totalMinutes = durationSeconds ~/ 60;
    if (totalMinutes >= 60) {
      final hours = totalMinutes ~/ 60;
      final mins = totalMinutes % 60;
      if (mins == 0) return '${hours}h';
      return '${hours}h ${mins}m';
    }
    return '${totalMinutes}m';
  }

  TimePackage({
    required this.id,
    required this.durationSeconds,
    required this.price,
    required this.currency,
    this.isDailyPass = false,
    this.isPopular = false,
    this.label,
    this.sortOrder = 0,
    required this.agentId,
    this.isActive = true,
  });

  factory TimePackage.fromJson(Map<String, dynamic> json) =>
      _$TimePackageFromJson(json);

  Map<String, dynamic> toJson() => _$TimePackageToJson(this);

  TimePackage copyWith({
    int? id,
    int? durationSeconds,
    double? price,
    String? currency,
    bool? isDailyPass,
    bool? isPopular,
    String? label,
    int? sortOrder,
    int? agentId,
    bool? isActive,
  }) {
    return TimePackage(
      id: id ?? this.id,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      isDailyPass: isDailyPass ?? this.isDailyPass,
      isPopular: isPopular ?? this.isPopular,
      label: label ?? this.label,
      sortOrder: sortOrder ?? this.sortOrder,
      agentId: agentId ?? this.agentId,
      isActive: isActive ?? this.isActive,
    );
  }
}
