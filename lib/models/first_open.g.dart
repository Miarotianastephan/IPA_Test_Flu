// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'first_open.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirstOpen _$FirstOpenFromJson(Map<String, dynamic> json) => FirstOpen(
  attributed: json['attributed'] as bool?,
  clickId: json['click_id'] as String?,
  method: json['method'] as String?,
  confidence: (json['confidence'] as num?)?.toInt(),
  idFirstOpen: (json['id_first_open'] as num?)?.toInt(),
  userId: json['user_id'] as String?,
);

Map<String, dynamic> _$FirstOpenToJson(FirstOpen instance) => <String, dynamic>{
  'attributed': instance.attributed,
  'click_id': instance.clickId,
  'method': instance.method,
  'confidence': instance.confidence,
  'id_first_open': instance.idFirstOpen,
  'user_id': instance.userId,
};
