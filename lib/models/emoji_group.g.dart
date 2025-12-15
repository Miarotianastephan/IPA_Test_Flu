// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emoji_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmojiGroup _$EmojiGroupFromJson(Map<String, dynamic> json) => EmojiGroup(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  price: json['price'] as String,
  isPremium: json['is_premium'] as bool,
);

Map<String, dynamic> _$EmojiGroupToJson(EmojiGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'is_premium': instance.isPremium,
    };
