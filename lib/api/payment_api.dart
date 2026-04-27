class PaymentApi {
  static const String base = "/api/user";
  // Wallet endpoints (matching backend implementation)
  static const String getWalletBalance = "$base/wallet/balance";
  static const String walletRecharge = "$base/wallet/recharge";
  static const String getTransactionHistory = "$base/wallet/transactions";
  static const String getTransactionDetail = "$base/wallet/transactions";

  // Payment channel endpoints (will be implemented later)
  static const String getPaymentChannels = "$base/payment/channels";
  static const String getRechargeAmounts = "$base/payment/recharge-amounts";

  // Payment order endpoints (will be implemented later)
  static const String createOrder = "$base/payment/orders/create";
  static const String getOrderDetail = "$base/payment/orders/detail";
  static const String verifyOrder = "$base/payment/orders/verify";
  static const String getOrderHistory = "$base/payment/orders/history";
  static const String cancelOrder = "$base/payment/orders/cancel";

  // Resource purchase endpoints (will be implemented later)
  static const String purchaseVideo = "$base/payment/purchase/video";
  static const String purchaseAudio = "$base/payment/purchase/audio";
  static const String purchaseTimePackage =
      "$base/payment/purchase/time-package";
  static const String walletPurchase = "$base/payment/wallet/purchase";

  // Feature flags (will be implemented later)
  static const String getFeatureFlags = "$base/payment/feature-flags";

  // VIP subscription endpoints
  static const String getVipLevels = "$base/payment/vip/levels";
  static const String getUserVips = "$base/payment/vip/user-subscriptions";
  static const String purchaseVip = "$base/payment/vip/purchase";
  static const String getActiveVip = "$base/payment/vip/active";

  // Content access verification endpoints
  static const String checkContentAccess = "$base/payment/content/check-access";
  static const String getPurchaseHistory =
      "$base/payment/content/purchase-history";

  // Generic content purchase check endpoint
  static const String check = "$base/payment/check";
}
