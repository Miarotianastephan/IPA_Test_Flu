// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:live_app/api/api_client.dart';
import 'package:live_app/api/services/user_service.dart';
import 'package:live_app/l10n/app_localizations.dart';
import 'package:live_app/models/userinfo.dart';
import 'package:live_app/utils/toast_util.dart';
import 'package:live_app/widgets/cover_image_picker.dart';
import 'package:live_app/widgets/profile_image_picker.dart';
import 'package:live_app/widgets/save_button_edit_user.dart';
import 'package:live_app/widgets/text_field_widget.dart';
import 'package:path/path.dart';

class UserInfoPage extends StatefulWidget {
  final UserInfo? user;
  const UserInfoPage({super.key, required this.user});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  final _formKey = GlobalKey<FormState>();
  late String _username;
  late String _nickname;
  late String _bio;
  late String _phone;
  XFile? _avatar;
  XFile? _cover;

  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _username = widget.user!.username ?? '';
    _nickname = widget.user!.nickname ?? '';
    _bio = widget.user!.bio ?? '';
    _phone = widget.user!.phone ?? '';
  }

  Future<void> _pickAvatarImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _avatar = image;
        });
      }
    }
  }

  Future<void> _pickCoverImage(BuildContext context) async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseSource),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.gallery),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.camera),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _cover = image;
        });
      }
    }
  }

  Future<void> _saveProfileApi(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    final user = widget.user;
    if (user == null) {
      ToastUtil.warning(AppLocalizations.of(context)!.userNotFound);
      Navigator.pop(context, true);
      return;
    }

    setState(() => _saving = true);

    try {
      final Map<String, dynamic> data = {
        'username': _username,
        'nickname': _nickname,
        'bio': _bio,
        'phone': _phone,
      };

      if (_avatar != null) {
        data['avatar'] = await MultipartFile.fromFile(
          _avatar!.path,
          filename: basename(_avatar!.path),
        );
      }

      if (_cover != null) {
        data['cover'] = await MultipartFile.fromFile(
          _cover!.path,
          filename: basename(_cover!.path),
        );
      }

      final formData = FormData.fromMap(data);
      final response = await UserService(ApiClient()).updateInfo(formData);

      if (!mounted) return;

      if (response.success || response.code == 1) {
        ToastUtil.success(AppLocalizations.of(context)!.profileUpdated);

        setState(() {
          _saving = false;
          _isEditing = false;
        });
        Navigator.pop(context, true);
      } else {
        ToastUtil.error(AppLocalizations.of(context)!.serverError);
        debugPrint('Erreur serveur: ${response.msg}');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ToastUtil.error(AppLocalizations.of(context)!.networkError);
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.userInfo),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
            tooltip: _isEditing ? localizations.show : localizations.edit,
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          widget.user == null
              ? Center(child: Text(localizations.userInfoPageContent))
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            CoverImagePicker(
                              cover: _cover,
                              coverUrl: widget.user!.cover,
                              isEditing: _isEditing,
                              onTap: () {
                                _isEditing
                                    ? _pickCoverImage(context)
                                    : showDial(
                                        context,
                                        _cover ?? widget.user!.cover,
                                        widget.user!.cover != null
                                            ? false
                                            : true,
                                      );
                              },
                              user: widget.user,
                            ),
                            Positioned(
                              bottom: -50,
                              left: MediaQuery.of(context).size.width / 2 - 55,
                              child: ProfileImagePicker(
                                avatar: _avatar,
                                avatarUrl: widget.user!.avatar,
                                isEditing: _isEditing,
                                onTap: () {
                                  _isEditing
                                      ? _pickAvatarImage(context)
                                      : showDial(
                                          context,
                                          _avatar ?? widget.user!.avatar,
                                          widget.user!.avatar != null
                                              ? false
                                              : true,
                                        );
                                },
                                user: widget.user,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 80),
                        TextFieldWidget(
                          label: localizations.username,
                          icon: Icons.person_outline,
                          value: _username,
                          isEditing: _isEditing,
                          onSaved: (value) => _username = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: localizations.nickname,
                          icon: Icons.tag,
                          value: _nickname,
                          isEditing: _isEditing,
                          onSaved: (value) => _nickname = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: localizations.bio,
                          icon: Icons.description,
                          value: _bio,
                          isEditing: _isEditing,
                          onSaved: (value) => _bio = value ?? '',
                        ),
                        const SizedBox(height: 16),
                        TextFieldWidget(
                          label: localizations.phone,
                          icon: Icons.phone,
                          value: _phone,
                          isEditing: _isEditing,
                          onSaved: (value) => _phone = value ?? '',
                        ),
                        SizedBox(height: 20),
                        if (_isEditing)
                          SaveButtonEditUser(
                            onPressed: () {
                              _saveProfileApi(context);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
          if (_saving)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

void showDial(BuildContext context, dynamic image, bool isLocalFile) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "",
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: isLocalFile == true && image is XFile
                        ? FileImage(File(image.path))
                        : NetworkImage(image),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
