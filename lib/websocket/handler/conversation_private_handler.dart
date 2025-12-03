import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../protos/socket_message.pb.dart';
import 'msg_handler.dart';

class PrivateConversationHandler extends MessageHandler {
  final Ref ref;

  PrivateConversationHandler(this.ref);

  @override
  bool canHandle(SocketEnvelope env) {
    final meta = env.meta;
    final body = env.body;

    // 必须是业务消息
    if (!body.hasBusiness()) return false;
    final biz = body.business;

    // 必须是单聊（用户→用户）
    if (meta.scope != TargetScope.SCOPE_USER) return false;

    // 必须是 IM
    if (!biz.hasIm()) return false;
    final im = biz.im;

    // 允许的 IM 类型
    if (im.hasChat()) return true;           // 私聊文字 / 图片 / 语音等
    if (im.hasEvent()) return true;          // 单聊事件（拍一拍等）
    if (im.hasBotMessage()) return true;     // 私聊 Bot 回复
    if (im.hasBotCommand()) return true;     // Bot 指令

    // 其他 IM 类型不处理（如果未来加更多）
    return false;
  }

  @override
  void handle(SocketEnvelope env) {}
}
