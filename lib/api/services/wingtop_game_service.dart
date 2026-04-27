import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:live_app/api/game_api.dart';
import 'package:live_app/api/services/base_service.dart';
import 'package:live_app/models/api_response.dart';
import 'package:live_app/models/wallet_balance.dart';

class WingtopGameService extends BaseService {
  WingtopGameService(super.client);

  Future<ApiResponse<WalletBalance>> recharge({required double amount}) async {
    return post<WalletBalance>(
      GameApi.recharge,
      body: {"amount": amount},
      fromJson: (json) => WalletBalance.fromJson(json),
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getFirstRecharge() async {
    return post<Map<String, dynamic>>(
      GameApi.getFirstRecharge,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getTotalRechargeAmount() async {
    return post<Map<String, dynamic>>(
      GameApi.getTotalRechargeAmount,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> getPlayDays() async {
    return post<Map<String, dynamic>>(
      GameApi.playDays,
      fromJson: (json) => json as Map<String, dynamic>,
    );
  }

  int getDeviceType() {
    if (kIsWeb) {
      return 4;
    } else if (Platform.isAndroid) {
      return 1;
    } else if (Platform.isIOS) {
      return 2;
    } else if (Platform.isWindows) {
      return 0;
    } else {
      return 3;
    }
  }
}
