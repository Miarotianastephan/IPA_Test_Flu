// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_reduction_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameReductionData _$GameReductionDataFromJson(Map<String, dynamic> json) =>
    GameReductionData(
      id: (json['id'] as num?)?.toInt(),
      startDate: json['start_date'] == null
          ? null
          : DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      reduction: json['reduction'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      time: parseInt(json['time']),
    );

Map<String, dynamic> _$GameReductionDataToJson(GameReductionData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'start_date': instance.startDate?.toIso8601String(),
      'end_date': instance.endDate?.toIso8601String(),
      'reduction': instance.reduction,
      'title': instance.title,
      'description': instance.description,
      'icon': instance.icon,
      'time': instance.time,
    };

GameReductionResponse _$GameReductionResponseFromJson(
  Map<String, dynamic> json,
) => GameReductionResponse(
  gameReduction: json['gameReduction'] == null
      ? null
      : GameReductionData.fromJson(
          json['gameReduction'] as Map<String, dynamic>,
        ),
  hasReduction: json['hasReduction'] as bool? ?? false,
);

Map<String, dynamic> _$GameReductionResponseToJson(
  GameReductionResponse instance,
) => <String, dynamic>{
  'gameReduction': instance.gameReduction,
  'hasReduction': instance.hasReduction,
};

UserGameReduction _$UserGameReductionFromJson(Map<String, dynamic> json) =>
    UserGameReduction(
      id: (json['id'] as num?)?.toInt(),
      userId: json['user_id'] as String?,
      gameReductionId: (json['game_reduction_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$UserGameReductionToJson(UserGameReduction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'game_reduction_id': instance.gameReductionId,
    };
