import 'package:json_annotation/json_annotation.dart';
import 'package:live_app/utils/json_utils.dart';

part 'comment_like.g.dart';

String _userIdToString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

String _commentIdToString(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

@JsonSerializable(explicitToJson: true)
class CommentLike {
  @JsonKey(fromJson: parseInt)
  final int id;
  @JsonKey(name: 'user_id', fromJson: _userIdToString)
  final String userId;
  @JsonKey(name: 'comment_id', fromJson: _commentIdToString)
  final String commentId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  CommentLike({
    required this.id,
    required this.userId,
    required this.commentId,
    required this.createdAt,
  });

  factory CommentLike.fromJson(Map<String, dynamic> json) {
    try {
      final result = _$CommentLikeFromJson(json);
      return result;
    } catch (e, stackTrace) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$CommentLikeToJson(this);
}
