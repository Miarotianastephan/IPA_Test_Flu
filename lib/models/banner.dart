import 'package:json_annotation/json_annotation.dart';

part 'banner.g.dart';

@JsonSerializable()
class BannerModel {
  final int id;
  final String name;
  final String? description;

  @JsonKey(name: 'url_image')
  final String urlImage;

  @JsonKey(name: 'expired_at')
  final DateTime expiredAt;

  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  BannerModel({
    required this.id,
    required this.name,
    required this.description,
    required this.urlImage,
    required this.expiredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);
}
