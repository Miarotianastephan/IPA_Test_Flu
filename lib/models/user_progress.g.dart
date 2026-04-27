// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProgress _$UserProgressFromJson(Map<String, dynamic> json) => UserProgress(
  id: parseInt(json['id']),
  campaignId: parseInt(json['campaign_id']),
  userId: json['user_id'] as String,
  progressAmount: json['progress_amount'] as String,
  firstPayDone: json['first_pay_done'] as bool,
  firstPayOrderId: json['first_pay_order_id'] as String?,
  version: parseInt(json['version']),
  updatedAt: json['updated_at'] as String,
);

Map<String, dynamic> _$UserProgressToJson(UserProgress instance) =>
    <String, dynamic>{
      'id': instance.id,
      'campaign_id': instance.campaignId,
      'user_id': instance.userId,
      'progress_amount': instance.progressAmount,
      'first_pay_done': instance.firstPayDone,
      'first_pay_order_id': instance.firstPayOrderId,
      'version': instance.version,
      'updated_at': instance.updatedAt,
    };
