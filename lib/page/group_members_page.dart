import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/conversation.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/vip_badge.dart';

class GroupMembersPage extends ConsumerStatefulWidget {
  final Conversation conversation;

  const GroupMembersPage({super.key, required this.conversation});

  @override
  ConsumerState<GroupMembersPage> createState() => _GroupMembersPageState();
}

class _GroupMembersPageState extends ConsumerState<GroupMembersPage> {
  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final members = widget.conversation.users;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          "${translate("members")} (${members.length})",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              // TODO: Navigate to AddGroupMembersPage
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          final user = member.user;

          if (user == null) {
            return const SizedBox.shrink();
          }

          final isOwner = index == 0;

          return Card(
            color: Colors.grey[900],
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[800],
                child: user.avatar == null
                    ? Text(
                        user.nickname?.substring(0, 1) ?? "?",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          user.avatar!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Text(
                              user.nickname?.substring(0, 1) ?? "?",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            );
                          },
                        ),
                      ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.nickname ?? "User ${user.id}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        VipBadge(vip: member.user?.vip),
                      ],
                    ),
                  ),
                  if (isOwner)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        translate("owner"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              subtitle: user.bio != null
                  ? Text(
                      user.bio!,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  : null,
              trailing: !isOwner
                  ? PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      color: Colors.grey[900],
                      onSelected: (value) {
                        if (value == 'remove') {
                          _showRemoveMemberDialog(
                            user.id,
                            user.nickname ?? "User ${user.id}",
                          );
                        } else if (value == 'transfer') {
                          _showTransferOwnershipDialog(
                            user.id,
                            user.nickname ?? "User ${user.id}",
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'transfer',
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz, color: Colors.blue),
                              const SizedBox(width: 8),
                              Text(
                                translate("transferOwnership"),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              const Icon(
                                Icons.person_remove,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                translate("removeMember"),
                                style: const TextStyle(color: Colors.red),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showRemoveMemberDialog(String userId, String userName) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          translate("removeMember"),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "${translate("confirmRemoveMember")} $userName?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate("cancel")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _removeMember(userId);
            },
            child: Text(
              translate("remove"),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferOwnershipDialog(String userId, String userName) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          translate("transferOwnership"),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          "${translate("confirmTransferOwnership")} $userName?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(translate("cancel")),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _transferOwnership(userId);
            },
            child: Text(
              translate("transfer"),
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _removeMember(String userId) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    // TODO: Implement API call to remove member
    // final messageService = ref.read(messageServiceProvider);
    // await messageService.kickUser(
    //   conversationId: widget.conversation.id,
    //   targetUserId: userId,
    // );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate("memberRemoved")),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _transferOwnership(String userId) async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    // TODO: Implement API call to transfer ownership
    // final messageService = ref.read(messageServiceProvider);
    // await messageService.transferGroupOwner(
    //   conversationId: widget.conversation.id,
    //   newOwnerId: userId,
    // );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate("ownershipTransferred")),
        backgroundColor: Colors.green,
      ),
    );
  }
}
