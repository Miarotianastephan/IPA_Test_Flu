import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/models/emoji_group.dart';

part 'emoji.g.dart';

@JsonSerializable(explicitToJson: true)
class Emoji {
  final int id;
  final String code;
  final String url;
  final int type;
  final int status;
  final EmojiGroup group;
  final bool purchased;

  Emoji({
    required this.id,
    required this.code,
    required this.url,
    required this.type,
    required this.status,
    required this.group,
    required this.purchased,
  });

  factory Emoji.fromJson(Map<String, dynamic> json) =>
      _$EmojiFromJson(json);

  Map<String, dynamic> toJson() => _$EmojiToJson(this);
}
