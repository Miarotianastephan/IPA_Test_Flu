import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/conversation.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/select_members_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/vip_badge.dart';

import '../provider/api_provider.dart';

class AddGroupMembersPage extends ConsumerStatefulWidget {
  final Conversation conversation;

  const AddGroupMembersPage({super.key, required this.conversation});

  @override
  ConsumerState<AddGroupMembersPage> createState() =>
      _AddGroupMembersPageState();
}

class _AddGroupMembersPageState extends ConsumerState<AddGroupMembersPage> {
  List<UserInfo> _selectedMembers = [];
  bool _isAdding = false;

  Future<void> _selectMembers() async {
    final existingMemberIds = widget.conversation.users
        .map((u) => u.userId)
        .toSet();

    final result = await Navigator.push<List<UserInfo>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMembersPage(initialSelected: _selectedMembers),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMembers = result
            .where((user) => !existingMemberIds.contains(user.id))
            .toList();
      });
    }
  }

  Future<void> _addMembers() async {
    if (_selectedMembers.isEmpty) return;

    setState(() => _isAdding = true);

    try {
      final messageService = ref.read(messageServiceProvider);
      final memberIds = _selectedMembers.map((u) => u.id).toList();

      // TODO: Implémenter l'API pour ajouter des membres
      // await messageService.addGroupMembers(
      //   conversationId: widget.conversation.id,
      //   userIds: memberIds,
      // );

      if (!mounted) return;

      final i18n = ref.read(i18nNotifierProvider.notifier);
      String translate(String key) => i18n.translate(key);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate("membersAdded")),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      final i18n = ref.read(i18nNotifierProvider.notifier);
      String translate(String key) => i18n.translate(key);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${translate("error")}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isAdding = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(translate("addMembers")),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _selectMembers,
              icon: const Icon(Icons.person_add),
              label: Text(translate("selectMembers")),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
          if (_selectedMembers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "${translate("selected")}: ${_selectedMembers.length}",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ),
          Expanded(
            child: _selectedMembers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.white38,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          translate("noMembersSelected"),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedMembers.length,
                    itemBuilder: (context, index) {
                      final user = _selectedMembers[index];
                      return Card(
                        color: Colors.grey[900],
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.grey[800],
                            child: user.avatar == null
                                ? Text(
                                    user.nickname?.substring(0, 1) ?? "?",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  )
                                : ClipOval(
                                    child: Image.network(
                                      user.avatar!,
                                      width: 40,
                                      height: 40,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Text(
                                              user.nickname?.substring(0, 1) ??
                                                  "?",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ),
                                            );
                                          },
                                    ),
                                  ),
                          ),
                          title: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  user.nickname ?? "User ${user.id}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              VipBadge(vip: user.vip),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedMembers.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_selectedMembers.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(top: BorderSide(color: Colors.grey[800]!)),
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isAdding ? null : _addMembers,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      disabledBackgroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isAdding
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "${translate("add")} (${_selectedMembers.length})",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
