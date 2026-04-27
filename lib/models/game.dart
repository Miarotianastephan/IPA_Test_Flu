import 'package:json_annotation/json_annotation.dart';

part 'game.g.dart';

@JsonSerializable()
class Game {
  final String platType;
  final String gameType;
  final String gameCode;
  final String ingress;
  final String gameName;

  Game({
    required this.platType,
    required this.gameType,
    required this.gameCode,
    required this.ingress,
    required this.gameName,
  });

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  Map<String, dynamic> toJson() => _$GameToJson(this);
}
