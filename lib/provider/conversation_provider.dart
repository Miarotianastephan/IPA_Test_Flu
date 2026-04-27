import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/message_service.dart';
import '../config/storage_config.dart';
import '../database/dao/conversation_dao.dart';
import '../database/dao/message_dao.dart';
import '../models/api_response.dart';
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

  final String? peerUserId;

  final int? initialConversationId;

  String? selfUserId;
  int? conversationId;
  bool isGroupChat = false;

  final Completer<void> initDone = Completer<void>();

  ChatController(
    this.ref,
    this.service,
    this.conversationDao,
    this.messageDao,
    this.peerUserId,
  ) : initialConversationId = null,
      super(ChatState()) {
    _init().whenComplete(() {
      if (!initDone.isCompleted) initDone.complete();
    });
  }

  ChatController.fromConversationId(
    this.ref,
    this.service,
    this.conversationDao,
    this.messageDao,
    this.initialConversationId,
  ) : peerUserId = null,
      super(ChatState()) {
    _initFromConversationId().whenComplete(() {
      if (!initDone.isCompleted) initDone.complete();
    });
  }

  Future<void> _init() async {
    state = state.copyWith(loading: true);

    // 读取用户 ID
    final userRaw = await StorageService.instance.getValue("user_info");
    if (userRaw != null) {
      final map = userRaw is String ? jsonDecode(userRaw) : userRaw;
      selfUserId = UserInfo.fromJson(map).id;
    }

    if (peerUserId == null) {
      if (mounted) {
        state = state.copyWith(loading: false);
      }
      return;
    }

    // 始终请求服务器以确保会话存在（get-or-create）
    final resp = await service.getConversationBetween(peerUserId!);

    Conversation? conv;

    if (resp.data != null) {
      final serverConv = resp.data!;

      conversationId = serverConv.id;
      isGroupChat = serverConv.type == 'group';

      final enrichedConv = serverConv.copyWith(
        users: [
          ConversationUser(
            id: 0,
            conversationId: serverConv.id,
            userId: peerUserId!,
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
      try {
        await conversationDao.upsertFull(enrichedConv);
        conv =
            await conversationDao.getFullById(enrichedConv.id) ?? enrichedConv;
      } catch (e) {
        conv = enrichedConv;
      }
    } else {
      try {
        conv = await conversationDao.getFullByPeerUser(peerUserId!);
      } catch (e) {
        debugPrint('[_init] local DB fallback error: $e');
      }
    }

    if (conv == null) {
      if (mounted) state = state.copyWith(loading: false);
      return;
    }

    conversationId = conv.id;
    isGroupChat = conv.type == 'group';

    ref.read(currentConversationIdProvider.notifier).state = conversationId;

    // 通知会话列表
    try {
      ref.read(conversationListProvider.notifier).upsertConversation(conv);
    } catch (e) {
      debugPrint('[_init] upsertConversation error: $e');
    }

    // 先用本地缓存展示（web DB may be unavailable）
    List<Message> localMsgs = [];
    try {
      localMsgs = await messageDao.getMessages(conv.id);
    } catch (e) {
      debugPrint('[_init] getMessages (local) error: $e');
    }

    if (!mounted) {
      debugPrint(
        '[_init] DROPPED — provider was disposed before state could be set',
      );
      return;
    }
    state = state.copyWith(
      conversation: conv,
      messages: localMsgs,
      loading: false,
    );

    // 从服务器拉取历史消息
    try {
      final histResp = await service.getHistory(
        conversationId: conv.id,
        page: 1,
        limit: 50,
      );
      final serverMsgs = histResp.data?.list ?? [];
      if (serverMsgs.isNotEmpty) {
        try {
          for (final m in serverMsgs) {
            await messageDao.insertMessage(m);
          }
          final updatedMsgs = await messageDao.getMessages(conv.id);
          if (!mounted) return;
          state = state.copyWith(messages: updatedMsgs);
        } catch (e) {
          debugPrint('[_init] DB insert error (non-fatal): $e');
          if (!mounted) return;
          state = state.copyWith(messages: serverMsgs);
        }
      }
    } catch (e) {
      debugPrint('[_init] getHistory error: $e');
    }

    _markAllAsRead();
  }

  Future<void> _initFromConversationId() async {
    state = state.copyWith(loading: true);

    final userRaw = await StorageService.instance.getValue("user_info");
    if (userRaw != null) {
      final map = userRaw is String ? jsonDecode(userRaw) : userRaw;
      selfUserId = UserInfo.fromJson(map).id;
    }

    if (initialConversationId == null) {
      if (mounted) {
        state = state.copyWith(loading: false);
      }
      return;
    }

    Conversation? conv = await conversationDao.getFullById(
      initialConversationId!,
    );

    if (conv == null) {
      if (mounted) {
        state = state.copyWith(loading: false);
      }
      return;
    }

    conversationId = conv.id;
    isGroupChat = conv.type == 'group';

    ref.read(currentConversationIdProvider.notifier).state = conversationId;

    ref.read(conversationListProvider.notifier).upsertConversation(conv);

    final msgList = await messageDao.getMessages(conversationId!);

    if (!mounted) return;
    state = state.copyWith(
      conversation: conv,
      messages: msgList,
      loading: false,
    );

    _markAllAsRead();
  }

  Future<void> _markAllAsRead() async {
    if (conversationId == null || selfUserId == null) return;

    final unreadMessages = state.messages
        .where((m) => !m.isSelf && !m.isRead)
        .toList();

    if (unreadMessages.isEmpty) return;

    final unreadIds = unreadMessages.map((m) => m.id).toList();

    try {
      await service.markAsRead(
        messageIDs: unreadIds,
        conversationId: conversationId!,
        isGroup: isGroupChat,
      );
    } catch (_) {}

    for (final id in unreadIds) {
      await messageDao.updateMessageRead(id, true);
    }

    if (!mounted) return;

    final newList = state.messages.map((m) {
      if (unreadIds.contains(m.id)) {
        return m.copyWith(isRead: true);
      }
      return m;
    }).toList();

    state = state.copyWith(messages: newList);

    final conv = state.conversation;
    if (conv != null && conv.unreadCount > 0) {
      final newConv = conv.copyWith(unreadCount: 0);
      await conversationDao.upsertBasic(newConv);

      if (!mounted) return;
      state = state.copyWith(conversation: newConv);

      ref
          .read(conversationListProvider.notifier)
          .markConversationAsRead(conversationId!);
    }
  }

  Future<void> refreshConversation() async {
    if (conversationId == null) return;

    final conv = await conversationDao.getFullById(conversationId!);
    if (conv != null && mounted) {
      state = state.copyWith(conversation: conv);

      ref.read(conversationListProvider.notifier).upsertConversation(conv);
    }
  }

  Future<void> sendMessage(String text, {String messageType = "text"}) async {
    if (conversationId == null || text.trim().isEmpty) {
      return;
    }
    if (selfUserId == null) {
      return;
    }

    final conv = state.conversation;

    // 创建临时本地消息
    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = Message(
      id: tempId,
      conversationId: conversationId!,
      senderId: selfUserId!,
      content: text,
      messageType: messageType,
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
      final supportAgentId = conv?.users
          .where((u) => u.isSupportAgent)
          .map((u) => u.agentSupportId)
          .firstOrNull;

      final ApiResponse<Message> resp;
      if (supportAgentId != null) {
        resp = await service.sendToSupportMessage(
          conversationId: conversationId!,
          agentSupportId: supportAgentId,
          content: text,
          messageType: messageType,
          isGroup: false,
        );
      } else {
        resp = await service.sendMessage(
          conversationId: conversationId!,
          toUserId: isGroupChat ? "" : (peerUserId?.toString() ?? ""),
          content: text,
          messageType: messageType,
          isGroup: isGroupChat,
        );
      }

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

      if (!mounted) return;
      state = state.copyWith(messages: newList);

      final updatedConv = conv?.copyWith(
        lastMessageId: serverMsg.id,
        lastMessage: serverMsg,
        updatedAt: serverMsg.createdAt,
      );
      if (updatedConv != null) {
        await conversationDao.upsertBasic(updatedConv);
        if (!mounted) return;
        state = state.copyWith(conversation: updatedConv);
      }

      if (updatedConv != null) {
        Future.microtask(() {
          if (mounted) {
            final notifier = ref.read(conversationListProvider.notifier);
            final currentList = [...notifier.state.conversations];
            final index = currentList.indexWhere((c) => c.id == updatedConv.id);
            if (index >= 0) {
              final tempList = [...currentList];
              tempList.removeAt(index);
              notifier.state = notifier.state.copyWith(conversations: tempList);
            }
            notifier.upsertConversation(updatedConv);
          }
        });

        debugPrint(
          "Conversation updated after sending message: ${updatedConv.lastMessage?.content}",
        );
      }
    } catch (e, st) {
      debugPrint('[sendMessage] EXCEPTION: $e\n$st');
      //  发送失败，更新失败状态
      final newList = state.messages.map((m) {
        if (m.id == tempId) {
          return m.copyWith(resending: false, sendFailed: true);
        }
        return m;
      }).toList();
      await messageDao.updateMessageSendState(tempId, sendFailed: true);
      if (!mounted) return;
      state = state.copyWith(messages: newList);
    }
  }

  /// 添加消息
  void addMessage(Message msg) async {
    // 更新 UI
    final updated = [...state.messages, msg];
    if (!mounted) return;
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

      if (!mounted) return;
      state = state.copyWith(conversation: newConv);

      // 通知列表
      ref.read(conversationListProvider.notifier).upsertConversation(newConv);
    }
  }

  /// 添加消息但不写入数据库（用于当前会话实时消息）
  void addMessageToStateOnly(Message msg) {
    // 更新 UI 消息列表
    final updated = [...state.messages, msg];
    if (!mounted) return;
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
        isGroup: isGroupChat,
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
        if (!mounted) return;
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
    if (!mounted) return;
    state = state.copyWith(messages: sendingList);

    try {
      //调用发送消息的 HTTP 接口
      final conv = state.conversation;
      debugPrint("conv id : ${conv!.id}");
      final supportAgentId = conv?.users
          .where((u) => u.isSupportAgent)
          .map((u) => u.agentSupportId)
          .firstOrNull;

      final ApiResponse<Message> resp;
      if (supportAgentId != null) {
        resp = await service.sendToSupportMessage(
          conversationId: conversationId!,
          agentSupportId: supportAgentId,
          content: msg.content,
          messageType: msg.messageType,
          isGroup: false,
        );
      } else {
        resp = await service.sendMessage(
          conversationId: conversationId!,
          toUserId: isGroupChat ? "" : (peerUserId?.toString() ?? ""),
          content: msg.content,
          messageType: msg.messageType,
          isGroup: isGroupChat,
        );
      }

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

      if (!mounted) return;
      state = state.copyWith(messages: updatedList);

      // Update conversation last message for resent messages
      final conversation = state.conversation;
      if (conversation != null) {
        final updatedConv = conversation.copyWith(
          lastMessageId: serverMsg.id,
          lastMessage: serverMsg,
          updatedAt: serverMsg.createdAt,
        );
        await conversationDao.upsertBasic(updatedConv);
        if (!mounted) return;
        state = state.copyWith(conversation: updatedConv);

        // Force update conversation list
        Future.microtask(() {
          if (mounted) {
            final notifier = ref.read(conversationListProvider.notifier);
            final currentList = [...notifier.state.conversations];
            final index = currentList.indexWhere((c) => c.id == updatedConv.id);
            if (index >= 0) {
              final tempList = [...currentList];
              tempList.removeAt(index);
              notifier.state = notifier.state.copyWith(conversations: tempList);
            }
            notifier.upsertConversation(updatedConv);
          }
        });
      }
    } catch (e) {
      //重发失败 → UI标记失败
      final updatedList = state.messages.map((m) {
        if (m.id == msg.id) {
          return m.copyWith(resending: false, sendFailed: true);
        }
        return m;
      }).toList();

      if (!mounted) return;
      state = state.copyWith(messages: updatedList);

      //更新 DB（只需要更新 sendFailed）
      await messageDao.updateMessageSendState(msg.id, sendFailed: true);
    }
  }

  Future<bool> leaveGroup() async {
    if (!isGroupChat || conversationId == null) return false;

    try {
      await service.leaveGroup(conversationId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> dissolveGroup() async {
    if (!isGroupChat || conversationId == null) return false;

    try {
      await service.dissolveGroup(conversationId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<int> kickMember(String targetUserId) async {
    if (!isGroupChat || conversationId == null) return 0;

    try {
      final response = await service.kickUser(
        conversationId: conversationId!,
        targetUserId: targetUserId,
      );
      return response.code;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> setUserAsGroupAdmin(String targetUserId) async {
    if (!isGroupChat || conversationId == null) return false;

    try {
      await service.setUserAsGroupAdmin(
        conversationId: conversationId!,
        userId: targetUserId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> transferOwnership(String newOwnerId) async {
    if (!isGroupChat || conversationId == null) return false;

    try {
      await service.transferGroupOwner(
        conversationId: conversationId!,
        newOwnerId: newOwnerId,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteGroup() async {
    if (!isGroupChat || conversationId == null) return false;

    try {
      await service.deleteGroup(conversationId!);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a member from the conversation (update local state and database)
  Future<void> removeMemberFromConversation(String userId) async {
    final conv = state.conversation;
    if (conv == null || conversationId == null) return;
    // Remove the member from the database first
    await conversationDao.removeUserFromConversation(conversationId!, userId);

    // Remove the member from the users list
    final updatedUsers = conv.users.where((u) => u.userId != userId).toList();
    final updatedConv = conv.copyWith(users: updatedUsers);
    // Update the state
    if (!mounted) return;
    state = state.copyWith(conversation: updatedConv);

    // Also update the conversation list provider
    ref.read(conversationListProvider.notifier).upsertConversation(updatedConv);
  }
}

final chatControllerProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, String>((ref, peerUserId) {
      // Keep alive until _init finishes so autoDispose doesn't kill it mid-flight
      final keepAlive = ref.keepAlive();

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

      // Release keepAlive once init completes
      controller.initDone.future.then((_) => keepAlive.close());

      // 离开聊天页面自动取消当前会话 ID
      ref.onDispose(() {
        debugPrint(
          '[chatControllerProvider] DISPOSED for peerUserId=$peerUserId',
        );
        ref.read(currentConversationIdProvider.notifier).state = null;
      });

      return controller;
    });

final conversationProvider = StateNotifierProvider.autoDispose
    .family<ChatController, ChatState, int>((ref, conversationId) {
      final keepAlive = ref.keepAlive();

      final service = ref.watch(messageServiceProvider);

      final db = ref.watch(currentUserDatabaseProvider);
      final conversationDao = ConversationDao(db);
      final messageDao = MessageDao(db);

      final controller = ChatController.fromConversationId(
        ref,
        service,
        conversationDao,
        messageDao,
        conversationId,
      );

      controller.initDone.future.then((_) => keepAlive.close());

      ref.onDispose(() {
        ref.read(currentConversationIdProvider.notifier).state = null;
      });

      return controller;
    });

final currentConversationIdProvider = StateProvider<int?>((ref) => null);
