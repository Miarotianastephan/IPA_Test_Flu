import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/utils/json_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/content_access_response.dart';
import '../models/payment_channel.dart';
import '../models/payment_order_create_response.dart';
import '../models/time_package.dart';
import '../provider/api_provider.dart';
import '../provider/currency_provider.dart';
import '../provider/current_user_provider.dart';
import '../provider/i18n_provider.dart';
import '../provider/payment_flow_provider.dart';
import '../provider/purchased_post_provider.dart';
import '../provider/purchased_video_provider.dart';
import '../provider/wallet_provider.dart';
import '../services/content_access_service.dart';
import '../services/video_payment_polling_service.dart';
import '../widgets/payment/payment_channel_popup.dart';
import '../widgets/payment/payment_method_choice_dialog.dart';
import '../widgets/payment/payment_status_overlay.dart';
import '../widgets/payment/recharge_amount_popup.dart';

class PaymentOrchestrator {
  final BuildContext context;
  final ProviderContainer _container;

  PaymentOrchestrator(WidgetRef ref, this.context)
    : _container = ProviderScope.containerOf(context, listen: false);

  String _getCurrencySymbol() {
    final currencyState = _container.read(currencyProvider);
    return currencyState.currencySymbol;
  }

  String _getCurrencyCode() {
    final currencyState = _container.read(currencyProvider);
    return currencyState.currencyCode;
  }

  void _invalidatePurchasedContentProviders(String contentType) {
    if (contentType == 'video' || contentType == 'long_video') {
      _container.invalidate(purchasedVideoProvider);
      return;
    }

    if (contentType == 'posts') {
      _container.invalidate(purchasedPostProvider);
    }
  }

  Future<bool> purchaseContent({
    required String contentType,
    required String contentId,
    required double price,
    required String contentTitle,
  }) async {
    try {
      final walletState = _container.read(walletProvider);

      final result = await _showPaymentMethodChoice(
        contentType: contentType,
        contentId: contentId,
        price: price,
        contentTitle: contentTitle,
        currentBalance: walletState.balance?.balance ?? 0.0,
      );

      return result;
    } catch (e) {
      debugPrint('Error purchasing $contentType: $e');
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> purchaseContentWithVipDiscount({
    required String contentType,
    required String contentId,
    required double price,
    required String contentTitle,
  }) async {
    try {
      final contentAccessService = _container.read(
        contentAccessServiceProvider,
      );
      final i18n = _container.read(i18nNotifierProvider.notifier);
      final walletState = _container.read(walletProvider);
      final accessResponse = await contentAccessService.checkContentAccess(
        contentType: contentType,
        contentId: contentId,
      );

      if (!context.mounted) return false;

      if (accessResponse.hasAccess) {
        return true;
      }

      if (!accessResponse.requiresPayment) {
        if (context.mounted) {
          await PaymentStatusOverlay.showFailure(
            context: context,
            errorMessage: i18n.translate('contentNotAvailableForPurchase'),
          );
        }
        return false;
      }

      final finalPrice = accessResponse.price ?? price;

      if (accessResponse.isVipDiscount &&
          accessResponse.originalPrice != null) {
        await _showVipDiscountInfo(accessResponse);
      }

      // Always show payment method choice dialog
      return await _showPaymentMethodChoiceVip(
        contentType: contentType,
        contentId: contentId,
        price: finalPrice,
        contentTitle: contentTitle,
        currentBalance: walletState.balance?.balance ?? 0.0,
      );
    } catch (e) {
      debugPrint('Error purchasing $contentType with VIP discount: $e');
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<void> _showVipDiscountInfo(
    ContentAccessResponse accessResponse,
  ) async {
    if (!context.mounted) return;

    final i18n = _container.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final currencySymbol = _getCurrencySymbol();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber),
            const SizedBox(width: 8),
            Text(translate('vipDiscountApplied')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${translate('originalPrice')}: $currencySymbol${accessResponse.originalPrice!.toStringAsFixed(2)}',
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${translate('vipDiscount')}: ${accessResponse.discountPercentage}% ${translate('off')}',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${translate('finalPrice')}: $currencySymbol${accessResponse.price!.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${translate('youSave')}: $currencySymbol${accessResponse.discountAmount.toStringAsFixed(2)}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(translate('continue')),
          ),
        ],
      ),
    );
  }

