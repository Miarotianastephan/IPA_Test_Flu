import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/download_page.dart';
import 'package:live_app/page/home.dart';
import 'package:live_app/page/home_audio.dart';
import 'package:live_app/page/home_manga.dart';
import 'package:live_app/page/home_roman.dart';
import 'package:live_app/provider/api_provider.dart';
import 'package:live_app/provider/current_user_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/manga_provider.dart';
import 'package:live_app/provider/roman_provider.dart';
import 'package:live_app/provider/user_follow_provider.dart';
import 'package:live_app/utils/profile_utils.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:visibility_detector/visibility_detector.dart';
import '../../config/storage_config.dart';
import '../../models/userinfo.dart';
import '../../utils/toast_util.dart';
import '../../widgets/count_item.dart';
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

enum ProfileOrigin { xo, manga, roman, audio }

class ProfileTabPage extends ConsumerStatefulWidget {
  final ProfileOrigin origin;
  const ProfileTabPage({super.key, required this.origin});

  @override
  ConsumerState<ProfileTabPage> createState() => _ProfileTabPageState();
}

class _ProfileTabPageState extends ConsumerState<ProfileTabPage> {
  UserInfo? _userInfo;
  bool _hasLoaded = false;
  bool _isLoggingOut = false;
  Map<String, dynamic>? _config;
  String translate(String key) =>
      ref.read(i18nNotifierProvider.notifier).translate(key);
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getUserFromCache();
    });
  }

  Future<void> getAppConfig() async {
    final appService = ref.read(appServiceProvider);
    try {
      final appConfig = await appService.appConfig();
      await StorageService.instance.setValue("app_config", appConfig.data);
      if (!mounted) return;
      setState(() {
        _config = appConfig.data;
      });
    } catch (e, st) {
      debugPrintStack(stackTrace: st);
    }
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

  void _navigate(BuildContext context, Widget page) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await getUserFromCache();
  }

  void _pushUntil(BuildContext context, Widget page) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final theme = Theme.of(context);
    if (_userInfo == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    final count = ref.watch(userFollowProvider(_userInfo!.id.toString()));

    final List<Widget> extraTiles = [];

    switch (widget.origin) {
      case ProfileOrigin.xo:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("manga")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(mangaProvider.future);
              _pushUntil(
                context,
                HomeMangaPage(items: response, config: _config),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("roman")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(romanProvider.future);
              _pushUntil(
                context,
                HomeRomanPage(config: _config, items: response),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(translate("audio")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              _pushUntil(context, HomeAudioPage(config: _config, items: []));
            },
          ),
        ]);
        break;

      case ProfileOrigin.manga:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Xo"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              _pushUntil(context, HomePage(config: _config));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("roman")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(romanProvider.future);
              _pushUntil(
                context,
                HomeRomanPage(config: _config, items: response),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(translate("audio")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              _pushUntil(context, HomeAudioPage(config: _config, items: []));
            },
          ),
        ]);
        break;

      case ProfileOrigin.roman:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Xo"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              _pushUntil(context, HomePage(config: _config));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("manga")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(mangaProvider.future);
              _pushUntil(
                context,
                HomeMangaPage(items: response, config: _config),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(translate("audio")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              _pushUntil(context, HomeAudioPage(config: _config, items: []));
            },
          ),
        ]);
        break;

      case ProfileOrigin.audio:
        extraTiles.addAll([
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Xo"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              _pushUntil(context, HomePage(config: _config));
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("manga")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(mangaProvider.future);
              _pushUntil(
                context,
                HomeMangaPage(items: response, config: _config),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book_rounded),
            title: Text(translate("roman")),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await getAppConfig();
              final response = await ref.read(romanProvider.future);
              _pushUntil(
                context,
                HomeRomanPage(config: _config, items: response),
              );
            },
          ),
        ]);
        break;
    }

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
                            _userInfo?.bio ?? translate("noSignature"),
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
                                  tooltip: translate("copyId"),
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: _userInfo!.displayId.toString(),
                                      ),
                                    );
                                    ToastUtil.success(translate("idCopied"));
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
                                        ? translate("login")
                                        : translate("logout"),
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
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildCountItem(
                    translate("followCount"),
                    count.followCount,
                    onTap: () => _navigate(context, const MyFollowPage()),
                  ),
                  buildCountItem(
                    translate("fansCount"),
                    count.fansCount,
                    onTap: () => _navigate(context, const MyFansPage()),
                  ),
                  buildCountItem(
                    translate("likeCount"),
                    _userInfo?.likeCount ?? 0,
                  ),
                ],
              ),
            ),
            const Divider(),
            ...extraTiles,
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(translate("userInfo")),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, UserInfoPage(user: _userInfo!)),
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: Text(translate("favorites")),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const FavoritePage()),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(translate("history")),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const HistoryPage()),
            ),
            ListTile(
              leading: const Icon(Icons.thumb_up),
              title: Text(translate("likes")),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const LikePage()),
            ),
            if (!isVisitorUser(_userInfo))
              ListTile(
                leading: const Icon(Icons.lock),
                title: Text(translate("changePassword")),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigate(context, const ChangePasswordPage()),
              ),
            if (isVisitorUser(_userInfo))
              ListTile(
                leading: const Icon(Icons.vpn_key),
                title: Text(translate("bindPassword")),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigate(context, const BindPasswordPage()),
              ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(translate("settings")),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigate(context, const SettingsPage()),
            ),
            if (!kIsWeb)
              ListTile(
                leading: const Icon(Icons.video_collection),
                title: Text(translate("downloadedContent")),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _navigate(context, const DownloadsPage()),
              ),
          ],
        ),
      ),
    );
  }
}
