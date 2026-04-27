import '../../models/api_response.dart';
import '../../models/content_access_response.dart';
import '../../models/content_purchase.dart';
import '../../models/page_params.dart';
import '../../models/page_response.dart';
import '../../models/payment_channel.dart';
import '../../models/payment_feature_flags.dart';
import '../../models/payment_order.dart';
import '../../models/payment_order_create_response.dart';
import '../../models/recharge_amount.dart';
import '../../models/wallet_balance.dart';
import '../../models/wallet_transaction.dart';
import '../payment_api.dart';
import 'base_service.dart';

class PaymentService extends BaseService {
  PaymentService(super.client);

  Future<ApiResponse<WalletBalance>> getWalletBalance() {
    return post<WalletBalance>(
      PaymentApi.getWalletBalance,
      fromJson: (json) => WalletBalance.fromJson(json),
    );
  }

  Future<ApiResponse<PageResponse<RechargeAmount>>> getRechargeAmounts({
    int page = 1,
    int limit = 20,
  }) {
    return post<PageResponse<RechargeAmount>>(
      PaymentApi.getRechargeAmounts,
      body: {'page': page, 'limit': limit},
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => RechargeAmount.fromJson(item)),
    );
  }

  Future<ApiResponse<PageResponse<WalletTransaction>>> getTransactionHistory(
    PageParams params,
  ) {
    return post<PageResponse<WalletTransaction>>(
      PaymentApi.getTransactionHistory,
      body: {'page': params.page, 'limit': params.limit},
      fromJson: (json) => PageResponse.fromJson(
        json,
        (item) => WalletTransaction.fromJson(item),
      ),
    );
  }

  // ===== Payment Channels =====
  /// Get available payment channels
  /// [amount] - Transaction amount to filter channels by min/max
  /// [paymentType] - 'wallet_recharge' or 'resource_purchase'
  Future<ApiResponse<PageResponse<PaymentChannel>>> getPaymentChannels({
    required double amount,
    required String paymentType,
    int page = 1,
    int limit = 20,
  }) {
    return post<PageResponse<PaymentChannel>>(
      PaymentApi.getPaymentChannels,
      body: {
        'amount': amount,
        'payment_type': paymentType,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => PaymentChannel.fromJson(item)),
    );
  }

  Future<ApiResponse<PaymentOrderCreateResponse>> createOrder({
    required double amount,
    String? productName,
    String? clientIp,
    String? bizType,
    String? bizId,
    String? currency,
    String? channelCode,
    int? platformId,
    String? resourceType,
    String? data,
    String? paymentMethod,
    String? contentId,
    String? contentType,
    int? vipId,
    int? timePackageId,
  }) {
    return post<PaymentOrderCreateResponse>(
      PaymentApi.createOrder,
      body: {
        'amount': amount,
        'productName': productName,
        'clientIp': clientIp,
        'bizType': bizType,
        'bizId': bizId,
        'currency': currency,
        'channelCode': channelCode,
        'platformId': platformId,
        'resourceType': resourceType,
        'data': data,
        'paymentMethod': paymentMethod,
        'id_type': contentId,
        'type': contentType,
        'vip_id': vipId,
        'timePackageId': timePackageId,
      },
      fromJson: (json) => PaymentOrderCreateResponse.fromJson(json),
    );
  }

  Future<ApiResponse<PaymentOrder>> getOrderDetail(int orderId) {
    return post<PaymentOrder>(
      PaymentApi.getOrderDetail,
      body: {'order_id': orderId},
      fromJson: (json) => PaymentOrder.fromJson(json),
    );
  }

  /// Verify payment order status (after callback from payment platform)
  Future<ApiResponse<PaymentOrder>> verifyOrder(String orderNo) {
    return post<PaymentOrder>(
      PaymentApi.verifyOrder,
      body: {'order_no': orderNo},
      fromJson: (json) => PaymentOrder.fromJson(json),
    );
  }

  Future<ApiResponse<PageResponse<PaymentOrder>>> getOrderHistory(
    PageParams params,
  ) {
    return post<PageResponse<PaymentOrder>>(
      PaymentApi.getOrderHistory,
      body: params.toJson(),
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => PaymentOrder.fromJson(item)),
    );
  }

  /// Cancel a pending payment order
  Future<ApiResponse<String>> cancelOrder(int orderId) {
    return post<String>(
      PaymentApi.cancelOrder,
      body: {'order_id': orderId},
      fromJson: (json) => json.toString(),
    );
  }

  // ===== Resource Purchases =====
  /// Generic method to purchase any content type using wallet balance
  /// [contentType] - Type of content: 'video', 'audio', 'manga', 'time_package', etc.
  /// [contentId] - ID of the content
  /// Returns updated wallet balance
  Future<ApiResponse<WalletBalance>> purchaseContentWithWallet({
    required String contentType,
    required String contentId,
  }) {
    return post<WalletBalance>(
      PaymentApi.walletPurchase,
      body: {'resource_type': contentType, 'resource_id': contentId},
      fromJson: (json) => WalletBalance.fromJson(json),
    );
  }

  Future<ApiResponse<WalletBalance>> purchaseTimePackageWithWallet(
    int packageId,
  ) {
    return purchaseContentWithWallet(
      contentType: 'time_package',
      contentId: packageId.toString(),
    );
  }

  // ===== Feature Flags =====
  /// Get payment feature configuration
  Future<ApiResponse<PaymentFeatureFlags>> getFeatureFlags() {
    return post<PaymentFeatureFlags>(
      PaymentApi.getFeatureFlags,
      fromJson: (json) => PaymentFeatureFlags.fromJson(json),
    );
  }

  // ===== Content Access Verification =====
  /// Check if user has access to content and get pricing info
  /// [contentType] - Type of content (long_video, short_video, audio, post, etc.)
  /// [contentId] - ID of the content
  Future<ApiResponse<ContentAccessResponse>> checkContentAccess({
    required String contentType,
    required String contentId,
  }) {
    return post<ContentAccessResponse>(
      PaymentApi.checkContentAccess,
      body: {'content_type': contentType, 'content_id': contentId},
      fromJson: (json) => ContentAccessResponse.fromJson(json),
    );
  }

  /// Generic purchase/access check for a specific content item.
  Future<ApiResponse<bool>> check({
    required String contentType,
    required String contentId,
  }) {
    return post<bool>(
      PaymentApi.check,
      body: {'type': contentType, 'contentId': contentId},
      fromJson: (json) {
        if (json is bool) return json;
        if (json is num) return json != 0;
        if (json is String) return json.toLowerCase() == 'true';
        return false;
      },
    );
  }

  /// Get user's content purchase history
  Future<ApiResponse<PageResponse<ContentPurchase>>> getPurchaseHistory(
    PageParams params, {
    String? contentType,
  }) {
    return post<PageResponse<ContentPurchase>>(
      PaymentApi.getPurchaseHistory,
      body: {
        ...params.toJson(),
        if (contentType != null) 'content_type': contentType,
      },
      fromJson: (json) =>
          PageResponse.fromJson(json, (item) => ContentPurchase.fromJson(item)),
    );
  }
}
