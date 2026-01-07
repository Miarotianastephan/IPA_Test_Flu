import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:live_app/models/conversation.dart';
import 'package:live_app/models/conversation_user.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/select_members_page.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/conversation_list_provider.dart';
import 'package:live_app/provider/conversation_provider.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/group_avatar_widget.dart';
import 'package:live_app/widgets/message/message_popup_menu_route.dart';

class GroupInfoPage extends ConsumerStatefulWidget {
  final Conversation conversation;
  final int conversationId;

  const GroupInfoPage({
    super.key,
    required this.conversation,
    required this.conversationId,
  });

  @override
  ConsumerState<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends ConsumerState<GroupInfoPage> {
  final List<UserInfo> _selectedMembers = [];

  @override
  void initState() {
    super.initState();
    // Refresh conversation data from database to get latest roles
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(conversationProvider(widget.conversationId).notifier)
          .refreshConversation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(conversationProvider(widget.conversationId));
    final conversation = chatState.conversation ?? widget.conversation;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final currentUserId = ref.watch(currentUserIdProvider);

    final currentUserMember = conversation.users.firstWhere(
      (u) => u.userId == currentUserId,
      orElse: () => ConversationUser(
        id: 0,
        conversationId: widget.conversationId,
        userId: currentUserId ?? 0,
        role: "member",
        joinedAt: DateTime.now(),
      ),
    );

    final bool isCurrentUserOwner = currentUserMember.role == "owner";

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Group Avatar
                        GroupAvatarWidget(
                          members: conversation.users,
                          size: 80,
                        ),
                        const SizedBox(width: 16),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Group Name
                            Text(
                              conversation.name ?? translate("groupChat"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Group Info (Bio/Description)
                            Text(
                              conversation.name != null
                                  ? "${conversation.users.length} ${translate("members")}"
                                  : translate("noGroupDescription"),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),

                            // Create Time
                            Text(
                              "${translate("created")}: ${DateFormat('MMM dd, yyyy').format(conversation.createdAt)}",
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Members Section
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      constraints: const BoxConstraints(
                        minHeight: 300,
                        maxHeight: 425,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  translate("members"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[800],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: TextButton.icon(
                                    onPressed: _selectMembers,
                                    icon: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    label: Text(
                                      translate("invite"),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(color: Colors.white12, height: 1),
                          Expanded(
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              itemCount: conversation.users.length,
                              separatorBuilder: (context, index) =>
                                  const Divider(
                                    color: Colors.white12,
                                    height: 0,
                                    indent: 72,
                                  ),
                              itemBuilder: (context, index) {
                                final member = conversation.users[index];
                                return _buildMemberItem(member, translate);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Leave Group Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showLeaveGroupDialog(translate),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            translate("leaveGroup"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Delete Group Button - Fixed at bottom
            if (isCurrentUserOwner)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border(
                    top: BorderSide(color: Colors.grey[900]!, width: 1),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showDeleteGroupDialog(translate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      translate("deleteGroup"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(
    ConversationUser member,
    String Function(String) translate,
  ) {
    final userInfo = member.user;
    final nickname =
        userInfo?.nickname ?? userInfo?.username ?? "User ${member.userId}";
    final avatar = userInfo?.avatar ?? "";

    final currentUserId = ref.watch(currentUserIdProvider);
    final chatState = ref.watch(conversationProvider(widget.conversationId));
    final conversation = chatState.conversation ?? widget.conversation;

    final currentUserMember = conversation.users.firstWhere(
      (u) => u.userId == currentUserId,
      orElse: () => ConversationUser(
        id: 0,
        conversationId: widget.conversationId,
        userId: currentUserId ?? 0,
        role: "member",
        joinedAt: DateTime.now(),
      ),
    );

    final bool isCurrentUserOwner = currentUserMember.role == "owner";
    final bool isNotMe = member.userId != currentUserId;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[800],
        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
        child: avatar.isEmpty
            ? Text(
                nickname[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        nickname,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        "@${member.role}",
        style: const TextStyle(color: Colors.white54, fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      trailing: (isCurrentUserOwner && isNotMe)
          ? Builder(
              builder: (buttonContext) {
                return IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  onPressed: () =>
                      _showMemberMenu(buttonContext, member, translate),
                );
              },
            )
          : null,
    );
  }

  void _showMemberMenu(
    BuildContext buttonContext,
    ConversationUser member,
    String Function(String) translate,
  ) async {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(buttonContext).context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    final double rightInset =
        overlay.size.width - (buttonPosition.dx + button.size.width);

    await Navigator.of(buttonContext).push(
      MessagePopupMenuRoute(
        duration: const Duration(milliseconds: 150),
        position: RelativeRect.fromLTRB(
          buttonPosition.dx,
          buttonPosition.dy + button.size.height - 10,
          rightInset,
          0,
        ),
        child: IntrinsicWidth(
          child: Material(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(8),
            elevation: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text(
                    translate("kick"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(buttonContext);
                    _handleKickMember(member, translate);
                  },
                ),
                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: Text(
                    translate("setAsAdmin"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(buttonContext);
                    _handleSetAsAdmin(member, translate);
                  },
                ),

                const Divider(color: Colors.white12, height: 1),
                ListTile(
                  title: Text(
                    translate("setAsOwner"),
                    style: const TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.pop(buttonContext);
                    _handleSetAsOwner(member, translate);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleKickMember(
    ConversationUser member,
    String Function(String) translate,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final userInfo = member.user;
        final nickname =
            userInfo?.nickname ?? userInfo?.username ?? "User ${member.userId}";

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            translate("confirmKick"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            "${translate("areYouSureKick")} $nickname?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translate("cancel"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                translate("kick"),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final notifier = ref.read(
        conversationProvider(widget.conversationId).notifier,
      );
      final response = await notifier.kickMember(member.userId);

      if (!mounted) return;

      if (response != 0) {
        // Remove the kicked member from the conversation immediately
        await notifier.removeMemberFromConversation(member.userId);

        // Refresh the conversation data from server
        await ref
            .read(conversationListProvider.notifier)
            .fetchAllConversationsFromServer();

        // Refresh the current conversation to update UI
        await ref
            .read(conversationProvider(widget.conversationId).notifier)
            .refreshConversation();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("memberKicked")),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("failedToKickMember")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleSetAsAdmin(
    ConversationUser member,
    String Function(String) translate,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final userInfo = member.user;
        final nickname =
            userInfo?.nickname ?? userInfo?.username ?? "User ${member.userId}";

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            translate("confirmSetAsAdmin"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            "${translate("areYouSureSetAsAdmin")} $nickname?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translate("cancel"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                translate("confirm"),
                style: const TextStyle(color: Colors.blue),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final notifier = ref.read(
        conversationProvider(widget.conversationId).notifier,
      );
      final success = await notifier.setUserAsGroupAdmin(
        member.userId.toString(),
      );

      if (!mounted) return;

      if (success) {
        // Refresh the conversation data from server
        await ref
            .read(conversationListProvider.notifier)
            .fetchAllConversationsFromServer();

        // Refresh the current conversation to update UI
        await ref
            .read(conversationProvider(widget.conversationId).notifier)
            .refreshConversation();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("setAsAdminSuccess")),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("failedToSetAsAdmin")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectMembers() async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final result = await Navigator.push<List<UserInfo>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMembersPage(initialSelected: _selectedMembers),
      ),
    );

    if (result != null && result.isNotEmpty) {
      if (!mounted) return;

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            translate("confirmInvite"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            "${translate("inviteUsers")} ${result.length} ${translate("usersToGroup")}?",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translate("cancel"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
              child: Text(translate("invite")),
            ),
          ],
        ),
      );

      if (!mounted) return;

      if (confirm == true) {
        // Send invitations
        final messageService = ref.read(messageServiceProvider);
        int successCount = 0;
        int failCount = 0;

        for (final user in result) {
          try {
            final response = await messageService.inviteUserToGroup(
              conversationId: widget.conversationId,
              userId: user.id.toString(),
            );

            if (response.code == 1) {
              successCount++;
            } else {
              failCount++;
            }
          } catch (e) {
            failCount++;
            debugPrint('Error inviting user ${user.id}: $e');
          }
        }

        if (!mounted) return;

        // Show result
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "$successCount ${translate("invitationsSent")}${failCount > 0 ? ", $failCount ${translate("failed")}" : ""}",
              ),
              backgroundColor: failCount == 0 ? Colors.green : Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(translate("failedToSendInvitations")),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _handleSetAsOwner(
    ConversationUser member,
    String Function(String) translate,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        final userInfo = member.user;
        final nickname =
            userInfo?.nickname ?? userInfo?.username ?? "User ${member.userId}";

        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            translate("confirmSetAsOwner"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            "${translate("areYouSureSetAsOwner")} $nickname? ${translate("youWillLoseOwnership")}",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translate("cancel"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                translate("confirm"),
                style: const TextStyle(color: Colors.amber),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final notifier = ref.read(
        conversationProvider(widget.conversationId).notifier,
      );
      final success = await notifier.transferOwnership(
        member.userId.toString(),
      );

      if (!mounted) return;

      if (success) {
        // Refresh the conversation data from server
        await ref
            .read(conversationListProvider.notifier)
            .fetchAllConversationsFromServer();

        // Refresh the current conversation to update UI
        await ref
            .read(conversationProvider(widget.conversationId).notifier)
            .refreshConversation();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("setAsOwnerSuccess")),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("failedToSetAsOwner")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLeaveGroupDialog(String Function(String) translate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            translate("confirmLeaveGroup"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            translate("youWillNotReceiveMessages"),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translate("cancel"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                translate("leave"),
                style: const TextStyle(color: Colors.orange),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final notifier = ref.read(
        conversationProvider(widget.conversationId).notifier,
      );
      final success = await notifier.leaveGroup();

      if (!mounted) return;

      if (success) {
        // Pop both the info page and the chat page
        Navigator.pop(context); // Pop info page
        Navigator.pop(context); // Pop chat page
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("failedToLeaveGroup")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDeleteGroupDialog(String Function(String) translate) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            translate("confirmDeleteGroup"),
            style: const TextStyle(color: Colors.white),
          ),
          content: Text(
            translate("actionCanNotBeUndoneDeleteGroup"),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                translate("cancel"),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                translate("delete"),
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      final notifier = ref.read(
        conversationProvider(widget.conversationId).notifier,
      );
      final success = await notifier.deleteGroup();

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("groupDeletedSuccess")),
            backgroundColor: Colors.green,
          ),
        );

        if (mounted) {
          // Pop both the info page and the chat page
          Navigator.pop(context); // Pop info page
          Navigator.pop(context); // Pop chat page
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("failedToDeleteGroup")),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
