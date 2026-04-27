import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/payment_channel.dart';
import '../models/payment_order.dart';
import '../models/payment_order_create_response.dart';
import 'api_provider.dart';

/// Payment flow state
enum PaymentFlowStatus {
  idle,
  fetchingChannels,
  channelSelectionReady,
  creatingOrder,
  awaitingPayment,
  verifyingPayment,
  success,
  failed,
  cancelled,
}

class PaymentFlowState {
  final PaymentFlowStatus status;
  final List<PaymentChannel> availableChannels;
  final PaymentChannel? selectedChannel;
  final PaymentOrder? activeOrder;
  final PaymentOrderCreateResponse? createResponse;
  final String? errorMessage;
  final bool isLoading;
  final bool isLoadingMore;
  final int currentPage;
  final int totalChannels;
  final bool hasMoreChannels;

  PaymentFlowState({
    this.status = PaymentFlowStatus.idle,
    this.availableChannels = const [],
    this.selectedChannel,
    this.activeOrder,
    this.createResponse,
    this.errorMessage,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.currentPage = 1,
    this.totalChannels = 0,
    this.hasMoreChannels = false,
  });

  PaymentFlowState copyWith({
    PaymentFlowStatus? status,
    List<PaymentChannel>? availableChannels,
    PaymentChannel? selectedChannel,
    PaymentOrder? activeOrder,
    PaymentOrderCreateResponse? createResponse,
    String? errorMessage,
    bool? isLoading,
    bool? isLoadingMore,
    int? currentPage,
    int? totalChannels,
    bool? hasMoreChannels,
  }) {
    return PaymentFlowState(
      status: status ?? this.status,
      availableChannels: availableChannels ?? this.availableChannels,
      selectedChannel: selectedChannel ?? this.selectedChannel,
      activeOrder: activeOrder ?? this.activeOrder,
      createResponse: createResponse ?? this.createResponse,
      errorMessage: errorMessage,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
      totalChannels: totalChannels ?? this.totalChannels,
      hasMoreChannels: hasMoreChannels ?? this.hasMoreChannels,
    );
  }
}

/// Payment flow notifier
class PaymentFlowNotifier extends StateNotifier<PaymentFlowState> {
  final Ref ref;

  PaymentFlowNotifier(this.ref) : super(PaymentFlowState());

  /// Fetch available payment channels
  Future<void> fetchPaymentChannels({
    required double amount,
    required String paymentType,
    int page = 1,
    int limit = 20,
  }) async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      state = state.copyWith(
        status: PaymentFlowStatus.fetchingChannels,
        isLoading: true,
        errorMessage: null,
      );

      final res = await paymentService.getPaymentChannels(
        amount: amount,
        paymentType: paymentType,
        page: page,
        limit: limit,
      );

