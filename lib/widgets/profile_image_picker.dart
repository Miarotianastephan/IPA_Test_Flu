import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/widgets/encrypted_image.dart';

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
      child: _buildAvatar(context, displayChar),
    );
  }

  Widget _buildAvatar(BuildContext context, String displayChar) {
    Widget avatarWidget;

    if (widget.avatar != null) {
      avatarWidget = FutureBuilder<ImageProvider>(
        future: _getImageProvider(widget.avatar),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildCircleAvatarWithImage(snapshot.data);
          }
          return _buildCircleAvatarPlaceholder(context, displayChar);
        },
      );
    } else if (widget.avatarUrl != null) {
      avatarWidget = _buildCircleAvatarWithEncryptedImage(context, displayChar);
    } else {
      avatarWidget = _buildCircleAvatarPlaceholder(context, displayChar);
    }

    if (widget.isEditing) {
      return Stack(
        children: [
          avatarWidget,
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(Icons.edit, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      );
    }

    return avatarWidget;
  }

  Widget _buildCircleAvatarWithEncryptedImage(
    BuildContext context,
    String displayChar,
  ) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      child: ClipOval(
        child: EncryptedImage(
          url: widget.avatarUrl!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
          placeholder: Container(
            color: Colors.grey[300],
            child: Center(
              child: Text(
                displayChar,
                style: TextStyle(
                  fontSize: 30.0,
                  color: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
            ),
          ),
          errorWidget: Center(
            child: Text(
              displayChar,
              style: TextStyle(
                fontSize: 30.0,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleAvatarWithImage(ImageProvider? backgroundImage) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      backgroundImage: backgroundImage,
    );
  }

  Widget _buildCircleAvatarPlaceholder(
    BuildContext context,
    String displayChar,
  ) {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.grey[300],
      child: Text(
        displayChar,
        style: TextStyle(
          fontSize: 30.0,
          color: Theme.of(context).colorScheme.onSecondary,
        ),
      ),
    );
  }

  Future<ImageProvider> _getImageProvider(dynamic avatar) async {
    if (kIsWeb) {
      final bytes = await avatar.readAsBytes();
      return MemoryImage(bytes);
    } else {
      return FileImage(File(avatar.path));
    }
  }
}
