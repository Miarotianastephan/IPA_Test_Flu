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
    return GestureDetector(
      onTap: widget.onTap,
      child: CircleAvatar(
        radius: 50,
        backgroundImage: widget.avatar != null
            ? FileImage(File(widget.avatar.path))
            : widget.avatarUrl != null
            ? NetworkImage(widget.avatarUrl!) as ImageProvider
            : null,
        child: widget.isEditing ? const Icon(Icons.mode, size: 50) : null,
      ),
    );
  }
}
