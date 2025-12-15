import 'package:json_annotation/json_annotation.dart';

part 'emoji_group.g.dart';

@JsonSerializable()
class EmojiGroup {
  final int id;
  final String name;
  final String price;

  @JsonKey(name: 'is_premium')
  final bool isPremium;

  EmojiGroup({
    required this.id,
    required this.name,
    required this.price,
    required this.isPremium,
  });

  factory EmojiGroup.fromJson(Map<String, dynamic> json) =>
      _$EmojiGroupFromJson(json);

  Map<String, dynamic> toJson() => _$EmojiGroupToJson(this);
}
