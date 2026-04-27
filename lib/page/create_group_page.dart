import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/page/select_members_page.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/html_text_field.dart';
import 'package:live_app/widgets/vip_badge.dart';

import '../provider/api_provider.dart';
import '../provider/conversation_list_provider.dart';
import 'group_chat_detail_page.dart';

class CreateGroupPage extends ConsumerStatefulWidget {
  const CreateGroupPage({super.key});

  @override
  ConsumerState<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends ConsumerState<CreateGroupPage> {
  final TextEditingController _groupNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<UserInfo> _selectedMembers = [];
  bool _isCreating = false;
  String _isPublic = "public";
  File? _groupAvatarFile;
  String? _selectedDefaultAvatar;

  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.white),
              title: Text(
                translate("gallery"),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() {
                    _groupAvatarFile = File(image.path);
                    _selectedDefaultAvatar = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                translate("camera"),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 512,
                  maxHeight: 512,
                  imageQuality: 85,
                );
                if (image != null) {
                  setState(() {
                    _groupAvatarFile = File(image.path);
                    _selectedDefaultAvatar = null;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.grid_view, color: Colors.white),
              title: Text(
                translate("chooseDefaultAvatar"),
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _showDefaultAvatars();
              },
            ),
            if (_groupAvatarFile != null || _selectedDefaultAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(
                  translate("removeAvatar"),
                  style: const TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _groupAvatarFile = null;
                    _selectedDefaultAvatar = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showDefaultAvatars() {
    final defaultAvatars = [
      'assets/group_avatars/default_1.png',
      'assets/group_avatars/default_2.png',
      'assets/group_avatars/default_3.png',
      'assets/group_avatars/default_4.png',
      'assets/group_avatars/default_5.png',
      'assets/group_avatars/default_6.png',
    ];

    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          translate("selectDefaultAvatar"),
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: defaultAvatars.length,
            itemBuilder: (context, index) {
              final avatar = defaultAvatars[index];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDefaultAvatar = avatar;
                    _groupAvatarFile = null;
                  });
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _selectedDefaultAvatar == avatar
                          ? Colors.blue
                          : Colors.grey[700]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Icon(Icons.group, size: 48, color: Colors.grey[600]),
                    // TODO: Remplacer par Image.asset(avatar) quand les assets existent
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              translate("cancel"),
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectMembers() async {
    final result = await Navigator.push<List<UserInfo>>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectMembersPage(initialSelected: _selectedMembers),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedMembers.clear();
        _selectedMembers.addAll(result);
      });
    }
  }

  void _removeMember(UserInfo user) {
    setState(() {
      _selectedMembers.removeWhere((u) => u.id == user.id);
    });
  }

  Future<void> _createGroup() async {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final groupName = _groupNameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate("description")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedMembers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(translate("pleaseSelectAtLeastTwoMembers")),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final messageService = ref.read(messageServiceProvider);
      final userIds = _selectedMembers.map((u) => u.id).toList();

      final resp = await messageService.createGroup(
        name: groupName,
        userIds: userIds,
        description: _descriptionController.text.trim(),
        visibility: _isPublic,
        avatarUrl: "",
      );

      if (!mounted) return;

      if (resp.code == 1 && resp.data != null) {
        final conversationId = resp.data!.conversationId;

        await ref
            .read(conversationListProvider.notifier)
            .fetchAllConversationsFromServer();

        if (!mounted) return;

        final conversationListState = ref.read(conversationListProvider);
        final conversation = conversationListState.conversations.firstWhere(
          (c) => c.id == conversationId,
          orElse: () => throw Exception('Conversation not found'),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(translate("groupCreatedSuccessfully")),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GroupChatDetailPage(conversation: conversation),
          ),
        );
      } else {
        if (!mounted) return;
        debugPrint(resp.msg);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resp.msg), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${translate("error")}: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
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
        title: Text(translate("createGroup")),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: GestureDetector(
                      onTap: _pickAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[800],
                            backgroundImage: _groupAvatarFile != null
                                ? FileImage(_groupAvatarFile!)
                                : null,
                            child:
                                _groupAvatarFile == null &&
                                    _selectedDefaultAvatar == null
                                ? const Icon(
                                    Icons.group,
                                    size: 50,
                                    color: Colors.white54,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "${translate("name")} *",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  HtmlTextField(
                    controller: _groupNameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: translate("enterGroupName"),
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),

                  // Description du groupe
                  Text(
                    translate("description"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  HtmlTextField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: translate("enterGroupDescription"),
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    maxLength: 200,
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate("publicGroup"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              translate(
                                _isPublic == "public"
                                    ? "anyoneCanFindAndJoin"
                                    : "inviteOnlyNotSearchable",
                              ),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isPublic == "public",
                          onChanged: (value) {
                            setState(
                              () => _isPublic = value ? "public" : "private",
                            );
                          },
                          activeThumbColor: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${translate("members")} (${_selectedMembers.length}) *",
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
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: Text(
                            translate("addMembers"),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (_selectedMembers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.people_outline,
                              size: 48,
                              color: Colors.white38,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              translate("noMembersSelected"),
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _selectedMembers.length,
                      itemBuilder: (context, index) {
                        final user = _selectedMembers[index];
                        return Card(
                          color: Colors.grey[900],
                          margin: const EdgeInsets.only(bottom: 8),
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
                                                user.nickname?.substring(
                                                      0,
                                                      1,
                                                    ) ??
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
                            subtitle: user.bio != null
                                ? Text(
                                    user.bio!,
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                color: Colors.red,
                              ),
                              onPressed: () => _removeMember(user),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),

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
                  onPressed: _isCreating ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isCreating
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.grey[800],
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          translate("createGroup"),
                          style: TextStyle(
                            color: Colors.grey[800],
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
