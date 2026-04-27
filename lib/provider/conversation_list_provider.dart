import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/conversation.dart';

import '../api/services/message_service.dart';
import '../database/app_database.dart';
import '../database/dao/conversation_dao.dart';
import '../database/dao/message_dao.dart';
import '../models/conversation_user.dart';
import '../models/message.dart';
import '../models/message_inbox.dart';
import '../provider/api_provider.dart';
import 'current_user_provider.dart';

class ConversationListState {
  final List<Conversation> conversations;
  final bool isLoading;
  final String? error;

  ConversationListState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationListState copyWith({
    List<Conversation>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationListState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ConversationListNotifier extends StateNotifier<ConversationListState> {
  final MessageService messageService;
  final ConversationDao conversationDao;
  final MessageDao messageDao;

  Message? _mergeLastMessage(Message? oldMsg, Message? newMsg) {
    if (oldMsg == null) return newMsg;
    if (newMsg == null) return oldMsg;
    return newMsg.createdAt.isAfter(oldMsg.createdAt) ? newMsg : oldMsg;
  }

  bool _isLoading = false;

  ConversationListNotifier(
    this.messageService,
    this.conversationDao,
    this.messageDao, {
    bool autoLoad = false,
  }) : super(ConversationListState()) {
    if (autoLoad) {
      loadConversationsAndHistory();
    }
  }

  /// 只从本地数据库加载 —— 不触发网络
  Future<bool> _loadFromDbOnly() async {
    final localList = await conversationDao.getAllFull();

    if (localList.isEmpty) {
      return false;
    }

    if (!mounted) return false;
    state = state.copyWith(conversations: _sortConversations(localList));
    return true; // 表示已成功从本地数据库加载
  }

  Future<void> loadConversationsAndHistory({bool isRefresh = false}) async {
    if (_isLoading && !isRefresh) return;
    if (!mounted) return;
    _isLoading = true;
    state = state.copyWith(isLoading: true, error: null);

    try {
      if (isRefresh) {
        await fetchAllConversationsFromServer();
        await loadHistory();
      } else {
        // 进入页面 → 优先加载本地 Drift
        bool hasLocal = false;
        try {
          hasLocal = await _loadFromDbOnly().timeout(
            const Duration(seconds: 3),
            onTimeout: () => false,
          );
        } catch (e) {
          hasLocal = false;
        }
        //如果会本地有记录 就只加载未读数据
        if (hasLocal) {
          await loadUnReadHistory();
        } else {
          // 如果会没有记录 就加载所有的 会话 和 所有的聊天记录
          await fetchAllConversationsFromServer();
          await loadHistory();
        }
      }

      if (!mounted) return;
      _isLoading = false;
      state = state.copyWith(isLoading: false, error: null);
    } catch (e) {
      if (!mounted) return;
      _isLoading = false;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load conversations: ${e.toString()}',
      );
    }
  }

  Future<void> loadHistory() async {
    final conversations = await conversationDao.getAllFull();
    if (conversations.isEmpty) return;

    const int limit = 50;

    await Future.wait(
      conversations.map((conv) async {
        int page = 1;
        int loadedCount = 0;

        while (true) {
          final resp = await messageService.getHistory(
            conversationId: conv.id,
            page: page,
            limit: limit,
          );
          final data = resp.data;
          if (data == null || data.list.isEmpty) break;

          for (final msg in data.list) {
            await messageDao.insertMessage(msg);
          }

          loadedCount += data.list.length;
          final total = data.total;

          if (loadedCount >= total || data.list.length < limit) break;

          page++;
        }

        await conversationDao.updateUnreadCount(conv.id, 0);
      }),
    );
  }

  /// 加载全部未读消息（分页加载到全部加载完成）
  Future<void> loadUnReadHistory() async {
    const int limit = 50;
    int page = 1;
    List<MessageInbox> allUnread = [];

    try {
      while (true) {
        try {
          final resp = await messageService.getUnreadList(
            page: page,
            limit: limit,
          );

          final data = resp.data;
          if (data == null || data.list.isEmpty) break;

          allUnread.addAll(data.list);

          final total = data.total;
          if (allUnread.length >= total || data.list.length < limit) break;

          page++;
        } catch (e) {
          if (e.toString().contains('Any conversation found')) {
            break;
          }
          rethrow;
        }
      }

      for (final inbox in allUnread) {
        if (inbox.message != null) {
          await messageDao.insertMessage(inbox.message!);
        }
      }
    } catch (e) {
      log("$e");
    }

    await fetchAllConversationsFromServer();
  }

  Future<void> fetchAllConversationsFromServer() async {
    int page = 1;
    const int limit = 50;
    List<Conversation> all = [];

    try {
      while (true) {
        try {
          final resp = await messageService.getMyConversations(
            page: page,
            limit: limit,
          );

          if (resp.data == null) {
            break;
          }

          all.addAll(resp.data!.list);

          final total = resp.data!.total;
          final loadedCount = all.length;

          if (loadedCount >= total || resp.data!.list.length < limit) break;

          page++;
        } catch (e) {
          if (e.toString().contains('Any conversation found')) {
            break;
          }
          rethrow;
        }
      }

      final sorted = _sortConversations(all);

      if (!mounted) return;
      state = state.copyWith(conversations: sorted, error: null);

      for (final conv in sorted) {
        await conversationDao.upsertFull(conv);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        error: 'Failed to fetch conversations: ${e.toString()}',
      );
      rethrow;
    }
  }

  Future<void> upsertConversation(Conversation conv) async {
    if (!mounted) return;

    final list = [...state.conversations];
    final index = list.indexWhere((c) => c.id == conv.id);

    Conversation merged;

    if (index >= 0) {
      final old = list[index];

      final mergedLastMessage = _mergeLastMessage(
        old.lastMessage,
        conv.lastMessage,
      );

      final newUpdatedAt = mergedLastMessage?.createdAt ?? conv.updatedAt;
      final finalUpdatedAt = newUpdatedAt.isAfter(old.updatedAt)
          ? newUpdatedAt
          : old.updatedAt;

      final mergedUsers = conv.users.isNotEmpty
          ? conv.users.map((newU) {
              if (newU.user != null) return newU;
              final oldU = old.users.firstWhere(
                (o) => o.userId == newU.userId,
                orElse: () => newU,
              );
              if (oldU.user == null) return newU;
              return ConversationUser(
                id: newU.id,
                conversationId: newU.conversationId,
                userId: newU.userId,
                agentSupportId: newU.agentSupportId,
                role: newU.role,
                joinedAt: newU.joinedAt,
                user: oldU.user,
                agentSupport: newU.agentSupport ?? oldU.agentSupport,
              );
            }).toList()
          : old.users;

      merged = old.copyWith(
        name: conv.name ?? old.name,
        lastMessage: mergedLastMessage,
        lastMessageId: mergedLastMessage?.id ?? old.lastMessageId,
        unreadCount: conv.unreadCount,
        updatedAt: finalUpdatedAt,
        users: mergedUsers,
      );

      list.removeAt(index);
    } else {
      merged = conv;
    }

    list.insert(0, merged);

    final sorted = _sortConversations(list);
    if (!mounted) return;
    state = state.copyWith(conversations: sorted);

    await conversationDao.upsertBasic(merged);
  }

  /// 排序逻辑（支持聊天置顶，然后按最新消息排前面）
  List<Conversation> _sortConversations(List<Conversation> list) {
    final sorted = [...list];

    sorted.sort((a, b) {
      final aIsSupport = a.name?.startsWith('userToSupport') ?? false;
      final bIsSupport = b.name?.startsWith('userToSupport') ?? false;

      if (aIsSupport && !bIsSupport) {
        return -1;
      }
      if (!aIsSupport && bIsSupport) {
        return 1;
      }

      final aTime = a.lastMessage?.createdAt ?? a.updatedAt;
      final bTime = b.lastMessage?.createdAt ?? b.updatedAt;
      return bTime.compareTo(aTime);
    });

    return sorted;
  }

  int get totalUnreadCount {
    return state.conversations.fold<int>(
      0,
      (sum, conv) => sum + conv.unreadCount,
    );
  }

  Future<void> markConversationAsRead(int conversationId) async {
    await conversationDao.updateUnreadCount(conversationId, 0);

    if (!mounted) return;

    final list = state.conversations.map((c) {
      if (c.id == conversationId) {
        return c.copyWith(unreadCount: 0);
      }
      return c;
    }).toList();

    final sorted = _sortConversations(list);
    if (!mounted) return;
    state = state.copyWith(conversations: sorted);
  }
}

String? _lastUserId;

final conversationListProvider =
    StateNotifierProvider<ConversationListNotifier, ConversationListState>((
      ref,
    ) {
      final userId = ref.watch(currentUserIdProvider);
      final isNewUser = userId != _lastUserId;
      _lastUserId = userId;

      if (userId == null) {
        final service = ref.read(messageServiceProvider);
        final tempDb = AppDatabase(userId: "");
        final dao = ConversationDao(tempDb);
        final messageDao = MessageDao(tempDb);
        return ConversationListNotifier(service, dao, messageDao);
      }

      final service = ref.read(messageServiceProvider);
      final db = ref.read(currentUserDatabaseProvider);
      final dao = ConversationDao(db);
      final messageDao = MessageDao(db);
      return ConversationListNotifier(
        service,
        dao,
        messageDao,
        autoLoad: isNewUser,
      );
    });

final totalUnreadCountProvider = Provider<int>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.isVisitor) {
    return 0;
  }

  final conversations = ref.watch(conversationListProvider).conversations;
  return conversations.fold<int>(0, (sum, conv) => sum + conv.unreadCount);
});
