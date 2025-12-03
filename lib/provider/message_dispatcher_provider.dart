import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../protos/socket_message.pb.dart';
import '../websocket/handler/conversation_group_handler.dart';
import '../websocket/handler/conversation_private_handler.dart';
import '../websocket/handler/msg_handler.dart';
import '../websocket/handler/notice_handler.dart';
import 'current_user_provider.dart';
import 'websocket_provider.dart';

final messageDispatcherProvider = Provider<MessageDispatcher>((ref) {
  final dispatcher = MessageDispatcher(ref);
  ref.onDispose(dispatcher.dispose);
  return dispatcher;
});

class MessageDispatcher {
  final Ref ref;

  ProviderSubscription<AsyncValue<SocketEnvelope>>? _sub;

  late final List<MessageHandler> handlers;

  MessageDispatcher(this.ref) {
    handlers = [
      PrivateConversationHandler(ref),
      GroupConversationHandler(ref),
      NoticeHandler(ref),
    ];

    _sub = ref.listen<AsyncValue<SocketEnvelope>>(
      webSocketMessageProvider,
          (_, next) {
        next.whenData(_dispatch);
      },
    );
  }

  void _dispatch(SocketEnvelope env) {
    bool matched = false;

    for (final handler in handlers) {
      if (handler.canHandle(env)) {
        handler.handle(env);
        matched = true;
      }
    }

    if (!matched) {
      debugPrint("未匹配到 Handler 的消息: $env");
    }
  }

  void dispose() => _sub?.close();
}


final globalInitializerProvider = Provider<void>((ref) {
  // 强制加载当前用户（从 storage）并reconnect WebSocket si nécessaire
  ref.watch(currentUserProvider);

  // 强制构造 dispatcher
  ref.watch(messageDispatcherProvider);

  // 未来你想全局初始化更多 provider，也都加这里
  return;
});