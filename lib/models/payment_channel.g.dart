// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentChannel _$PaymentChannelFromJson(Map<String, dynamic> json) =>
    PaymentChannel(
      id: parseInt(json['id']),
      platformId: parseInt(json['platformId']),
      channelCode: json['channelCode'] as String,
      name: json['name'] as String,
      i18nKey: json['i18nKey'] as String?,
      minAmount: parseDouble(json['minAmount']),
      maxAmount: parseDouble(json['maxAmount']),
      currency: json['currency'] as String?,
      countryCodes:
          (json['countryCodes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      sort: json['sort'] == null ? 0 : parseInt(json['sort']),
      status:
          $enumDecodeNullable(_$PaymentChannelStatusEnumMap, json['status']) ??
          PaymentChannelStatus.inactive,
      icon: json['icon'] as String?,
      config: json['config'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      deletedAt: json['deletedAt'] == null
          ? null
          : DateTime.parse(json['deletedAt'] as String),
    );

Map<String, dynamic> _$PaymentChannelToJson(PaymentChannel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'platformId': instance.platformId,
      'channelCode': instance.channelCode,
      'name': instance.name,
      'i18nKey': instance.i18nKey,
      'minAmount': instance.minAmount,
      'maxAmount': instance.maxAmount,
      'currency': instance.currency,
      'countryCodes': instance.countryCodes,
      'sort': instance.sort,
      'status': _$PaymentChannelStatusEnumMap[instance.status]!,
      'icon': instance.icon,
      'config': instance.config,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'deletedAt': instance.deletedAt?.toIso8601String(),
    };

const _$PaymentChannelStatusEnumMap = {
  PaymentChannelStatus.active: 'active',
  PaymentChannelStatus.inactive: 'inactive',
};
