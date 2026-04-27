import 'package:json_annotation/json_annotation.dart';

part 'notif_chinese.g.dart';

@JsonSerializable()
class NotifLink {
  final String link;
  final String text;

  NotifLink({
    required this.link,
    required this.text,
  });

  factory NotifLink.fromJson(Map<String, dynamic> json) =>
      _$NotifLinkFromJson(json);

  Map<String, dynamic> toJson() => _$NotifLinkToJson(this);
}

@JsonSerializable()
class NotifChinese {
  final List<String> body;
  final String title;

  @JsonKey(name: 'linkList')
  final List<NotifLink> linkList;

  NotifChinese({
    required this.body,
    required this.title,
    required this.linkList,
  });

  factory NotifChinese.fromJson(Map<String, dynamic> json) =>
      _$NotifChineseFromJson(json);

  Map<String, dynamic> toJson() => _$NotifChineseToJson(this);
}
