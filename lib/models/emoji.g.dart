// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Emoji _$EmojiFromJson(Map<String, dynamic> json) => Emoji(
  id: (json['id'] as num).toInt(),
  code: json['code'] as String,
  url: json['url'] as String,
  type: (json['type'] as num).toInt(),
  status: (json['status'] as num).toInt(),
  group: EmojiGroup.fromJson(json['group'] as Map<String, dynamic>),
  purchased: json['purchased'] as bool,
);

Map<String, dynamic> _$EmojiToJson(Emoji instance) => <String, dynamic>{
  'id': instance.id,
  'code': instance.code,
  'url': instance.url,
  'type': instance.type,
  'status': instance.status,
  'group': instance.group.toJson(),
  'purchased': instance.purchased,
};