      if (res.data != null && res.data!.list.isNotEmpty) {
        final data = res.data!;
        final hasMore = (data.page * data.limit) < data.total;
        state = state.copyWith(
          status: PaymentFlowStatus.channelSelectionReady,
          availableChannels: data.list,
          isLoading: false,
          currentPage: data.page,
          totalChannels: data.total,
          hasMoreChannels: hasMore,
        );
      } else {
        state = state.copyWith(
          status: PaymentFlowStatus.failed,
          errorMessage: 'No payment channels available',
          isLoading: false,
          hasMoreChannels: false,
        );
      }
    } catch (e) {
      debugPrint("Failed to fetch payment channels: $e");
      state = state.copyWith(
        status: PaymentFlowStatus.failed,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }
  }

  /// Fetch more payment channels (pagination)
  Future<void> fetchMorePaymentChannels({
    required double amount,
    required String paymentType,
    int limit = 20,
  }) async {
    if (state.isLoadingMore || !state.hasMoreChannels) return;

    final paymentService = ref.read(paymentServiceProvider);
    final nextPage = state.currentPage + 1;

    try {
      state = state.copyWith(isLoadingMore: true);

      final res = await paymentService.getPaymentChannels(
        amount: amount,
        paymentType: paymentType,
        page: nextPage,
        limit: limit,
      );

      if (res.data != null) {
        final data = res.data!;
        final hasMore = (data.page * data.limit) < data.total;
        final allChannels = [...state.availableChannels, ...data.list];
        state = state.copyWith(
          availableChannels: allChannels,
          isLoadingMore: false,
          currentPage: data.page,
          totalChannels: data.total,
          hasMoreChannels: hasMore,
        );
      } else {
        state = state.copyWith(isLoadingMore: false);
      }
    } catch (e) {
      debugPrint("Failed to fetch more payment channels: $e");
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Select a payment channel
  void selectChannel(PaymentChannel channel) {
    state = state.copyWith(selectedChannel: channel);
  }

  /// Create payment order
  Future<PaymentOrderCreateResponse?> createOrder({
    required double amount,
    String? productName,
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
  }) async {
    if (state.selectedChannel == null && channelCode == null) {
      state = state.copyWith(
        status: PaymentFlowStatus.failed,
        errorMessage: 'No payment channel selected',
      );
      return null;
    }

    final paymentService = ref.read(paymentServiceProvider);

    try {
      state = state.copyWith(
        status: PaymentFlowStatus.creatingOrder,
        isLoading: true,
        errorMessage: null,
      );

      final res = await paymentService.createOrder(
        amount: amount,
        productName: productName,
        bizType: bizType,
        bizId: bizId,
        currency: currency,
        channelCode: channelCode ?? state.selectedChannel?.channelCode,
        platformId: platformId ?? state.selectedChannel?.platformId,
        resourceType: resourceType,
        data: data,
        paymentMethod: paymentMethod,
        contentId: contentId,
        contentType: contentType,
        vipId: vipId,
        timePackageId: timePackageId,
      );

      if (res.data != null) {
        state = state.copyWith(
          status: PaymentFlowStatus.awaitingPayment,
          createResponse: res.data,
          isLoading: false,
        );
        return res.data;
      }
    } catch (e) {
      debugPrint("Failed to create payment order: $e");
      state = state.copyWith(
        status: PaymentFlowStatus.failed,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }

    return null;
  }

  /// Verify payment order (after callback)
  Future<bool> verifyOrder(String orderNo) async {
    final paymentService = ref.read(paymentServiceProvider);

    try {
      state = state.copyWith(
        status: PaymentFlowStatus.verifyingPayment,
        isLoading: true,
        errorMessage: null,
      );

      final res = await paymentService.verifyOrder(orderNo);

      if (res.data != null) {
        final order = res.data!;

        if (order.status == PaymentOrderStatus.success) {
          state = state.copyWith(
            status: PaymentFlowStatus.success,
            activeOrder: order,
            isLoading: false,
          );
          return true;
        } else if (order.status == PaymentOrderStatus.failed) {
          state = state.copyWith(
            status: PaymentFlowStatus.failed,
            activeOrder: order,
            errorMessage:
                order.extra?['errorMessage'] as String? ?? 'Payment failed',
            isLoading: false,
          );
          return false;
        } else {
          state = state.copyWith(
            status: PaymentFlowStatus.awaitingPayment,
            activeOrder: order,
            isLoading: false,
          );
          return false;
        }
      }
    } catch (e) {
      debugPrint("Failed to verify payment order: $e");
      state = state.copyWith(
        status: PaymentFlowStatus.failed,
        errorMessage: e.toString(),
        isLoading: false,
      );
    }

    return false;
  }

  /// Cancel current payment flow
  void cancel() {
    state = PaymentFlowState(status: PaymentFlowStatus.cancelled);
  }

  /// Reset payment flow
  void reset() {
    state = PaymentFlowState(status: PaymentFlowStatus.idle);
  }
}

/// Payment flow provider
final paymentFlowProvider =
    StateNotifierProvider<PaymentFlowNotifier, PaymentFlowState>((ref) {
      return PaymentFlowNotifier(ref);
    });
