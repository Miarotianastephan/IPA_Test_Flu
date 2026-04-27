import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/widgets/encrypted_image.dart';

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
      onTap:
          widget.coverUrl == null && widget.cover == null && !widget.isEditing
          ? null
          : widget.onTap,
      child: _buildCoverContainer(context),
    );
  }

  Widget _buildCoverContainer(BuildContext context) {
    Widget coverWidget;

    if (widget.cover != null) {
      coverWidget = FutureBuilder<ImageProvider>(
        future: _getImageProvider(widget.cover),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return _buildContainerWithImage(
              context,
              DecorationImage(image: snapshot.data!, fit: BoxFit.cover),
            );
          }
          return _buildContainerPlaceholder(context);
        },
      );
    } else if (widget.coverUrl != null) {
      coverWidget = _buildContainerWithEncryptedImage(context);
    } else {
      coverWidget = _buildContainerPlaceholder(context);
    }

    if (widget.isEditing && (widget.cover != null || widget.coverUrl != null)) {
      return Stack(
        children: [
          coverWidget,
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
              ),
              child: const Center(
                child: Icon(Icons.edit, color: Colors.white, size: 40),
              ),
            ),
          ),
        ],
      );
    }

    return coverWidget;
  }

  Widget _buildContainerWithEncryptedImage(BuildContext context) {
    return Container(
      height: 175,
      width: double.infinity,
      color: Colors.grey[200],
      child: EncryptedImage(
        url: widget.coverUrl!,
        width: double.infinity,
        height: 175,
        fit: BoxFit.cover,
        placeholder: Center(
          child: Icon(
            Icons.image_outlined,
            color: Theme.of(context).colorScheme.onSurface,
            size: 50.0,
          ),
        ),
        errorWidget: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface,
          size: 50.0,
        ),
      ),
    );
  }

  Widget _buildContainerWithImage(BuildContext context, DecorationImage image) {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200], image: image),
    );
  }

  Widget _buildContainerPlaceholder(BuildContext context) {
    return Container(
      height: 175,
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.grey[200]),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface,
          size: 50.0,
        ),
      ),
    );
  }

  Future<ImageProvider> _getImageProvider(XFile xFile) async {
    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      return MemoryImage(bytes);
    } else {
      return FileImage(File(xFile.path));
    }
  }
}
