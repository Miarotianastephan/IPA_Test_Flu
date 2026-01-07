// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

File _$FileFromJson(Map<String, dynamic> json) => File(
  id: json['id'] as String,
  name: json['name'] as String,
  url: json['url'] as String,
  type: json['type'] as String,
  size: (json['size'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  wasTranscoded: json['wasTranscoded'] as bool,
);

Map<String, dynamic> _$FileToJson(File instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'url': instance.url,
  'type': instance.type,
  'size': instance.size,
  'createdAt': instance.createdAt.toIso8601String(),
  'wasTranscoded': instance.wasTranscoded,
};
