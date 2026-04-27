import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'chat_log.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatLog {
   @JsonKey(fromJson: parseInt)
   final int id;
   final String fromUserId;
   final String toUserId;
   final DateTime createdAt;

   ChatLog({required this.id, required this.fromUserId, required this.toUserId, required this.createdAt});

   factory ChatLog.fromJson(Map<String, dynamic> json) => _$ChatLogFromJson(json);
   Map<String, dynamic> toJson() => _$ChatLogToJson(this);
}