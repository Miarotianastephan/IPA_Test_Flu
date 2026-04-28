import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/page/chinese_promotion_dialog.dart';
import 'package:live_app/page/base_home.dart';
import 'package:live_app/page/user_profile_page.dart';
import 'package:live_app/provider/app_config_provider.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/reduction_provider.dart';
import 'package:live_app/utils/app_runtime_tracker.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';

import '/page/home_tab/home_page.dart';
import '/page/home_tab/profile_page.dart';
import '../models/notif_chinese.dart';
import '../provider/current_user_provider.dart';
import '../widgets/tiktok_scaffold.dart';
import 'home_tab/forum_page.dart';
import 'home_tab/game_page.dart';
import 'home_tab/message_page.dart';
import 'home_tab/video_page.dart';
import 'promotion_dialog.dart';

class HomePage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? config;
  const HomePage({super.key, this.config});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late final TikTokScaffoldController _tkController;
  final Map<int, Timer> _reductionTimers = {};
  final List<int> _pendingReductionIds = [];
  bool _isDialogShowing = false;
  int? _currentlyShowingReductionId;
  ProviderSubscription<int>? _tabSubscription;

  @override
  void initState() {
    super.initState();
    _tkController = TikTokScaffoldController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.trackLoadingComplete();
      _showPromotionOrReduction();
      _listenToTabChanges();
    });
  }

  void _listenToTabChanges() {
    _tabSubscription = ref.listenManual<int>(currentTabIndexProvider, (
      previous,
      next,
    ) {
      final gameTabIndex = ref.read(gameTabIndexProvider);
      final wasOnGameTab = gameTabIndex >= 0 && previous == gameTabIndex;
      final isOnGameTab = gameTabIndex >= 0 && next == gameTabIndex;
      if (wasOnGameTab && !isOnGameTab) {
        _showNextPendingDialog();
      }
    });
  }

  void _startReductionTimer(int reductionId) {
    if (!AppLangVersionUtils.isYd()) return;
    _reductionTimers[reductionId]?.cancel();

    final reductionState = ref.read(reductionProvider);
    final reduction = reductionState.unclaimedReductions
        .where((r) => r.gameReduction?.id == reductionId)
        .firstOrNull;
    if (reduction == null) return;

    final defaultInterval =
        ref.read(appConfigProvider).data?.reductionInterval ?? 60;
    final configuredInterval = reduction.gameReduction?.time ?? defaultInterval;
    final interval =
        configuredInterval > 0 ? configuredInterval : defaultInterval;

    _reductionTimers[reductionId] = Timer(
      Duration(seconds: interval),
      () => _queueReductionDialog(reductionId),
    );
  }

  void _queueReductionDialog(int reductionId) {
    if (_pendingReductionIds.contains(reductionId)) {
      return;
    }
    if (_currentlyShowingReductionId == reductionId) {
      return;
    }
    _pendingReductionIds.add(reductionId);
    _showNextPendingDialog();
  }

  bool _isOnGameTab() {
    final currentTabIndex = ref.read(currentTabIndexProvider);
    final gameTabIndex = ref.read(gameTabIndexProvider);
    return gameTabIndex >= 0 && currentTabIndex == gameTabIndex;
  }

  void _showNextPendingDialog() {
    if (_isDialogShowing || _pendingReductionIds.isEmpty || !mounted) return;
    if (_isOnGameTab()) return;
    final reductionId = _pendingReductionIds.removeAt(0);
    _showPromotionDialog(reductionId, false);
  }

  void _cancelAllTimers() {
    for (final timer in _reductionTimers.values) {
      timer.cancel();
    }
    _reductionTimers.clear();
  }

  @override
  void dispose() {
    _tabSubscription?.close();
    _cancelAllTimers();
    super.dispose();
  }

  Future<void> _showPromotionOrReduction() async {
    await _showChinesePromotionIfNeeded();
    if (AppLangVersionUtils.isYd()) {
      await _loadReductionIfNeeded();
      if (!mounted) return;
      _showInitialReductions();
    }
  }

  Future<void> _loadReductionIfNeeded() async {
    final reductionState = ref.read(reductionProvider);
    if (reductionState.reductionList.isNotEmpty || reductionState.isLoading) {
      return;
    }

    try {
      await ref.read(reductionProvider.notifier).loadReduction();
    } catch (e) {
      debugPrint('Error loading reduction in home: $e');
    }
  }

  void _showInitialReductions() {
    final reductionState = ref.read(reductionProvider);
    final unclaimedReductions = reductionState.unclaimedReductions;

    for (final reduction in unclaimedReductions) {
      final reductionId = reduction.gameReduction?.id;
      final amount = reduction.gameReduction?.reductionAmount ?? 0;
      if (reductionId != null && amount > 0) {
        _queueReductionDialog(reductionId);
      }
    }
  }

  Future<void> _showChinesePromotionIfNeeded() async {
    final appConfigState = ref.read(appConfigProvider);
    final notifChinese = appConfigState.data?.textNotif;
    if (notifChinese != null && mounted) {
      await _showChinesePromotionDialog(notifChinese);
    }
  }

  Future<void> _showChinesePromotionDialog(NotifChinese notifChinese) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ChinesePromotionDialog(
        notifChinese: notifChinese,
        onClose: () {
          Navigator.of(dialogContext).pop();
        },
      ),
    );
  }

  void _showPromotionDialog(int reductionId, bool claimed) {
    final reductionState = ref.read(reductionProvider);
    final reduction = reductionState.reductionList
        .where((r) => r.gameReduction?.id == reductionId)
        .firstOrNull;
    final reductionData = reduction?.gameReduction;
    if (reductionData == null) {
      _showNextPendingDialog();
      return;
    }

    _isDialogShowing = true;
    _currentlyShowingReductionId = reductionId;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PromotionDialog(
        reductionData: reductionData,
        onClose: () {
          Navigator.of(dialogContext).pop();
          _isDialogShowing = false;
          _currentlyShowingReductionId = null;
          _startReductionTimer(reductionId);
          _showNextPendingDialog();
        },
        onCta: () async {
          Navigator.of(dialogContext).pop();
          _isDialogShowing = false;
          _currentlyShowingReductionId = null;
          _reductionTimers[reductionId]?.cancel();
          _reductionTimers.remove(reductionId);
          final url = await ref
              .read(reductionProvider.notifier)
              .createUserReduction(reductionId, true);
          if (url != null) {
            ref.read(pendingGameUrlProvider.notifier).state = url;
          }
          final gameIndex = ref.read(gameTabIndexProvider);
          if (gameIndex >= 0) {
            ref.read(switchTabRequestProvider.notifier).state = gameIndex;
          }
          _showNextPendingDialog();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      if (widget.config?['enable_video'] == true)
        HomeTabPage(tkcontroller: _tkController),
      if (widget.config?['enable_video'] == true)
        VideoTabPage(tkcontroller: _tkController),
      if (widget.config?['enable_community'] == true)
        ForumTabPage(tkcontroller: _tkController),
      if (widget.config?['chat_enable'] == true)
        MessageTabPage(appConfig: widget.config),
      if (widget.config?['enable_game'] == true)
        GameTabPage(tkcontroller: _tkController),
      Consumer(
        builder: (context, ref, _) {
          final currentUser = ref.watch(currentUserProvider);
          if (currentUser == null) return const SizedBox.shrink();
          return UserProfilePage(
            user: currentUser,
            onShowSettings: () {
              Navigator.of(context).push(
                PageRouteBuilder(
                  opaque: false,
                  barrierDismissible: true,
                  barrierColor: Colors.black54,
                  transitionDuration: const Duration(milliseconds: 300),
                  reverseTransitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1, 0),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.85,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color(0xFF1A1A1A),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(16),
                              ),
                            ),
                            child: ProfileTabPage(
                              origin: ProfileOrigin.xo,
                              onBack: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    ];
    final i18nAsync = ref.watch(i18nNotifierProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18nAsync.when(
          data: (translations) => i18n.translate(key),
          loading: () => key,
          error: (error, stackTrace) => key,
        );
    List<Map<String, dynamic>> navItems = [
      if (widget.config?['enable_video'] == true)
        {"icon": Icons.home, "label": translate("home"), "key": "home"},
      if (widget.config?['enable_video'] == true)
        {"icon": Icons.videocam, "label": translate("video"), "key": "video"},
      if (widget.config?['enable_community'] == true)
        {
          "icon": Icons.groups,
          "label": translate("community"),
          "key": "community",
        },
      if (widget.config?['chat_enable'] == true)
        {
          "icon": Icons.bubble_chart,
          "label": translate("message"),
          "key": "message",
        },
      if (widget.config?['enable_game'] == true)
        {
          "icon": Icons.videogame_asset,
          "label": translate("game"),
          "key": "game",
        },
      {"icon": Icons.person, "label": translate("profile"), "key": "profile"},
    ];
    final gameIdx = navItems.indexWhere((item) => item["key"] == "game");
    Future(() => ref.read(gameTabIndexProvider.notifier).state = gameIdx);
    final profileIdx = navItems.indexWhere((item) => item["key"] == "profile");
    Future(() => ref.read(profileTabIndexProvider.notifier).state = profileIdx);
    return AppRuntimeTracker(
      child: BaseHome(
        pages: pages,
        navItems: navItems,
        controller: _tkController,
        // rightPage: Consumer(
        //   builder: (context, ref, _) {
        //     final user = ref.watch(currentVideoUserProvider);
        //     return user != null
        //         ? UserDetailPage(
        //             user: user,
        //             cover: user.cover,
        //             tkController: _tkController,
        //           )
        //         : const EmptyWidget();
        //   },
        // ),
      ),
    );
  }
}
