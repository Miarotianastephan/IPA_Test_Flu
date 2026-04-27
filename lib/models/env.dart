import 'package:json_annotation/json_annotation.dart';

part 'env.g.dart';

@JsonSerializable()
class Env {
  String? back;
  String? storage;
  String? landing;

  Env({this.back, this.storage, this.landing});

  factory Env.fromJson(Map<String, dynamic> json) => _$EnvFromJson(json);

  Map<String, dynamic> toJson() => _$EnvToJson(this);
}
