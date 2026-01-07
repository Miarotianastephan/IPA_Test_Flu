import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

class LoadingDots extends ConsumerStatefulWidget {
  const LoadingDots({super.key});

  @override
  ConsumerState<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends ConsumerState<LoadingDots> {
  String _dots = "";
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) return;
      setState(() {
        _dots = _dots.length < 3 ? '$_dots.' : '';
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Text(
      '${i18n.translate('loading')}$_dots',
      style: const TextStyle(color: Colors.white70, fontSize: 16),
    );
  }
}
