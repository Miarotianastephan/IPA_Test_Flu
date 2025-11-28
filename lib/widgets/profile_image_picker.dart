import 'dart:io';
import 'package:flutter/material.dart';
import 'package:live_app/models/userinfo.dart';

class ProfileImagePicker extends StatefulWidget {
  final dynamic avatar;
  final String? avatarUrl;
  final bool isEditing;
  final VoidCallback? onTap;
  final UserInfo? user;
  const ProfileImagePicker({
    super.key,
    required this.avatar,
    required this.avatarUrl,
    required this.isEditing,
    this.onTap,
    required this.user,
  });
  @override
  State<ProfileImagePicker> createState() => _ProfileImagePickerState();
}

class _ProfileImagePickerState extends State<ProfileImagePicker> {
  @override
  Widget build(BuildContext context) {
    final displayChar =
        (widget.user!.nickname != null && widget.user!.nickname!.isNotEmpty)
        ? widget.user!.nickname![0]
        : "?";
    return GestureDetector(
      onTap:
          widget.avatarUrl == null && widget.avatar == null && !widget.isEditing
          ? null
          : widget.onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: widget.avatar != null
            ? FileImage(File(widget.avatar.path))
            : widget.avatarUrl != null
            ? NetworkImage(widget.avatarUrl!) as ImageProvider
            : null,
        child: widget.isEditing
            ? const Icon(Icons.mode, size: 50)
            : widget.avatarUrl == null && widget.avatar == null
            ? Text(
                displayChar,
                style: TextStyle(
                  fontSize: 40.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              )
            : null,
      ),
    );
  }
}
