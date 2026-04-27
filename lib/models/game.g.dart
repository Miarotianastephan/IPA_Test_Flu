// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game(
  platType: json['platType'] as String,
  gameType: json['gameType'] as String,
  gameCode: json['gameCode'] as String,
  ingress: json['ingress'] as String,
  gameName: json['gameName'] as String,
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'platType': instance.platType,
  'gameType': instance.gameType,
  'gameCode': instance.gameCode,
  'ingress': instance.ingress,
  'gameName': instance.gameName,
};
