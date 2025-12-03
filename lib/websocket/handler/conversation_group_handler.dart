import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../protos/socket_message.pb.dart';
import 'msg_handler.dart';

class GroupConversationHandler extends MessageHandler {
  final Ref ref;

  GroupConversationHandler(this.ref);

  @override
  bool canHandle(SocketEnvelope env) {
    final meta = env.meta;
    final body = env.body;

    // 必须是业务消息
    if (!body.hasBusiness()) return false;
    final biz = body.business;
    // 必须是 IM 消息
    if (!biz.hasIm()) return false;
    final im = biz.im;
    // 必须是 ChatMessage（不是 Event / Bot）
    if (!im.hasChat()) return false;
    return meta.scope == TargetScope.SCOPE_GROUP;
  }

  @override
  void handle(SocketEnvelope env) {

  }
}