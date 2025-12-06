import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/message_service.dart';
import '../config/storage_config.dart';
import '../database/dao/conversation_dao.dart';
import '../database/dao/message_dao.dart';
import '../models/conversation.dart';
import '../models/conversation_user.dart';
import '../models/message.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';
import 'conversation_list_provider.dart';
import 'current_user_provider.dart';

class ChatState {
  final Conversation? conversation;
  final List<Message> messages;
  final bool loading;

  ChatState({
    this.conversation,
    this.messages = const [],
    this.loading = false,
  });

  ChatState copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? loading,
  }) {
    return ChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}

class ChatController extends StateNotifier<ChatState> {
  final Ref ref;
  final MessageService service;
  final ConversationDao conversationDao;
  final MessageDao messageDao;

  final int peerUserId;

  int? selfUserId;
  int? conversationId;

  ChatController(
    this.ref,
    this.service,
    this.conversationDao,
    this.messageDao,
    this.peerUserId,
  ) : super(ChatState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(loading: true);

    // 读取用户 ID
    final userRaw = await StorageService.instance.getValue("user_info");
    if (userRaw != null) {
      final map = userRaw is String ? jsonDecode(userRaw) : userRaw;
      selfUserId = UserInfo.fromJson(map).id;
    }

    // 从本地数据库取完整会话
    Conversation? conv = await conversationDao.getFullByPeerUser(peerUserId);

    // 如果本地没有 → 请求服务器
    if (conv == null) {
      final resp = await service.getConversationBetween(peerUserId);

      if (resp.data == null) {
        state = state.copyWith(loading: false);
        return;
      }

      final serverConv = resp.data!;

      final enrichedConv = serverConv.copyWith(
        users: [
          ConversationUser(
            id: 0,
            conversationId: serverConv.id,
            userId: peerUserId,
            joinedAt: serverConv.createdAt,
            user: null,
          ),
          ConversationUser(
            id: 0,
            conversationId: serverConv.id,
            userId: selfUserId!,
            joinedAt: serverConv.createdAt,
            user: null,
          ),
        ],
      );

      await conversationDao.upsertFull(enrichedConv);
      conv = await conversationDao.getFullById(enrichedConv.id);
      conv ??= enrichedConv;
    }

    conversationId = conv.id;

    ref.read(currentConversationIdProvider.notifier).state = conversationId;

    // 通知会话列表
    ref.read(conversationListProvider.notifier).upsertConversation(conv);

    // 加载本地消息
    final msgList = await messageDao.getMessages(conv.id);

    state = state.copyWith(
      conversation: conv,
      messages: msgList,
      loading: false,
    );
  }

  Future<void> sendMessage(String text) async {
    if (conversationId == null || text.trim().isEmpty) return;
    if (selfUserId == null) return;

    final conv = state.conversation;
    if (conv == null) return;

    final toUserId = peerUserId;

    // 创建临时本地消息
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = Message(
      id: tempId,
      conversationId: conversationId!,
      senderId: selfUserId!,
      content: text,
      messageType: "text",
      isRevoked: false,
      isSelf: true,
      isRead: true,
      // 自己的消息默认已读
      createdAt: DateTime.now(),
      resending: true,
      sendFailed: false,
    );

    addMessage(tempMsg); // 先插入 UI + DB

    //  HTTP 请求发送消息
    try {
      final resp = await service.sendMessage(
        conversationId: conversationId!,
        toUserId: toUserId.toString(),
        content: text,
        messageType: "text",
        isGroup: false,
      );

      //  覆盖临时消息，更新为真实 ID（保持 isSelf=true）
      final serverMsg = resp.data!.copyWith(isSelf: true, isRead: true);
      await messageDao.replaceTempMessage(tempId, serverMsg);

      // 更新 UI 中的 tempId → serverMsg
      final newList = state.messages.map((m) {
        if (m.id == tempId) {
          return serverMsg.copyWith(resending: false);
        }
        return m;
      }).toList();

      state = state.copyWith(messages: newList);

      final updatedConv = conv.copyWith(
        lastMessageId: serverMsg.id,
        lastMessage: serverMsg,
        updatedAt: serverMsg.createdAt,
      );
      await conversationDao.upsertBasic(updatedConv);
      state = state.copyWith(conversation: updatedConv);

      ref
          .read(conversationListProvider.notifier)
          .upsertConversation(updatedConv);
    } catch (e) {
      //  发送失败，更新失败状态
      final newList = state.messages.map((m) {
        if (m.id == tempId) {
          return m.copyWith(resending: false, sendFailed: true);
        }
        return m;
      }).toList();
      await messageDao.updateMessageSendState(tempId, sendFailed: true);
      state = state.copyWith(messages: newList);
    }
  }

  /// 添加消息
  void addMessage(Message msg) async {
    // 更新 UI
    final updated = [...state.messages, msg];
    state = state.copyWith(messages: updated);

    // 写入数据库 message 表
    await messageDao.insertMessage(msg);

    // 更新 conversation.lastMessage
    final conv = state.conversation;
    if (conv != null) {
      final newConv = conv.copyWith(
        lastMessageId: msg.id,
        lastMessage: msg,
        updatedAt: msg.createdAt,
      );

      // 更新 DB（只更新 conversation 表）
      await conversationDao.upsertBasic(newConv);

      state = state.copyWith(conversation: newConv);

      // 通知列表
      ref.read(conversationListProvider.notifier).upsertConversation(newConv);
    }
  }

