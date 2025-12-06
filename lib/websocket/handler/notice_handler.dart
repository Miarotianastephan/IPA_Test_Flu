import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/database/dao/conversation_dao.dart';
import 'package:live_app/database/dao/message_dao.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/conversation_user.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/conversation_list_provider.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:toastification/toastification.dart';

import '../../../models/in_app_notice.dart';
import '../../../protos/socket_message.pb.dart';
import '../../main.dart';
import '../../page/chat_detail_page.dart';
import '../../provider/conversation_provider.dart';
import 'msg_handler.dart';

class NoticeHandler extends MessageHandler {
  final Ref ref;

  NoticeHandler(this.ref);

  @override
  bool canHandle(SocketEnvelope env) {
    final body = env.body;

    if (!body.hasBusiness()) return false;

    final biz = body.business;

    // 系统通知
    if (biz.hasSystem()) return true;

    // 所有 IM 类型（Chat / Event / Bot）都进入通知
    if (biz.hasIm()) return true;

    return false;
  }

  @override
  void handle(SocketEnvelope env) async {
    final content = rootNavigatorKey.currentContext;
    if (content == null) return;
    final notice = await _convert(content, env);
    if (notice == null) return;

    //最后再弹出通知
    showNotice(content, notice);
  }

  Future<InAppNotice?> _convert(
    BuildContext content,
    SocketEnvelope env,
  ) async {
    final body = env.body.business;
    final localizations = AppLocalizations.of(content)!;

    if (body.hasSystem()) {
      final sys = body.system;
      return InAppNotice(title: sys.title, content: sys.body, onTap: () {});
    }

    if (body.hasIm()) {
      final im = body.im;

      if (im.hasChat()) {
        return await handleChatToNotice(content, env);
      }

      if (im.hasEvent()) {
        return InAppNotice(
          title: localizations.systemEvent,
          content: im.event.description,
          onTap: () {},
        );
      }

      if (im.hasBotMessage()) {
        final bot = im.botMessage;
        return InAppNotice(title: bot.botName, content: bot.text, onTap: () {});
      }

      if (im.hasBotCommand()) {
        return InAppNotice(
          title: localizations.botCommand,
          content: im.botCommand.command,
          onTap: () {},
        );
      }
    }

    return null;
  }

  void showNotice(BuildContext content, InAppNotice notice) {
    toastification.showCustom(
      context: content,
      autoCloseDuration: const Duration(seconds: 5),
      alignment: Alignment.topCenter,
      builder: (context, item) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              toastification.dismiss(item);
              notice.onTap();
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(0),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: UserAvatar(url: "${notice.avatarUrl}"),
                title: Text(
                  notice.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  notice.content,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54),
                ),
                trailing: Text(
                  TimeOfDay.fromDateTime(notice.time!).format(content),
                  style: const TextStyle(color: Colors.white38),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<InAppNotice?> handleChatToNotice(
    BuildContext content,
    SocketEnvelope env,
  ) async {
    // 先拿到 messageService
    final messageService = ref.read(messageServiceProvider);
    final localizations = AppLocalizations.of(content)!;

    // 根据 messageId 请求会话详情（包含这条消息）
    final rawMessageId = env.meta.messageId; // 这是一个 String
    final msgId = int.tryParse(rawMessageId) ?? 0;

    if (msgId == 0) {
      // messageId 异常情况，直接用 socket 里的内容构造一个简单通知
      final fallbackContent = env.body.business.im.chat.text;
      return InAppNotice(
        title: localizations.newMessage,
        content: fallbackContent,
        avatarUrl: null,
        time: DateTime.now(),
        onTap: () {},
      );
    }

    final convResp = await messageService.getConversationByMessageId(msgId);
    final convFromServer = convResp.data;

    if (convFromServer == null) {
      // 后端没返回会话，仍然至少弹一个通知
      final fallbackContent = env.body.business.im.chat.text;
      return InAppNotice(
        title: localizations.newMessage,
        content: fallbackContent,
        avatarUrl: null,
        time: DateTime.now(),
        onTap: () {},
      );
    }

    // 确保当前这条消息是未读的（后端可能已经标了 isRead，这里强制设为 false）
    final lastMsg = convFromServer.lastMessage?.copyWith(isRead: false);

    final convWithUnreadMsg = convFromServer.copyWith(
      lastMessage: lastMsg ?? convFromServer.lastMessage,
      lastMessageId:
          (lastMsg ?? convFromServer.lastMessage)?.id ??
          convFromServer.lastMessageId,
    );

    // 准备 Drift 相关的 DAO
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return null;
    }
    final db = ref.read(currentUserDatabaseProvider);
    final conversationDao = ConversationDao(db);
    final messageDao = MessageDao(db);

    // 检查本地是否已有这个会话
    final localConv = await conversationDao.getFullById(convWithUnreadMsg.id);

    if (lastMsg != null) {
      if (localConv == null) {
        // 本地没有：插入会话 + 消息（完整 upsert），未读数从 1 开始
        final newConv = convWithUnreadMsg.copyWith(unreadCount: 1);
        await conversationDao.upsertFull(newConv);

        // 会话列表也插入这条会话
        ref.read(conversationListProvider.notifier).upsertConversation(newConv);
      } else {
        // 本地已有会话：只插入这条消息，并把未读数 +1
        await messageDao.insertMessage(lastMsg);

        final updatedConv = localConv.copyWith(
          lastMessageId: lastMsg.id,
          lastMessage: lastMsg,
          unreadCount: localConv.unreadCount + 1,
          updatedAt: lastMsg.createdAt,
        );

        await conversationDao.upsertBasic(updatedConv);

        // 同步到会话列表
        ref
            .read(conversationListProvider.notifier)
            .upsertConversation(updatedConv);
      }
    }

    // 从会话里找到与 senderId 匹配的用户，拿头像和昵称
    final senderId = env.meta.fromUser;
    ConversationUser? senderUser; // 类型沿用 convFromServer.users 元素类型
    for (final u in convFromServer.users) {
      final uidInt = u.userId; // int
      final senderIdInt = senderId.toInt(); // Int64 → int
      if (uidInt == senderIdInt) {
        senderUser = u;
        break;
      }
    }

    final senderNickname =
        senderUser?.user?.nickname ?? localizations.newMessage;
    final senderAvatar = senderUser?.user?.avatar ?? "";

    final textContent = env.body.business.im.chat.text;

    // 当前正在聊天的会话 ID
    final currentConvId = ref.read(currentConversationIdProvider);

    // 如果当前打开的会话刚好与这条消息的会话一致
    if (currentConvId == convWithUnreadMsg.id) {
      // 找到对应的 ChatController
      final controller = ref.read(
        chatControllerProvider(senderUser!.userId).notifier,
      );

      // 把消息加到当前聊天窗口
      controller.addMessageToStateOnly(
        lastMsg!.copyWith(isRead: false, isSelf: false),
      );

      // 不再弹通知
      return null;
    }

    return InAppNotice(
      title: senderNickname,
      content: textContent,
      avatarUrl: senderAvatar,
      time: DateTime.now(),
      onTap: () {
        Navigator.push(
          content,
          MaterialPageRoute(
            builder: (_) => ChatDetailPage(user: senderUser!.user!),
          ),
        );
      },
    );
  }
}
