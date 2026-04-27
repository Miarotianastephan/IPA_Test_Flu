import 'package:drift/drift.dart';

import '../models/conversation.dart';
import '../models/conversation_user.dart';
import '../models/message.dart';
import '../models/userinfo.dart';
import '../models/agent_support.dart';
import 'app_database.dart';

extension ConversationMapper on Conversation {
  ConversationsCompanion toCompanion() {
    return ConversationsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      lastMessageId: Value(lastMessageId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      unreadCount: Value(unreadCount),
    );
  }
}

extension MessageMapper on Message {
  MessagesCompanion toCompanion() {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      senderId: Value(senderId),
      senderSupportId: Value(senderSupportId),
      content: Value(content),
      messageType: Value(messageType),
      isRevoked: Value(isRevoked),
      revokedAt: Value(revokedAt),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
      isSelf: Value(isSelf),
      sendFailed: Value(sendFailed),
    );
  }
}

extension UserInfoMapper on UserInfo {
  UserInfosCompanion toCompanion() {
    return UserInfosCompanion(
      id: Value(id),
      displayId: Value(displayId),
      username: Value(username),
      credential: Value(credential ?? ""),
      isVisitor: Value(isVisitor),
      isBindPass: Value(isBindPass),
      agentId: Value(agentId),
      inviteCode: Value(inviteCode ?? ""),
      level: Value(level),
      nextExp: Value(nextExp),
      levelName: Value(levelName),
      token: Value(token),
      avatar: Value(avatar),
      phone: Value(phone),
      bio: Value(bio),
      cover: Value(cover),
      nickname: Value(nickname ?? ""),
      fansCount: Value(fansCount),
      followCount: Value(followCount),
      likeCount: Value(likeCount),
      isFollowed: Value(isFollowed),
    );
  }
}

extension ConversationUserMapper on ConversationUser {
  ConversationUsersCompanion toCompanion() {
    return ConversationUsersCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      userId: Value(userId),
      agentSupportId: Value(agentSupportId),
      role: Value(role),
      joinedAt: Value(joinedAt),
    );
  }
}

extension AgentSupportMapper on AgentSupport {
  AgentSupportsCompanion toCompanion() {
    return AgentSupportsCompanion(
      id: Value(id),
      username: Value(username),
      loginId: Value(loginId),
      password: Value(password),
      role: Value(role),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      avatar: Value(avatar),
    );
  }
}
