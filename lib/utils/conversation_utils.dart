import '../models/conversation.dart';
import '../models/conversation_user.dart';

bool isSupportConversation(Conversation conversation) {
  if (conversation.name?.startsWith('support') == true) return true;
  if (conversation.name?.startsWith('userToSupport') == true) return true;
  return conversation.users.any((u) => isSupportAgent(u));
}

bool isSupportAgent(ConversationUser? convUser) {
  if (convUser == null) return false;
  if (convUser.isSupportAgent == true) return true;
  if (convUser.agentSupportId != null) return true;
  if (convUser.agentSupport != null) return true;
  return false;
}

String getSupportAgentDisplayName(ConversationUser? convUser) {
  if (convUser == null ||
      convUser.agentSupport?.username == "customer_service") {
    return "客服白兔";
  }
  return convUser.agentSupport?.username ?? "客服白兔";
}

String? getSupportAgentAvatar(ConversationUser? convUser) {
  return convUser?.agentSupport?.avatar;
}
