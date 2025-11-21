import 'dart:io';

import 'package:flutter/material.dart';
import 'package:live_app/models/userinfo.dart';

class CoverImagePicker extends StatefulWidget {
  final dynamic cover;
  final String? coverUrl;
  final bool isEditing;
  final VoidCallback? onTap;
  final UserInfo? user;

  const CoverImagePicker({
    super.key,
    required this.cover,
    required this.coverUrl,
    required this.isEditing,
    this.onTap,
    required this.user,
  });

  @override
  State<CoverImagePicker> createState() => _CoverImagePickerState();
}

class _CoverImagePickerState extends State<CoverImagePicker> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          image: widget.cover != null
              ? DecorationImage(
                  image: FileImage(File(widget.cover!.path)),
                  fit: BoxFit.cover,
                )
              : widget.coverUrl != null
              ? DecorationImage(
                  image: NetworkImage(widget.coverUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: widget.isEditing ? const Icon(Icons.mode, size: 50) : null,
      ),
    );
  }
}
