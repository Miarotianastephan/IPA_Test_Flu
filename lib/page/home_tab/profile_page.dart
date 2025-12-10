import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/profile_utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../config/storage_config.dart';
import '../../l10n/app_localizations.dart';
import '../../models/userinfo.dart';
import '../../utils/toast_util.dart';
import '../../widgets/count_item.dart';
import '../../widgets/encrypted_image.dart';
import '../login/bind_password.dart';
import '../login/change_password.dart';
import '../login/login_with_username.dart';
import '../my/favorite_page.dart';
import '../my/history_page.dart';
import '../my/like_page.dart';
import '../my/my_fans_page.dart';
import '../my/my_follow_page.dart';
import '../my/settings_page.dart';
import '../my/user_info_page.dart';
import '../qrcode_page.dart';

class ProfileTabPage extends ConsumerStatefulWidget {
  const ProfileTabPage({super.key});

  @override
  ConsumerState<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends ConsumerState<ProfileTabPage> {
  UserInfo? _userInfo;
  bool _hasLoaded = false;
  bool _isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUserFromCache();
    });
  }

  Future<void> getUserFromCache() async {
    final data = await StorageService.instance.getValue("user_info");
    if (data != null && data.isNotEmpty) {
      final map = data is String ? jsonDecode(data) : data;
      setState(() {
        _userInfo = UserInfo.fromJson(map);
      });
    }
  }

  Future<void> saveUserInfoWithToken(UserInfo userInfo) async {
    await StorageService.instance.clearUserData();
    await StorageService.instance.setValue("token", userInfo.token);
    await StorageService.instance.setValue(
      "user_info",
      jsonEncode(userInfo.toJson()),
    );
  }

  void _navigate(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));

    await getUserFromCache();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    if (_userInfo == null) {
      return Center(
        child: const CircularProgressIndicator(color: Colors.white),
      );
    }
    final count = ref.watch(userFollowProvider(_userInfo!.id.toString()));

    return Container(
      color: Colors.black,
      child: RefreshIndicator(
        color: theme.colorScheme.onPrimary,
        backgroundColor: theme.colorScheme.primary,
        onRefresh: getUserFromCache,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            VisibilityDetector(
              key: const Key("profile-header"),
              onVisibilityChanged: (info) {
                if (!_hasLoaded && info.visibleFraction > 0) {
                  _hasLoaded = true;
                  getUserFromCache();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      userId: _userInfo?.id,
                      url: _userInfo?.avatar,
                      nickname: _userInfo?.nickname,
                      size: 70,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _userInfo?.nickname ?? "",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userInfo?.bio ?? localizations.noSignature,
                            style: const TextStyle(color: Colors.grey),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(
                                child: Text(
                                  "ID: ${_userInfo?.displayId ?? ''}",
                                  style: const TextStyle(color: Colors.grey),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_userInfo?.displayId != null)
                                IconButton(
                                  icon: const Icon(
                                    Icons.copy,
                                    size: 18,
                                    color: Colors.grey,
                                  ),
                                  tooltip: localizations.copyId,
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: _userInfo!.displayId.toString(),
                                      ),
                                    );
                                    ToastUtil.success(localizations.idCopied);
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (_userInfo?.isVisitor ?? true)
                                  ? theme.colorScheme.onSecondary
                                  : theme.colorScheme.error,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(40),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: _isLoggingOut
                                ? null
                                : () async {
                                    if (_userInfo?.isVisitor ?? true) {
                                      _navigate(
                                        context,
                                        const LoginWithUsernamePage(),
                                      );
                                    } else {
                                      setState(() {
                                        _isLoggingOut = true;
                                      });
                                      try {
                                        await ref
                                            .read(currentUserProvider.notifier)
                                            .logout(cleanCache: true);
                                        final visitorUser = ref.read(
                                          currentUserProvider,
                                        );
                                        if (visitorUser != null) {
                                          setState(() {
                                            _userInfo = visitorUser;
                                          });
                                        }
                                      } finally {
                                        setState(() {
                                          _isLoggingOut = false;
                                        });
                                      }
                                    }
                                  },
                            child: _isLoggingOut
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    (_userInfo?.isVisitor ?? true)
                                        ? localizations.login
                                        : localizations.logout,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.qr_code),
                      onPressed: () => _navigate(context, const QRCodePage()),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildCountItem(
                    localizations.followCount,
                    count.followCount ?? 0,
                    onTap: () => _navigate(context, const MyFollowPage()),
                  ),
                  buildCountItem(
                    localizations.fansCount,
                    count.fansCount ?? 0,
                    onTap: () => _navigate(context, const MyFansPage()),
                  ),
                  buildCountItem(
                    localizations.likeCount,
                    _userInfo?.likeCount ?? 0,
                  ),
                ],
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(localizations.userInfo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => requireLogin(
                localizations: localizations,
                action: () =>
                    _navigate(context, UserInfoPage(user: _userInfo!)),
                userInfo: _userInfo,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(localizations.favorites),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const FavoritePage()),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(localizations.history),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const HistoryPage()),
            ),
            ListTile(
              leading: const Icon(Icons.thumb_up),
              title: Text(localizations.likes),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const LikePage()),
            ),

            if (!isVisitorUser(_userInfo))
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text(localizations.changePassword),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigate(context, const ChangePasswordPage()),
              ),
            if (isVisitorUser(_userInfo))
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: Text(localizations.bindPassword),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigate(context, const BindPasswordPage()),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(localizations.settings),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const SettingsPage()),
            ),
          ],
        ),
      ),
    );
  }
}
