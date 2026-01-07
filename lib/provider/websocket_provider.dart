import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/dao/conversation_dao.dart';
import '../database/dao/message_dao.dart';
import '../models/message.dart';
import '../models/system_notification.dart';
import '../models/userinfo.dart';
import '../protos/socket_message.pb.dart' as proto;
import '../websocket/websocket_manager.dart';
import 'conversation_list_provider.dart';
import 'conversation_provider.dart';
import 'current_user_provider.dart';
import 'system_notification_provider.dart';

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

final webSocketMessageProvider = StreamProvider<proto.SocketEnvelope>((ref) {
  final wsNotifier = ref.watch(webSocketProvider.notifier);
  return wsNotifier.messageStream;
});

class WebSocketNotifier extends StateNotifier<WebSocketState> {
  final _msgController = StreamController<proto.SocketEnvelope>.broadcast();
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

    manager.onSystemNotificationReceived = (data) {
      _handleSystemNotificationReceived(data);
    };

    manager.onConnectCallback = _handleConnected;
    manager.onDisconnectCallback = _handleDisconnected;
  }

  Stream<proto.SocketEnvelope> get messageStream => _msgController.stream;

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

    if (message.senderId == userId) {
      return;
    }

    try {
      final db = ref.read(currentUserDatabaseProvider);
      final messageDao = MessageDao(db);
      await messageDao.insertMessage(message);
    } catch (e) {
      debugPrint("Error saving message: $e");
    }

    final currentConvId = ref.read(currentConversationIdProvider);

    if (currentConvId == message.conversationId) {
      try {
        final db = ref.read(currentUserDatabaseProvider);
        final conversationDao = ConversationDao(db);
        final conversation = await conversationDao.getFullById(
          message.conversationId,
        );

        if (conversation == null) {
          return;
        }

        final isGroupChat = conversation.type == 'group';

        final receivedMessage = message.copyWith(isSelf: false, isRead: false);

        if (isGroupChat) {
          final controller = ref.read(
            conversationProvider(message.conversationId).notifier,
          );
          controller.addMessageToStateOnly(receivedMessage);
        } else {
          final chatController = ref.read(
            chatControllerProvider(message.senderId).notifier,
          );
          chatController.addMessageToStateOnly(receivedMessage);
        }
      } catch (e) {
        debugPrint("Error adding message to UI: $e");
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

  Future<void> _handleSystemNotificationReceived(
    Map<String, dynamic> data,
  ) async {
    try {
      // Parse the system notification from WebSocket data
      final notification = SystemNotification.fromJson(data);
      // Add notification to the system notification provider
      final notificationNotifier = ref.read(
        systemNotificationProvider.notifier,
      );
      notificationNotifier.addNotification(notification);
    } catch (e) {
      debugPrint("Error handling system notification: $e");
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

  void sendEnvelope(proto.SocketEnvelope env) {
    state.manager.sendEnvelope(env);
  }

  @override
  void dispose() {
    _msgController.close();
    super.dispose();
  }
}