  /// Generic purchase content using wallet balance (direct, no VIP discount)
  Future<bool> _purchaseContentWithWallet({
    required String contentType,
    required String contentId,
  }) async {
    try {
      final userService = _container.read(userServiceProvider);
      final walletNotifier = _container.read(walletProvider.notifier);
      PaymentStatusOverlay.showProcessing(context: context);

      final response = await userService.buyContent(contentType, contentId);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return false;

      if (response.data != null) {
        walletNotifier.refresh();
        _invalidatePurchasedContentProviders(contentType);

        if (context.mounted) {
          await PaymentStatusOverlay.showSuccess(
            context: context,
            orderNo:
                '${contentType.toUpperCase()}-${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  /// Generic purchase content using wallet balance with VIP discount support
  Future<bool> _purchaseContentWithWalletVip({
    required String contentType,
    required String contentId,
  }) async {
    try {
      final paymentService = _container.read(paymentServiceProvider);
      final walletNotifier = _container.read(walletProvider.notifier);

      PaymentStatusOverlay.showProcessing(context: context);

      // Purchase using payment service (which handles VIP discounts)
      final response = await paymentService.purchaseContentWithWallet(
        contentType: contentType,
        contentId: contentId,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return false;

      if (response.data != null) {
        walletNotifier.refresh();
        _invalidatePurchasedContentProviders(contentType);

        // Show success
        if (context.mounted) {
          await PaymentStatusOverlay.showSuccess(
            context: context,
            orderNo:
                '${contentType.toUpperCase()}-VIP-${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  Future<bool> _showPaymentMethodChoice({
    required String contentType,
    required String contentId,
    required double price,
    required String contentTitle,
    required double currentBalance,
  }) async {
    final choice = await PaymentMethodChoiceDialog.show(
      context: context,
      contentPrice: price,
      currentBalance: currentBalance,
      contentTitle: contentTitle,
    );

    if (choice == null || !context.mounted) {
      return false;
    }

    switch (choice) {
      case PaymentMethodChoice.walletPayment:
        return await _purchaseContentWithWallet(
          contentType: contentType,
          contentId: contentId,
        );

      case PaymentMethodChoice.directPayment:
        return await _purchaseContentWithDirectPayment(
          contentType: contentType,
          contentId: contentId,
          price: price,
          contentTitle: contentTitle,
        );

      case PaymentMethodChoice.rechargeWallet:
        final recharged = await rechargeWallet();
        if (!context.mounted) return false;
        if (recharged) {
          final walletState = _container.read(walletProvider);
          final balance = walletState.balance?.balance ?? 0.0;
          if (walletState.balance != null &&
              walletState.balance!.hasSufficientBalance(price)) {
            return await _purchaseContentWithWallet(
              contentType: contentType,
              contentId: contentId,
            );
          } else {
            return await _showPaymentMethodChoice(
              contentType: contentType,
              contentId: contentId,
              price: price,
              contentTitle: contentTitle,
              currentBalance: balance,
            );
          }
        }
        return false;
    }
  }

  Future<bool> _showPaymentMethodChoiceVip({
    required String contentType,
    required String contentId,
    required double price,
    required String contentTitle,
    required double currentBalance,
  }) async {
    final choice = await PaymentMethodChoiceDialog.show(
      context: context,
      contentPrice: price,
      currentBalance: currentBalance,
      contentTitle: contentTitle,
    );

    if (choice == null || !context.mounted) {
      return false;
    }

    switch (choice) {
      case PaymentMethodChoice.walletPayment:
        return await _purchaseContentWithWalletVip(
          contentType: contentType,
          contentId: contentId,
        );

      case PaymentMethodChoice.directPayment:
        return await _purchaseContentWithDirectPayment(
          contentType: contentType,
          contentId: contentId,
          price: price,
          contentTitle: contentTitle,
        );

      case PaymentMethodChoice.rechargeWallet:
        final recharged = await rechargeWallet();
        if (!context.mounted) return false;
        if (recharged) {
          final walletState = _container.read(walletProvider);
          final balance = walletState.balance?.balance ?? 0.0;
          if (walletState.balance != null &&
              walletState.balance!.hasSufficientBalance(price)) {
            return await _purchaseContentWithWalletVip(
              contentType: contentType,
              contentId: contentId,
            );
          } else {
            return await _showPaymentMethodChoiceVip(
              contentType: contentType,
              contentId: contentId,
              price: price,
              contentTitle: contentTitle,
              currentBalance: balance,
            );
          }
        }
        return false;
    }
  }

  /// Purchase content directly using payment channel (no wallet).
  /// Shows PaymentChannelPopup for user to select payment method.
  /// [onPurchased] is called once polling confirms the payment is successful.
  Future<bool> purchaseContentDirectly({
    required String contentType,
    required String contentId,
    required double price,
    required String contentTitle,
    VoidCallback? onPurchased,
  }) async {
    return _purchaseContentWithDirectPayment(
      contentType: contentType,
      contentId: contentId,
      price: price,
      contentTitle: contentTitle,
      onPurchased: onPurchased,
    );
  }

  Future<bool> _purchaseContentWithDirectPayment({
    required String contentType,
    required String contentId,
    required double price,
    required String contentTitle,
    VoidCallback? onPurchased,
  }) async {
    if (!context.mounted) return false;
    final i18n = _container.read(i18nNotifierProvider.notifier);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return false;

    final selectedChannel = await PaymentChannelPopup.show(
      context: context,
      amount: price,
      paymentType: 'resource_purchase',
    );

    if (selectedChannel == null || !context.mounted) {
      return false;
    }

    final order = await _createPaymentOrder(
      channel: selectedChannel,
      amount: price,
      bizType: 'resource',
      resourceType: contentType,
      bizId: contentId.toString(),
      productName: contentTitle,
      currency: _getCurrencyCode(),
      paymentMethod: 'direct',
      contentId: contentId,
      contentType: contentType,
    );

    if (order == null) {
      return false;
    }

    final success = await _openPaymentUrl(order.payUrl);
    if (!success) {
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: i18n.translate('couldNotOpenPaymentPage'),
        );
      }
      return false;
    }

    _startVideoPolling(
      contentId: contentId,
      contentType: contentType,
      orderId: order.orderId,
      onPurchased: onPurchased,
    );

    // Navigation is handled by onPurchased callback once polling confirms success.
    return false;
  }

  VideoPaymentPollingService? _activePolling;
  PollingDialogController? _pollingDialogController;

  void _startVideoPolling({
    required String contentId,
    required String contentType,
    required String orderId,
    bool refreshCurrentUser = false,
    VoidCallback? onPurchased,
  }) {
    _activePolling?.stop();
    _pollingDialogController?.dismiss();

    // Show polling dialog with cancel button
    if (context.mounted) {
      _pollingDialogController = PaymentStatusOverlay.showPollingPending(
        context: context,
        onCancel: () {
          _activePolling?.stop();
          _activePolling = null;
          _pollingDialogController = null;
        },
      );
    }

    _activePolling = VideoPaymentPollingService(
      paymentService: _container.read(paymentServiceProvider),
      contentId: contentId,
      contentType: contentType,
      onStatusChanged: (_) {},
      onPurchased: () async {
        _activePolling = null;
        _pollingDialogController?.dismiss();
        _pollingDialogController = null;
        final walletNotifier = _container.read(walletProvider.notifier);
        walletNotifier.refresh();
        _invalidatePurchasedContentProviders(contentType);
        if (refreshCurrentUser) {
          await _container.read(currentUserProvider.notifier).refreshUserInfo();
        }
        if (!context.mounted) return;
        await PaymentStatusOverlay.showSuccess(
          context: context,
          orderNo: orderId,
        );
        onPurchased?.call();
      },
      onError: (error) {
        debugPrint('Video polling error: $error');
      },
    );

    _activePolling!.start();
  }

  Future<bool> rechargeWallet({
    String? currency,
    VoidCallback? onPopupShown,
  }) async {
    try {
      if (!context.mounted) return false;

      final walletNotifier = _container.read(walletProvider.notifier);
      final i18n = _container.read(i18nNotifierProvider.notifier);

      // await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return false;

      await walletNotifier.loadRechargeAmounts();
      if (!context.mounted) return false;

      final userCurrency = currency ?? _getCurrencyCode();
      final currentContext = context;

      onPopupShown?.call();

      final selectedAmount = await RechargeAmountPopup.show(
        context: currentContext,
        currency: userCurrency,
      );

      if (selectedAmount == null || !context.mounted) {
        return false;
      }

      final selectedChannel = await PaymentChannelPopup.show(
        context: context,
        amount: selectedAmount.amount,
        paymentType: 'wallet_recharge',
      );

      if (selectedChannel == null || !context.mounted) {
        return false;
      }
      final order = await _createPaymentOrder(
        channel: selectedChannel,
        amount: selectedAmount.amount,
        bizType: 'recharge',
        productName: i18n.translate('walletRecharge'),
        currency: "CNY",
        paymentMethod: 'recharge',
      );

      if (order == null) {
        return false;
      }

      final success = await _openPaymentUrl(order.payUrl);
      if (!success) {
        if (context.mounted) {
          await PaymentStatusOverlay.showFailure(
            context: context,
            errorMessage: i18n.translate('couldNotOpenPaymentPage'),
          );
        }
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error recharging wallet: $e');
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> purchaseVipWithDirectPayment({
    required String vipId,
    required double price,
    required String vipName,
    VoidCallback? onPurchased,
  }) async {
    try {
      if (!context.mounted) return false;
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return false;

      final selectedChannel = await PaymentChannelPopup.show(
        context: context,
        amount: price,
        paymentType: 'vip_purchase',
      );

      if (selectedChannel == null || !context.mounted) {
        return false;
      }

      return _processVipDirectPayment(
        vipId: parseInt(vipId),
        price: price,
        vipName: vipName,
        channel: selectedChannel,
        onPurchased: onPurchased,
      );
    } catch (e) {
      debugPrint('Error purchasing VIP with direct payment: $e');
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> purchaseVipWithChannel({
    required int vipId,
    required double price,
    required String vipName,
    required PaymentChannel channel,
    String? contentId,
    String? contentType,
    VoidCallback? onPurchased,
  }) async {
    try {
      if (!context.mounted) return false;
      return _processVipDirectPayment(
        vipId: vipId,
        price: price,
        vipName: vipName,
        channel: channel,
        contentId: contentId,
        contentType: contentType,
        onPurchased: onPurchased,
      );
    } catch (e) {
      debugPrint('Error purchasing VIP with channel: $e');
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> _processVipDirectPayment({
    required int vipId,
    required double price,
    required String vipName,
    required PaymentChannel channel,
    String? contentId,
    String? contentType,
    VoidCallback? onPurchased,
  }) async {
    final i18n = _container.read(i18nNotifierProvider.notifier);
    final order = await _createPaymentOrder(
      channel: channel,
      amount: price,
      bizType: 'vip',
      bizId: vipId.toString(),
      productName: vipName,
      currency: _getCurrencyCode(),
      paymentMethod: 'direct',
      vipId: vipId,
    );

    if (order == null) {
      return false;
    }

    final success = await _openPaymentUrl(order.payUrl);
    if (!success) {
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: i18n.translate('couldNotOpenPaymentPage'),
        );
      }
      return false;
    }

    _startVideoPolling(
      contentId: contentId ?? vipId.toString(),
      contentType: contentType ?? 'vip',
      orderId: order.orderId,
      refreshCurrentUser: true,
      onPurchased: onPurchased,
    );

    return false;
  }

  Future<bool> purchaseTimePackage(TimePackage package) async {
    try {
      if (!context.mounted) return false;
      final walletState = _container.read(walletProvider);

      if (walletState.balance != null &&
          walletState.balance!.hasSufficientBalance(package.price)) {
        return await _purchaseTimePackageWithWallet(package);
      } else {
        // Need to recharge or use direct payment
        return await _purchaseTimePackageWithDirectPayment(package);
      }
    } catch (e) {
      debugPrint('Error purchasing time package: $e');
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> _purchaseTimePackageWithWallet(TimePackage package) async {
    try {
      final userService = _container.read(userServiceProvider);
      final walletNotifier = _container.read(walletProvider.notifier);
      final currentUserNotifier = _container.read(currentUserProvider.notifier);

      PaymentStatusOverlay.showProcessing(context: context);

      final response = await userService.buyTimePackageWithWallet(package.id);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return false;

      if (response.data != null) {
        walletNotifier.refresh();
        await currentUserNotifier.syncUser(response.data!);

        if (context.mounted) {
          await PaymentStatusOverlay.showSuccess(
            context: context,
            orderNo: 'WALLET-${DateTime.now().millisecondsSinceEpoch}',
          );
        }

        return true;
      }

      return false;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      rethrow;
    }
  }

  Future<bool> _purchaseTimePackageWithDirectPayment(
    TimePackage package,
  ) async {
    if (!context.mounted) return false;
    await Future.delayed(const Duration(milliseconds: 500));
    if (!context.mounted) return false;

    final selectedChannel = await PaymentChannelPopup.show(
      context: context,
      amount: package.price,
      paymentType: 'resource_purchase',
    );

    if (selectedChannel == null || !context.mounted) return false;

    return _processTimePackageDirectPayment(package, selectedChannel);
  }

  Future<bool> purchaseTimePackageWithChannel(
    TimePackage package,
    PaymentChannel channel,
  ) async {
    if (!context.mounted) return false;
    return _processTimePackageDirectPayment(package, channel);
  }

  Future<bool> _processTimePackageDirectPayment(
    TimePackage package,
    PaymentChannel selectedChannel,
  ) async {
    final i18n = _container.read(i18nNotifierProvider.notifier);
    final order = await _createPaymentOrder(
      channel: selectedChannel,
      amount: package.price,
      bizType: 'time_package',
      bizId: package.id.toString(),
      paymentMethod: 'direct',
      contentType: 'time_package',
      timePackageId: package.id,
      productName:
          '${package.durationSeconds} ${i18n.translate('minutesTimePackage')}',
      currency: _getCurrencyCode(),
    );

    if (order == null) return false;

    final success = await _openPaymentUrl(order.payUrl);
    if (!success) {
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: i18n.translate('couldNotOpenPaymentPage'),
        );
      }
      return false;
    }

    return true;
  }

  Future<PaymentOrderCreateResponse?> _createPaymentOrder({
    required PaymentChannel channel,
    required double amount,
    String? productName,
    String? bizType,
    String? bizId,
    String? currency,
    String? resourceType,
    String? data,
    String? paymentMethod,
    String? contentId,
    String? contentType,
    int? vipId,
    int? timePackageId,
  }) async {
    try {
      final paymentFlowNotifier = _container.read(paymentFlowProvider.notifier);
      final i18n = _container.read(i18nNotifierProvider.notifier);
      PaymentStatusOverlay.showProcessing(context: context);
      final order = await paymentFlowNotifier.createOrder(
        amount: amount,
        productName: productName,
        bizType: bizType,
        bizId: bizId,
        currency: currency,
        channelCode: channel.channelCode,
        platformId: channel.platformId,
        resourceType: resourceType,
        data: data,
        paymentMethod: paymentMethod,
        contentId: contentId,
        contentType: contentType,
        vipId: vipId,
        timePackageId: timePackageId,
      );

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (order == null) {
        if (context.mounted) {
          await PaymentStatusOverlay.showFailure(
            context: context,
            errorMessage: i18n.translate('failedToCreatePaymentOrder'),
          );
        }
      }

      return order;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return null;
    }
  }

  Future<bool> _openPaymentUrl(String url) async {
    try {
      final uri = Uri.parse(url);

      if (kIsWeb) {
        await launchUrl(uri, webOnlyWindowName: '_blank');
        return true;
      }

      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (launched) {
          return true;
        }
      } catch (e) {
        debugPrint('External application launch failed: $e');
      }

      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (launched) {
          return true;
        }
      } catch (e) {
        debugPrint('External non-browser launch failed: $e');
      }

      try {
        final launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
        if (launched) {
          return true;
        }
      } catch (e) {
        debugPrint('Platform default launch failed: $e');
      }

      return false;
    } catch (e) {
      debugPrint('Error parsing or opening payment URL: $e');
      return false;
    }
  }

  Future<bool> verifyPayment(String orderNo) async {
    try {
      final paymentFlowNotifier = _container.read(paymentFlowProvider.notifier);
      final walletNotifier = _container.read(walletProvider.notifier);
      final i18n = _container.read(i18nNotifierProvider.notifier);
      PaymentStatusOverlay.showProcessing(context: context);

      final success = await paymentFlowNotifier.verifyOrder(orderNo);

      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (!context.mounted) return false;

      if (success) {
        walletNotifier.refresh();

        if (context.mounted) {
          await PaymentStatusOverlay.showSuccess(
            context: context,
            orderNo: orderNo,
          );
        }
      } else {
        if (context.mounted) {
          await PaymentStatusOverlay.showFailure(
            context: context,
            errorMessage: i18n.translate('paymentVerificationFailed'),
          );
        }
      }

      return success;
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      if (context.mounted) {
        await PaymentStatusOverlay.showFailure(
          context: context,
          errorMessage: e.toString(),
        );
      }
      return false;
    }
  }
}
