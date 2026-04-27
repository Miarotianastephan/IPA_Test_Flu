import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'game_reduction_model.g.dart';

@JsonSerializable()
class GameReductionData {
  final int? id;
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  final String? reduction;
  final String? title;
  final String? description;
  final String? icon;
  @JsonKey(fromJson: parseInt)
  final int? time;

  GameReductionData({
    this.id,
    this.startDate,
    this.endDate,
    this.reduction,
    this.title,
    this.description,
    this.icon,
    this.time,
  });

  double? get reductionAmount =>
      reduction != null ? double.tryParse(reduction!) : null;

  factory GameReductionData.fromJson(Map<String, dynamic> json) =>
      _$GameReductionDataFromJson(json);

  Map<String, dynamic> toJson() => _$GameReductionDataToJson(this);
}

@JsonSerializable()
class GameReductionResponse {
  final GameReductionData? gameReduction;
  final bool hasReduction;

  GameReductionResponse({this.gameReduction, this.hasReduction = false});

  factory GameReductionResponse.fromJson(Map<String, dynamic> json) =>
      _$GameReductionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GameReductionResponseToJson(this);
}

@JsonSerializable()
class UserGameReduction {
  final int? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'game_reduction_id')
  final int? gameReductionId;

  UserGameReduction({this.id, this.userId, this.gameReductionId});

  factory UserGameReduction.fromJson(Map<String, dynamic> json) =>
      _$UserGameReductionFromJson(json);

  Map<String, dynamic> toJson() => _$UserGameReductionToJson(this);
}