  /// 添加消息但不写入数据库（用于当前会话实时消息）
  void addMessageToStateOnly(Message msg) {
    // 更新 UI 消息列表
    final updated = [...state.messages, msg];
    state = state.copyWith(messages: updated);

    // 更新会话的 lastMessage（但不写入数据库）
    final conv = state.conversation;
    if (conv != null) {
      final newConv = conv.copyWith(
        lastMessageId: msg.id,
        lastMessage: msg,
        updatedAt: msg.createdAt,
      );

      // 仅更新内存，不写入 DB
      state = state.copyWith(conversation: newConv);

      // 通知会话列表（也仅更新内存状态，不触发数据库写入）
      ref.read(conversationListProvider.notifier).upsertConversation(newConv);
    }
  }

  Future<void> onRead(Message msg) async {
    if (conversationId == null || selfUserId == null) return;
    if (msg.isSelf) return;
    if (msg.isRead == true) return;

    // 再查一次 DB，避免重复写入
    final dbMsg = await messageDao.getMessageById(msg.id);
    if (dbMsg?.isRead == true) {
      return; // 数据库已是已读，直接跳过
    }

    //  调用服务器接口
    try {
      await service.markAsRead(
        messageIDs: [msg.id],
        conversationId: conversationId!,
        isGroup: false,
      );
    } catch (_) {
      // 即便接口失败，本地依然可以更新已读状态
    }

    //  更新数据库 message 表
    await messageDao.updateMessageRead(msg.id, true);

    if (!mounted) return;

    //  更新内存 state 中的消息列表
    final newList = state.messages.map((m) {
      if (m.id == msg.id) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    state = state.copyWith(messages: newList);

    final conv = state.conversation;
    if (conv != null && conv.unreadCount > 0) {
      // 1. 更新当前 ChatState 里的会话
      final newConv = conv.copyWith(unreadCount: 0);
      await conversationDao.upsertBasic(newConv);

      if (!mounted) return;
      state = state.copyWith(conversation: newConv);

      // 2. 通知会话列表，把这个会话的 unreadCount 置 0
      ref
          .read(conversationListProvider.notifier)
          .markConversationAsRead(conversationId!);
    }
  }

  /// 清空历史消息（服务器 + 本地 DB）
  Future<void> clearHistory() async {
    if (conversationId == null) return;

    try {
      //调用后端接口清空历史消息（你需要在 messageService 中实现该接口）
      await service.clearHistory(conversationId: conversationId!);

      //删除本地消息数据库中的所有消息
      await messageDao.deleteMessagesByConversation(conversationId!);

      //将会话的 lastMessage 清空
      final conv = state.conversation;
      if (conv != null) {
        final newConv = conv.copyWith(lastMessage: null, lastMessageId: null);

        await conversationDao.upsertBasic(newConv);

        // 更新状态
        state = state.copyWith(conversation: newConv, messages: []);

        // 通知会话列表刷新
        ref.read(conversationListProvider.notifier).upsertConversation(newConv);
      }
    } catch (e) {
      print("clearHistory error: $e");
    }
  }

  Future<void> resendMessage(Message msg) async {
    if (conversationId == null || selfUserId == null) return;

    //UI 标记 “重发中”
    final sendingList = state.messages.map((m) {
      if (m.id == msg.id) {
        return m.copyWith(resending: true, sendFailed: false);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: sendingList);

    try {
      //调用发送消息的 HTTP 接口
      final resp = await service.sendMessage(
        conversationId: conversationId!,
        toUserId: peerUserId.toString(),
        content: msg.content,
        messageType: msg.messageType,
        isGroup: false,
      );

      //覆盖本地消息（用服务器返回的消息，保持 isSelf=true）
      final serverMsg = resp.data!.copyWith(isSelf: true, isRead: true);
      await messageDao.replaceTempMessage(msg.id, serverMsg);

      //更新 UI：重发成功
      final updatedList = state.messages.map((m) {
        if (m.id == msg.id) {
          return serverMsg.copyWith(resending: false, sendFailed: false);
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updatedList);
    } catch (e) {
      //重发失败 → UI标记失败
      final updatedList = state.messages.map((m) {
        if (m.id == msg.id) {
          return m.copyWith(resending: false, sendFailed: true);
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updatedList);

      //更新 DB（只需要更新 sendFailed）
      await messageDao.updateMessageSendState(msg.id, sendFailed: true);
    }
  }
}

// Provider：注入 ConversationDao + MessageDao
final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, int>((ref, peerUserId) {
      final service = ref.watch(messageServiceProvider);

      final db = ref.watch(currentUserDatabaseProvider);
      final conversationDao = ConversationDao(db);
      final messageDao = MessageDao(db);

      final controller = ChatController(
        ref,
        service,
        conversationDao,
        messageDao,
        peerUserId,
      );

      // 离开聊天页面自动取消当前会话 ID
      ref.onDispose(() {
        ref.read(currentConversationIdProvider.notifier).state = null;
      });

      return controller;
    });

final currentConversationIdProvider = StateProvider<int?>((ref) => null);
