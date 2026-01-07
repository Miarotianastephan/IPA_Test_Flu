// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionResponse _$VersionResponseFromJson(Map<String, dynamic> json) =>
    VersionResponse(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
      data: json['data'] == null
          ? null
          : Version.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$VersionResponseToJson(VersionResponse instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
      'data': instance.data,
    };
