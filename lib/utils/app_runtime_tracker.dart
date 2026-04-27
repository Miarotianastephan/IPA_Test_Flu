import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/behavior_tracker_provider.dart';
import 'package:live_app/provider/message_dispatcher_provider.dart';
import 'package:live_app/widgets/ad_popup.dart';

class AppRuntimeTracker extends ConsumerStatefulWidget {
  final Widget child;

  const AppRuntimeTracker({super.key, required this.child});

  @override
  ConsumerState<AppRuntimeTracker> createState() => _AppRuntimeTrackerState();
}

class _AppRuntimeTrackerState extends ConsumerState<AppRuntimeTracker>
    with WidgetsBindingObserver {
  DateTime? _appStartTime;
  DateTime? _pauseTime;
  Timer? _durationTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appStartTime = DateTime.now();
    _durationTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _trackSessionDuration();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _durationTimer?.cancel();
    _trackSessionDuration();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_pauseTime != null) {
          _appStartTime = DateTime.now();
          _pauseTime = null;
        }
        break;
      case AppLifecycleState.paused:
        _trackSessionDuration();
        _pauseTime = DateTime.now();
        break;
      default:
        break;
    }
  }

  void _trackSessionDuration() {
    if (_appStartTime == null) return;

    final duration = DateTime.now().difference(_appStartTime!);
    final seconds = duration.inSeconds;
    if (seconds > 0) {
      ref.trackStayDuration(seconds);
    }
    _appStartTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(globalInitializerProvider);
    ref.watch(userBehaviorStatsProvider);
    ref.watch(behaviorTrackerProvider);

    ref.listen(triggeredAdProvider, (previous, next) {
      if (next == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AdPopup.show(context, ad: next).catchError((error, stackTrace) {
          debugPrint('[AdPopup.show] $error');
          debugPrint(stackTrace.toString());
        });
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        ref.read(triggeredAdProvider.notifier).state = null;
      });
    });

    return widget.child;
  }
}
