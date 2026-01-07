import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/services/message_service.dart';
import '../config/storage_config.dart';
import '../database/dao/conversation_dao.dart';
import '../database/dao/message_dao.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/userinfo.dart';
import '../provider/api_provider.dart';
import 'conversation_list_provider.dart';
import 'conversation_provider.dart';
import 'current_user_provider.dart';

class GroupChatState {
  final Conversation? conversation;
  final List<Message> messages;
  final bool loading;

  GroupChatState({
    this.conversation,
    this.messages = const [],
    this.loading = false,
  });

  GroupChatState copyWith({
    Conversation? conversation,
    List<Message>? messages,
    bool? loading,
  }) {
    return GroupChatState(
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      loading: loading ?? this.loading,
    );
  }
}

class GroupChatController extends StateNotifier<GroupChatState> {
  final Ref ref;
  final MessageService service;
  final ConversationDao conversationDao;
  final MessageDao messageDao;

  final int conversationId;

  int? selfUserId;

  GroupChatController(
    this.ref,
    this.service,
    this.conversationDao,
    this.messageDao,
    this.conversationId,
  ) : super(GroupChatState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(loading: true);

    final userRaw = await StorageService.instance.getValue("user_info");
    if (userRaw != null) {
      final map = userRaw is String ? jsonDecode(userRaw) : userRaw;
      selfUserId = UserInfo.fromJson(map).id;
    }

    Conversation? conv = await conversationDao.getFullById(conversationId);

    if (conv == null) {
      state = state.copyWith(loading: false);
      return;
    }

    ref.read(currentConversationIdProvider.notifier).state = conversationId;

    ref.read(conversationListProvider.notifier).upsertConversation(conv);

    // Charger les messages locaux
    final msgList = await messageDao.getMessages(conversationId);

    state = state.copyWith(
      conversation: conv,
      messages: msgList,
      loading: false,
    );
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (selfUserId == null) return;

    final conv = state.conversation;
    if (conv == null) return;

    final tempId = DateTime.now().millisecondsSinceEpoch;
    final tempMsg = Message(
      id: tempId,
      conversationId: conversationId,
      senderId: selfUserId!,
      content: text,
      messageType: "text",
      isRevoked: false,
      isSelf: true,
      isRead: true,
      createdAt: DateTime.now(),
      resending: true,
      sendFailed: false,
    );

    addMessage(tempMsg);

    try {
      final resp = await service.sendMessage(
        conversationId: conversationId,
        toUserId: "",
        content: text,
        messageType: "text",
        isGroup: true,
      );

      final serverMsg = resp.data!.copyWith(isSelf: true, isRead: true);
      await messageDao.replaceTempMessage(tempId, serverMsg);

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

  void addMessage(Message msg) async {
    final updated = [...state.messages, msg];
    state = state.copyWith(messages: updated);

    await messageDao.insertMessage(msg);

    final conv = state.conversation;
    if (conv != null) {
      final newConv = conv.copyWith(
        lastMessageId: msg.id,
        lastMessage: msg,
        updatedAt: msg.createdAt,
      );

      await conversationDao.upsertBasic(newConv);

      state = state.copyWith(conversation: newConv);

      ref.read(conversationListProvider.notifier).upsertConversation(newConv);
    }
  }

  void addMessageToStateOnly(Message msg) {
    final updated = [...state.messages, msg];
    state = state.copyWith(messages: updated);

    final conv = state.conversation;
    if (conv != null) {
      final newConv = conv.copyWith(
        lastMessageId: msg.id,
        lastMessage: msg,
        updatedAt: msg.createdAt,
      );

      state = state.copyWith(conversation: newConv);

      ref.read(conversationListProvider.notifier).upsertConversation(newConv);
    }
  }

  Future<void> onRead(Message msg) async {
    if (selfUserId == null) return;
    if (msg.isSelf) return;
    if (msg.isRead == true) return;

    final dbMsg = await messageDao.getMessageById(msg.id);
    if (dbMsg?.isRead == true) {
      return;
    }

    try {
      await service.markAsRead(
        messageIDs: [msg.id],
        conversationId: conversationId,
        isGroup: true,
      );
    } catch (s) {
      // Même en cas d'échec, on peut mettre à jour localement
      debugPrint("$s");
    }

    await messageDao.updateMessageRead(msg.id, true);

    if (!mounted) return;

    final newList = state.messages.map((m) {
      if (m.id == msg.id) {
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
          .markConversationAsRead(conversationId);
    }
  }

  Future<void> clearHistory() async {
    try {
      await service.clearHistory(conversationId: conversationId);

      await messageDao.deleteMessagesByConversation(conversationId);

      final conv = state.conversation;
      if (conv != null) {
        final newConv = conv.copyWith(lastMessage: null, lastMessageId: null);

        await conversationDao.upsertBasic(newConv);

        state = state.copyWith(conversation: newConv, messages: []);

        ref.read(conversationListProvider.notifier).upsertConversation(newConv);
      }
    } catch (e) {
      debugPrint("error: $e");
    }
  }

  Future<void> resendMessage(Message msg) async {
    if (selfUserId == null) return;

    final sendingList = state.messages.map((m) {
      if (m.id == msg.id) {
        return m.copyWith(resending: true, sendFailed: false);
      }
      return m;
    }).toList();
    state = state.copyWith(messages: sendingList);

    try {
      final resp = await service.sendMessage(
        conversationId: conversationId,
        toUserId: "",
        content: msg.content,
        messageType: msg.messageType,
        isGroup: true,
      );

      final serverMsg = resp.data!.copyWith(isSelf: true, isRead: true);
      await messageDao.replaceTempMessage(msg.id, serverMsg);

      final updatedList = state.messages.map((m) {
        if (m.id == msg.id) {
          return serverMsg.copyWith(resending: false, sendFailed: false);
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updatedList);
    } catch (e) {
      final updatedList = state.messages.map((m) {
        if (m.id == msg.id) {
          return m.copyWith(resending: false, sendFailed: true);
        }
        return m;
      }).toList();

      state = state.copyWith(messages: updatedList);

      await messageDao.updateMessageSendState(msg.id, sendFailed: true);
    }
  }

  Future<bool> leaveGroup() async {
    try {
      await service.leaveGroup(conversationId);
      return true;
    } catch (e) {
      // leaveGroup error: $e
      return false;
    }
  }

  Future<bool> dissolveGroup() async {
    try {
      await service.dissolveGroup(conversationId);
      return true;
    } catch (e) {
      // dissolveGroup error: $e
      return false;
    }
  }
}

final groupChatControllerProvider = StateNotifierProvider.autoDispose
    .family<GroupChatController, GroupChatState, int>((ref, conversationId) {
      final service = ref.watch(messageServiceProvider);

      final db = ref.watch(currentUserDatabaseProvider);
      final conversationDao = ConversationDao(db);
      final messageDao = MessageDao(db);

      final controller = GroupChatController(
        ref,
        service,
        conversationDao,
        messageDao,
        conversationId,
      );

      ref.onDispose(() {
        ref.read(currentConversationIdProvider.notifier).state = null;
      });

      return controller;
    });
