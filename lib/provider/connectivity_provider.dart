import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/utils/app_lang_version_utils.dart';

class ConnectivityState {
  final List<ConnectivityResult> connectivityResults;
  final bool hasInternet;
  final bool isChecking;

  ConnectivityState({
    required this.connectivityResults,
    required this.hasInternet,
    this.isChecking = false,
  });

  bool get isOffline =>
      connectivityResults.contains(ConnectivityResult.none) || !hasInternet;

  ConnectivityState copyWith({
    List<ConnectivityResult>? connectivityResults,
    bool? hasInternet,
    bool? isChecking,
  }) {
    return ConnectivityState(
      connectivityResults: connectivityResults ?? this.connectivityResults,
      hasInternet: hasInternet ?? this.hasInternet,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityState>((ref) {
      return ConnectivityNotifier();
    });

class ConnectivityNotifier extends StateNotifier<ConnectivityState> {
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio();
  Timer? _probeTimer;
  bool _isDisposed = false;

  ConnectivityNotifier()
    : super(
        ConnectivityState(
          connectivityResults: [ConnectivityResult.none],
          hasInternet: false,
        ),
      ) {
    _init();
  }

  Future<void> _init() async {
    final results = await _connectivity.checkConnectivity();
    state = state.copyWith(connectivityResults: results);
    await checkInternet();

    _connectivity.onConnectivityChanged.listen((results) {
      if (_isDisposed) return;
      state = state.copyWith(connectivityResults: results);
      checkInternet();
    });

    _probeTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => checkInternet(),
    );
  }

  Future<void> checkInternet() async {
    if (_isDisposed) return;

    if (AppLangVersionUtils.isCn() || AppLangVersionUtils.isTk()) {
      state = state.copyWith(hasInternet: true, isChecking: false);
      return;
    }

   if (state.connectivityResults.contains(ConnectivityResult.none)) {
      state = state.copyWith(hasInternet: false, isChecking: false);
      return;
    }

    state = state.copyWith(isChecking: true);

    final hasNet = await _probeInternet();

    if (!_isDisposed) {
      state = state.copyWith(hasInternet: hasNet, isChecking: false);
    }
  }

  Future<bool> _probeInternet() async {
    try {
      final response = await _dio.get(
        'https://www.google.com/generate_204',
        options: Options(
          receiveTimeout: const Duration(seconds: 5),
          sendTimeout: const Duration(seconds: 5),
          validateStatus: (status) => status != null,
        ),
      );
      return response.statusCode == 204 || response.statusCode == 200;
    } catch (_) {
      try {
        final result = await InternetAddress.lookup('google.com');
        return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      } catch (e) {
        debugPrint('Internet probe failed: $e');
        return false;
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _probeTimer?.cancel();
    super.dispose();
  }
}
