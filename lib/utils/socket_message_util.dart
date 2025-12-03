import 'package:fixnum/fixnum.dart';

import '../protos/socket_message.pb.dart';

class SocketMessageUtil {
  /// 构建一个业务消息
  static SocketEnvelope buildBusinessMessage({
    required int fromUser,
    required int toUser,
    required String messageId,
    required MessageBody body,
    int? timestamp,
  }) {
    final ts = timestamp ?? DateTime.now().millisecondsSinceEpoch;

    return SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = messageId
        ..fromUser = Int64(fromUser)
        ..toTarget = Int64(toUser)
        ..scope = TargetScope.SCOPE_USER
        ..timestamp = Int64(ts)
        ..version = 1
        ..category = MessageCategory.CATEGORY_BUSINESS)
      ..body = body;
  }

  /// 构建握手消息
  static SocketEnvelope buildHandshake({
    required int userId,
    required String token,
    required String clientVersion,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "handshake-$now"
        ..fromUser = Int64(userId)
        ..timestamp = Int64(now)
        ..category = MessageCategory.CATEGORY_CONTROL)
      ..body = (MessageBody()
        ..control = (ControlBody()
          ..handshake = (Handshake()
            ..token = token
            ..clientVersion = clientVersion)));
  }

  /// 构建心跳消息
  static SocketEnvelope buildHeartbeat({required int userId}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "hb-$now"
        ..fromUser = Int64(userId)
        ..timestamp = Int64(now)
        ..category = MessageCategory.CATEGORY_CONTROL)
      ..body = (MessageBody()
        ..control = (ControlBody()
          ..heartbeat = (Heartbeat()
            ..seq = Int64(now)
            ..timestamp = Int64(now))));
  }

  /// 构建一个 Chat 聊天业务包
  static SocketEnvelope buildChatMessage({
    required int fromUser,
    required int toUser,
    required String text,
  }) {
    final nowMs = DateTime.now().millisecondsSinceEpoch;

    final chat = ChatMessage()
      ..text = text
      ..contentType = "text"
      ..ext.addAll({"message_type": "chat"});

    final imBody = IMBody()..chat = chat;
    final bizBody = BusinessBody()..im = imBody;

    return SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "pm-$nowMs"
        ..fromUser = Int64(fromUser)
        ..toTarget = Int64(toUser)
        ..scope = TargetScope.SCOPE_USER
        ..timestamp = Int64(nowMs)
        ..traceId = "trace-$nowMs"
        ..version = 1
        ..category = MessageCategory.CATEGORY_BUSINESS)
      ..body = (MessageBody()..business = bizBody);
  }

  /// 构建业务 ACK（仅用于非控制类消息）
  static SocketEnvelope buildAck({
    required int fromUser,
    required int toUser,
    required String ackId,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;

    return SocketEnvelope()
      ..meta = (MessageMeta()
        ..messageId = "ack-$ackId"
        ..fromUser = Int64(fromUser)
        ..toTarget = Int64(toUser)
        ..scope = TargetScope.SCOPE_USER
        ..timestamp = Int64(now)
        ..traceId = "trace-$now"
        ..version = 1
        ..category = MessageCategory.CATEGORY_CONTROL)
      ..body = (MessageBody()
        ..control = (ControlBody()
          ..ack = (Ack()
            ..ackId = ackId
            ..success = true
            ..reason = ""
            ..timestamp = Int64(now))));
  }
}
