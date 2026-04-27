import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/current_tab_provider.dart';
import 'package:live_app/provider/game_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/widgets/tiktok_scaffold.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'game_webview_stub.dart'
    if (dart.library.html) 'game_webview_web.dart'
    if (dart.library.io) 'game_webview_mobile.dart'
    as game_webview;

class GameTabPage extends ConsumerStatefulWidget {
  final TikTokScaffoldController? tkcontroller;

  const GameTabPage({super.key, this.tkcontroller});

  @override
  ConsumerState<GameTabPage> createState() => _GameTabPageState();
}

class _GameTabPageState extends ConsumerState<GameTabPage> {
  String? _gameUrl;
  bool _isLoading = false;
  String? _error;
  bool _inFullscreen = false;
  bool _initialCheckDone = false;

  Future<void> _loadAndLaunchGame() async {
    if (_isLoading || _inFullscreen) return;
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      String? gameUrl = ref.read(pendingGameUrlProvider);
      if (gameUrl != null) {
        ref.read(pendingGameUrlProvider.notifier).state = null;
      } else {
        gameUrl = await ref.read(gameListProvider.notifier).loginGame();
      }

      if (!mounted) return;
      if (gameUrl != null && gameUrl.isNotEmpty) {
        setState(() {
          _gameUrl = gameUrl;
          _isLoading = false;
        });
        _openFullscreenGame(gameUrl);
      } else {
        setState(() {
          _isLoading = false;
          _error = ref
              .read(i18nNotifierProvider.notifier)
              .translate('failedToLoadGame');
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = ref
            .read(i18nNotifierProvider.notifier)
            .translate('somethingWentWrong');
      });
    }
  }

  void _openFullscreenGame(String url) {
    _inFullscreen = true;
    Navigator.of(context)
        .push(
          MaterialPageRoute(builder: (_) => _FullscreenGamePage(gameUrl: url)),
        )
        .then((_) {
          _inFullscreen = false;
          ref.read(switchTabRequestProvider.notifier).state = 0;
        });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(currentTabIndexProvider, (prev, next) {
      final myIndex = ref.read(gameTabIndexProvider);
      if (next == myIndex && !_inFullscreen && !_isLoading) {
        _loadAndLaunchGame();
      }
    });

    if (!_initialCheckDone) {
      _initialCheckDone = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentIdx = ref.read(currentTabIndexProvider);
        final myIndex = ref.read(gameTabIndexProvider);
        if (currentIdx == myIndex &&
            myIndex >= 0 &&
            !_inFullscreen &&
            !_isLoading) {
          _loadAndLaunchGame();
        }
      });
    }

    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    translate("loadingGame"),
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              )
            : _error != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_esports_outlined,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadAndLaunchGame,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(translate("retry")),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.gamepad, size: 64, color: Colors.white),
                  SizedBox(height: 16),
                  Text(
                    translate("game"),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _FullscreenGamePage extends StatefulWidget {
  final String gameUrl;
  const _FullscreenGamePage({required this.gameUrl});

  @override
  State<_FullscreenGamePage> createState() => _FullscreenGamePageState();
}

class _FullscreenGamePageState extends State<_FullscreenGamePage> {
  Offset _buttonPosition = const Offset(20, 100);
  bool _dragged = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            game_webview.buildGameWebView(widget.gameUrl),
            Positioned(
              left: _buttonPosition.dx,
              top: _buttonPosition.dy,
              child: PointerInterceptor(
                child: GestureDetector(
                  onPanStart: (_) => _dragged = false,
                  onPanUpdate: (details) {
                    _dragged = true;
                    setState(() {
                      _buttonPosition += details.delta;
                    });
                  },
                  onPanEnd: (_) {
                    if (!_dragged) {
                      Navigator.pop(context);
                    }
                  },
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
