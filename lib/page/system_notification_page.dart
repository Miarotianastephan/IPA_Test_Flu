import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/conversation.dart';
import 'package:live_app/models/system_notification.dart';
import 'package:live_app/page/group_chat_detail_page.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/conversation_list_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/system_notification_provider.dart';
import 'package:live_app/utils/toast_util.dart';

import '../widgets/empty_widget.dart';

class SystemNotificationPage extends ConsumerStatefulWidget {
  const SystemNotificationPage({super.key});

  @override
  ConsumerState<SystemNotificationPage> createState() =>
      _SystemNotificationPageState();
}

class _SystemNotificationPageState
    extends ConsumerState<SystemNotificationPage> {
  int? _expandedNotificationId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(systemNotificationProvider.notifier).loadNotifications();
    });
  }

  Future<void> _handleGroupInvitationAction({
    required BuildContext context,
    required WidgetRef ref,
    required SystemNotification notification,
    required String action,
  }) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final metadata = notification.metadata;
    if (metadata == null) return;

    final invitationId = metadata['invitation_id'] is int
        ? metadata['invitation_id'] as int
        : int.tryParse(metadata['invitation_id']?.toString() ?? '');
    final conversationId = metadata['conversation_id'] is int
        ? metadata['conversation_id'] as int
        : int.tryParse(metadata['conversation_id']?.toString() ?? '');
    final groupName = metadata['group_name'] as String?;
    final visibility = metadata['visibility'] as String? ?? 'public';
    final inviterRole = metadata['inviter_role'] as String? ?? 'member';

    if (invitationId == null || conversationId == null) return;

    final isPublicGroup = visibility == 'public';
    final isAdminOrOwner = inviterRole == 'admin' || inviterRole == 'owner';
    final isDirectJoin = isPublicGroup || isAdminOrOwner;

    if (action == 'accept') {
      try {
        final messageService = ref.read(messageServiceProvider);

        if (isDirectJoin) {
          // Direct join: Public group OR Admin/Owner invitation
          final response = await messageService.acceptInvitation(
            invitationId: invitationId,
          );

          if (!context.mounted) return;

          if (response.code == 1) {
            // Fetch updated conversations
            await ref
                .read(conversationListProvider.notifier)
                .fetchAllConversationsFromServer();

            if (!context.mounted) return;

            // Navigate to group chat
            final conversationState = ref.read(conversationListProvider);
            final conversation = conversationState.conversations.firstWhere(
              (c) => c.id == conversationId,
              orElse: () => Conversation(
                id: conversationId,
                type: 'group',
                name: groupName,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => GroupChatDetailPage(conversation: conversation),
              ),
            );

            ToastUtil.success(translate("joinedGroupSuccessfully"));
          } else {
            ToastUtil.error(response.msg);
          }
        } else {
          // Private group + Regular member invitation = Wait for admin approval
          final response = await messageService.acceptInvitation(
            invitationId: invitationId,
          );

          if (!context.mounted) return;

          if (response.code == 1) {
            // Synchronize conversation list even for pending approval
            await ref
                .read(conversationListProvider.notifier)
                .fetchAllConversationsFromServer();

            ToastUtil.info(translate("invitationAcceptedWaitingApproval"));
          } else {
            ToastUtil.error(response.msg);
          }
        }
      } catch (e) {
        if (!context.mounted) return;
      }
    } else if (action == 'decline') {
      // Decline the invitation
      try {
        final messageService = ref.read(messageServiceProvider);
        final response = await messageService.rejectInvitation(
          invitationId: invitationId,
        );

        if (!context.mounted) return;

        if (response.code == 1) {
          ToastUtil.warning(translate("invitationDeclined"));
        } else {
          ToastUtil.error(response.msg);
        }
      } catch (e) {
        if (!context.mounted) return;
      }
    }

    setState(() {
      _expandedNotificationId = null;
    });
  }

  Future<void> _handleInvitationApprovalAction({
    required BuildContext context,
    required WidgetRef ref,
    required SystemNotification notification,
    required bool approve,
  }) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final metadata = notification.metadata;
    if (metadata == null) return;

    // Handle both int and string types from backend
    final invitationId = metadata['invitation_id'] is int
        ? metadata['invitation_id'] as int
        : int.tryParse(metadata['invitation_id']?.toString() ?? '');

    if (invitationId == null) return;

    // Call API to approve or decline invitation
    try {
      final messageService = ref.read(messageServiceProvider);
      final response = approve
          ? await messageService.approveInvitation(invitationId: invitationId)
          : await messageService.declineInvitation(invitationId: invitationId);

      if (!context.mounted) return;

      if (response.code == 1) {
        final message = approve
            ? translate("invitationApproved")
            : translate("invitationDeclined");

        approve ? ToastUtil.success(message) : ToastUtil.warning(message);
      } else {
        ToastUtil.error(response.msg);
      }
    } catch (e) {
      if (!context.mounted) return;
    }

    setState(() {
      _expandedNotificationId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final notificationState = ref.watch(systemNotificationProvider);
    final notifications = notificationState.notifications;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(translate('systemNotification')),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(systemNotificationProvider.notifier).markAllAsRead();
              },
              child: Text(
                translate("markAllAsRead"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: EmptyWidget(
                icon: Icons.notifications_none,
                message: translate("noNotifications"),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                final isUnread = !notification.isRead;
                final isExpanded = _expandedNotificationId == notification.id;

                return _buildExpandableNotificationTile(
                  notification: notification,
                  isUnread: isUnread,
                  isExpanded: isExpanded,
                );
              },
            ),
    );
  }

  Widget _buildExpandableNotificationTile({
    required SystemNotification notification,
    required bool isUnread,
    required bool isExpanded,
  }) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Card(
      color: isUnread ? Colors.grey[850] : Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: _getNotificationIconColor(notification.type),
              child: Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 24,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.content,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(notification.createdAt),
                  style: const TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
            trailing: isUnread
                ? Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  )
                : null,
            onTap: () {
              ref
                  .read(systemNotificationProvider.notifier)
                  .markAsRead(notification.id);

              // Only toggle expansion for actionable notifications
              if (_isActionableNotification(notification.type)) {
                setState(() {
                  if (_expandedNotificationId == notification.id) {
                    _expandedNotificationId = null;
                  } else {
                    _expandedNotificationId = notification.id;
                  }
                });
              }
            },
          ),
          // Expandable action buttons with animation
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: isExpanded
                ? _buildActionButtons(notification, translate)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Determines if a notification type requires action buttons
  bool _isActionableNotification(String type) {
    return type ==
            NotificationTypes
                .groupInvitation || // Invitee: Accept/Decline invitation
        type ==
            NotificationTypes
                .invitationPending || // Inviter: Approve/Decline join request
        type ==
            NotificationTypes
                .groupInvitationApproval || // Inviter: Approve/Decline (legacy)
        type == NotificationTypes.joinGroup; // View group after join
  }

  Widget _buildActionButtons(
    SystemNotification notification,
    String Function(String) translate,
  ) {
    switch (notification.type) {
      // INVITEE SIDE: Someone invited you to a group
      case NotificationTypes.groupInvitation:
        return _buildInviteeButtons(notification, translate);

      // INVITER/ADMIN SIDE: Someone wants to join your group (needs approval)
      case NotificationTypes.invitationPending:
      case NotificationTypes.groupInvitationApproval:
        return _buildInviterApprovalButtons(notification, translate);

      // INFORMATIONAL: Someone joined (can view the group)
      case NotificationTypes.joinGroup:
        return _buildJoinGroupButtons(notification, translate);

      default:
        return const SizedBox.shrink();
    }
  }

  /// INVITEE SIDE: Buttons for when you receive a group invitation
  Widget _buildInviteeButtons(
    SystemNotification notification,
    String Function(String) translate,
  ) {
    final metadata = notification.metadata;
    final visibility = metadata?['visibility'] as String? ?? 'public';
    final inviterRole = metadata?['inviter_role'] as String? ?? 'member';
    final isPublicGroup = visibility == 'public';
    final isAdminOrOwner = inviterRole == 'admin' || inviterRole == 'owner';
    final isDirectJoin = isPublicGroup || isAdminOrOwner;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              _handleGroupInvitationAction(
                context: context,
                ref: ref,
                notification: notification,
                action: 'decline',
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(translate("decline")),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              _handleGroupInvitationAction(
                context: context,
                ref: ref,
                notification: notification,
                action: 'accept',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text(
              isDirectJoin ? translate("joinGroup") : translate("accept"),
            ),
          ),
        ],
      ),
    );
  }

  /// INVITER/ADMIN SIDE: Buttons for approving someone's join request
  Widget _buildInviterApprovalButtons(
    SystemNotification notification,
    String Function(String) translate,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              _handleInvitationApprovalAction(
                context: context,
                ref: ref,
                notification: notification,
                approve: false,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            child: Text(translate("decline")),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              _handleInvitationApprovalAction(
                context: context,
                ref: ref,
                notification: notification,
                approve: true,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text(translate("approve")),
          ),
        ],
      ),
    );
  }

  /// INFORMATIONAL: Buttons for join group notification
  Widget _buildJoinGroupButtons(
    SystemNotification notification,
    String Function(String) translate,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () {
              // Just collapse and mark as read
              setState(() {
                _expandedNotificationId = null;
              });
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: BorderSide(color: Colors.grey[700]!),
            ),
            child: Text(translate("cancel")),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              // Handle view group action
              final metadata = notification.metadata;
              final conversationId =
                  metadata != null && metadata['conversation_id'] is int
                  ? metadata['conversation_id'] as int
                  : int.tryParse(
                      metadata?['conversation_id']?.toString() ?? '',
                    );

              if (conversationId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GroupChatDetailPage(conversationId: conversationId),
                  ),
                );
              }

              setState(() {
                _expandedNotificationId = null;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: Text(translate("viewGroup")),
          ),
        ],
      ),
    );
  }

  Color _getNotificationIconColor(String type) {
    switch (type) {
      // ACTIONABLE - Blue tones (requires user action)
      case NotificationTypes.groupInvitation:
        return Colors.blue[700]!; // Invitee: New invitation
      case NotificationTypes.invitationPending:
      case NotificationTypes.groupInvitationApproval:
        return Colors.orange[700]!; // Inviter: Needs approval

      // SUCCESS - Green tones
      case NotificationTypes.joinGroup:
        return Colors.green[700]!; // Someone joined
      case NotificationTypes.invitationAccepted:
        return Colors.green[600]!; // Invitation accepted
      case NotificationTypes.invitationApproved:
        return Colors.teal[700]!; // Join approved

      // REJECTION - Red/Grey tones
      case NotificationTypes.invitationDeclined:
        return Colors.red[700]!; // Invitation declined
      case NotificationTypes.invitationToJoinRejected:
        return Colors.red[800]!; // Join rejected

      // SYSTEM - Special colors
      case NotificationTypes.warning:
        return Colors.amber[800]!;
      case NotificationTypes.announcement:
        return Colors.purple[700]!;
      case NotificationTypes.info:
        return Colors.blue[600]!;

      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      // INVITEE SIDE: Receiving invitation
      case NotificationTypes.groupInvitation:
        return Icons.mail; // Envelope icon for receiving invitation

      // INVITER/ADMIN SIDE: Pending approval request
      case NotificationTypes.invitationPending:
      case NotificationTypes.groupInvitationApproval:
        return Icons.pending_actions; // Pending action for approval needed

      // SUCCESS STATES
      case NotificationTypes.joinGroup:
        return Icons.group_add; // Someone joined your group
      case NotificationTypes.invitationAccepted:
        return Icons.check_circle_outline; // Invitation was accepted
      case NotificationTypes.invitationApproved:
        return Icons.verified_user; // Join request was approved

      // REJECTION STATES
      case NotificationTypes.invitationDeclined:
        return Icons.cancel_outlined; // Invitation was declined
      case NotificationTypes.invitationToJoinRejected:
        return Icons.block; // Join request was rejected

      // SYSTEM NOTIFICATIONS
      case NotificationTypes.warning:
        return Icons.warning_amber;
      case NotificationTypes.announcement:
        return Icons.campaign;
      case NotificationTypes.info:
        return Icons.info_outline;

      default:
        return Icons.notifications;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
