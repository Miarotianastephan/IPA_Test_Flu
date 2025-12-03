import 'package:json_annotation/json_annotation.dart';

part 'page_params.g.dart';

@JsonSerializable()
class PageParams {
  final int page;
  final int limit;
  final int type;

  const PageParams({this.page = 1, this.limit = 20, this.type = 2});

  factory PageParams.fromJson(Map<String, dynamic> json) =>
      _$PageParamsFromJson(json);

  Map<String, dynamic> toJson() => _$PageParamsToJson(this);
}
