class MessageApi {
  static const String base = "/api/user/message";

  // 未读消息
  static const String unreadCount = "$base/unread/count";
  static const String unreadList = "$base/unread/list";

  // 历史
  static const String history = "$base/history";
  static const String historyClear = "$base/history/clear";

  //已读回调
  static const String read = "$base/read";

  // 撤回
  static const String revoke = "$base/revoke";

  // 会话
  static const String conversationList = "$base/conversation/list";
  static const String conversationBetween = "$base/conversation/between";

  // 群聊
  static const String groupCreate = "$base/group/create";
  static const String groupJoin = "$base/group/join";
  static const String groupDissolve = "$base/group/dissolve";
  static const String groupTransferOwner = "$base/group/owner/transfer";
  static const String groupSetAnAdmin = "$base/group/setAsAdmin";
  static const String groupLeave = "$base/group/leave";
  static const String groupKick = "$base/group/kick";
  static const String groupDelete = "$base/group/delete";
  static const String groupSearch = "$base/group/search";

  static const String groupInvite = "$base/group/invitation/invite";
  static const String groupInvitationApprove = "$base/group/invitation/approve";
  static const String groupInvitationDecline = "$base/group/invitation/decline";
  static const String groupInvitationAccept = "$base/group/invitation/accept";
  static const String groupInvitationReject = "$base/group/invitation/reject";

  // System notifications
  static const String notificationList = "$base/notification/list";
  static const String notificationMarkAsRead = "$base/notification/markAsRead";
  static const String notificationMarkAllAsRead =
      "$base/notification/markAllAsRead";
  static const String notificationDelete = "$base/notification/remove";

  static const String sendMessage = "$base/send";
  static const String conversationByMessageId = "$base/conversation/message_id";
}
