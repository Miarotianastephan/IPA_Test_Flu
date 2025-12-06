import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/dao/message_dao.dart';
import '../models/message.dart';
import '../models/userinfo.dart';
import '../protos/socket_message.pb.dart';
import '../websocket/websocket_manager.dart';
import 'conversation_list_provider.dart';
import 'conversation_provider.dart';
import 'current_user_provider.dart';

class WebSocketState {
  final bool isConnected;
  final WebSocketManager manager;
  final bool isRetrying;

  WebSocketState({
    required this.isConnected,
    required this.manager,
    this.isRetrying = false,
  });

  WebSocketState copyWith({
    bool? isConnected,
    WebSocketManager? manager,
    bool? isRetrying,
  }) {
    return WebSocketState(
      isConnected: isConnected ?? this.isConnected,
      manager: manager ?? this.manager,
      isRetrying: isRetrying ?? this.isRetrying,
    );
  }
}

final webSocketProvider =
    StateNotifierProvider<WebSocketNotifier, WebSocketState>((ref) {
      return WebSocketNotifier(WebSocketManager.instance, ref);
    });

final webSocketMessageProvider = StreamProvider<SocketEnvelope>((ref) {
  final wsNotifier = ref.watch(webSocketProvider.notifier);
  return wsNotifier.messageStream;
});

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  final _msgController = StreamController<SocketEnvelope>.broadcast();
  final Ref ref;

  WebSocketNotifier(WebSocketManager manager, this.ref)
    : super(WebSocketState(isConnected: false, manager: manager)) {
    manager.onLog = (msg) => print("[WS] $msg");

    manager.onMessageReceived = (env) {
      _msgController.add(env);
    };

    manager.onLiveBatch = (batch) {
      print("Live batch received : $batch");
    };

    manager.onMessageSent = (message) {
      _handleMessageReceived(message);
    };

    manager.onConnectCallback = _handleConnected;
    manager.onDisconnectCallback = _handleDisconnected;
  }

  Stream<SocketEnvelope> get messageStream => _msgController.stream;

  void _handleConnected() {
    state = state.copyWith(isConnected: true);
  }

  void _handleDisconnected() {
    state = state.copyWith(isConnected: false);
  }

  Future<void> _handleMessageReceived(Message message) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return;
    }

    try {
      final db = ref.read(currentUserDatabaseProvider);
      final messageDao = MessageDao(db);
      await messageDao.insertMessage(message);
    } catch (e) {
      debugPrint("Error fetching message: $e");
    }

    final currentConvId = ref.read(currentConversationIdProvider);

    if (currentConvId == message.conversationId) {
      try {
        final chatController = ref.read(
          chatControllerProvider(message.senderId).notifier,
        );
        chatController.addMessageToStateOnly(message);
      } catch (e) {
        debugPrint("Error adding chat: $e");
      }
    }

    try {
      final convListNotifier = ref.read(conversationListProvider.notifier);
      final conversations = ref.read(conversationListProvider).conversations;

      final convIndex = conversations.indexWhere(
        (c) => c.id == message.conversationId,
      );

      if (convIndex >= 0) {
        final conv = conversations[convIndex];
        final updatedConv = conv.copyWith(
          lastMessage: message,
          lastMessageId: message.id,
          updatedAt: message.createdAt,
          unreadCount: currentConvId == message.conversationId
              ? 0
              : conv.unreadCount + 1,
        );

        await convListNotifier.upsertConversation(updatedConv);
      } else {
        await convListNotifier.fetchAllConversationsFromServer();

        final updatedConversations = ref
            .read(conversationListProvider)
            .conversations;
        final newConvIndex = updatedConversations.indexWhere(
          (c) => c.id == message.conversationId,
        );

        if (newConvIndex >= 0) {
          final newConv = updatedConversations[newConvIndex];
          if (currentConvId != message.conversationId &&
              newConv.unreadCount == 0) {
            final fixedConv = newConv.copyWith(
              unreadCount: 1,
              lastMessage: message,
              lastMessageId: message.id,
              updatedAt: message.createdAt,
            );
            await convListNotifier.upsertConversation(fixedConv);
          }
        }
      }
    } catch (e) {
      debugPrint("Error updating message: $e");
    }
  }

  // ----- API -----
  Future<void> connect(UserInfo user) async {
    final baseUrl = dotenv.env['WS_BASE_URL'] ?? '';
    state.manager.connect(
      userId: user.id,
      token: user.token ?? '',
      baseUrl: baseUrl,
    );
  }

  void disconnect() {
    state.manager.disconnect();
  }

  void sendEnvelope(SocketEnvelope env) {
    state.manager.sendEnvelope(env);
  }

  @override
  void dispose() {
    _msgController.close();
    super.dispose();
  }
}
