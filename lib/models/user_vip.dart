import 'package:json_annotation/json_annotation.dart';
import 'vip_level.dart';

part 'user_vip.g.dart';

/// User VIP subscription status
enum UserVipStatus {
  @JsonValue('active')
  active,

  @JsonValue('expired')
  expired,

  @JsonValue('cancelled')
  cancelled,
}

/// User's VIP subscription record
@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class UserVip {
  /// User VIP record ID
  final int id;

  /// User ID
  final String userId;

  /// VIP level ID
  final int vipLevelId;

  /// VIP level details
  final VipLevel vipLevel;

  /// Subscription status
  @JsonKey(defaultValue: UserVipStatus.active)
  final UserVipStatus status;

  /// Start date of subscription
  final DateTime startDate;

  /// End date of subscription
  final DateTime endDate;

  /// Payment order ID (if purchased)
  final int? orderId;

  /// Created timestamp
  final DateTime createdAt;

  /// Updated timestamp
  final DateTime updatedAt;

  UserVip({
    required this.id,
    required this.userId,
    required this.vipLevelId,
    required this.vipLevel,
    this.status = UserVipStatus.active,
    required this.startDate,
    required this.endDate,
    this.orderId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserVip.fromJson(Map<String, dynamic> json) =>
      _$UserVipFromJson(json);

  Map<String, dynamic> toJson() => _$UserVipToJson(this);

  /// Check if VIP is currently active
  bool get isActive {
    if (status != UserVipStatus.active) return false;
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if VIP has expired
  bool get isExpired {
    return status == UserVipStatus.expired || DateTime.now().isAfter(endDate);
  }

  /// Days remaining until expiration
  int get daysRemaining {
    if (isExpired) return 0;
    final now = DateTime.now();
    return endDate.difference(now).inDays;
  }

  /// Hours remaining until expiration
  int get hoursRemaining {
    if (isExpired) return 0;
    final now = DateTime.now();
    return endDate.difference(now).inHours;
  }

  /// Get expiration status text
  String get expirationText {
    if (isExpired) return 'Expired';

    final days = daysRemaining;
    if (days > 1) {
      return 'Expires in $days days';
    } else if (days == 1) {
      return 'Expires tomorrow';
    } else {
      final hours = hoursRemaining;
      return 'Expires in $hours hours';
    }
  }

  UserVip copyWith({
    int? id,
    String? userId,
    int? vipLevelId,
    VipLevel? vipLevel,
    UserVipStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int? orderId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserVip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vipLevelId: vipLevelId ?? this.vipLevelId,
      vipLevel: vipLevel ?? this.vipLevel,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      orderId: orderId ?? this.orderId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
