import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/currency_provider.dart';

import '../../models/payment_channel.dart';
import '../../provider/i18n_provider.dart';
import '../../provider/payment_flow_provider.dart';
import 'payment_channel_tile.dart';

class PaymentChannelResult {
  final PaymentChannel? channel;
  final bool useWallet;

  const PaymentChannelResult({this.channel, this.useWallet = false});

  static const wallet = PaymentChannelResult(useWallet: true);
}

class PaymentChannelPopup extends ConsumerStatefulWidget {
  final double amount;
  final String paymentType;
  final Function(PaymentChannel)? onChannelSelected;
  final VoidCallback? onCancel;
  final VoidCallback? onWalletPayment;
  final double? walletBalance;
  final bool showWalletOption;

  const PaymentChannelPopup({
    super.key,
    required this.amount,
    required this.paymentType,
    this.onChannelSelected,
    this.onCancel,
    this.onWalletPayment,
    this.walletBalance,
    this.showWalletOption = false,
  });

  @override
  ConsumerState<PaymentChannelPopup> createState() =>
      _PaymentChannelPopupState();

  static Future<PaymentChannel?> show({
    required BuildContext context,
    required double amount,
    required String paymentType,
  }) {
    if (!context.mounted) return Future.value(null);

    return showModalBottomSheet<PaymentChannel>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => PaymentChannelPopup(
        amount: amount,
        paymentType: paymentType,
        onChannelSelected: (channel) {
          Navigator.of(context).pop(channel);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }

  static Future<PaymentChannelResult?> showWithWalletOption({
    required BuildContext context,
    required double amount,
    required String paymentType,
    required double walletBalance,
  }) {
    if (!context.mounted) return Future.value(null);

    final isRecharge = paymentType == 'recharge';
    final hasEnoughBalance = !isRecharge && walletBalance >= amount;

    return showModalBottomSheet<PaymentChannelResult>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: false,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => PaymentChannelPopup(
        amount: amount,
        paymentType: paymentType,
        showWalletOption: hasEnoughBalance,
        walletBalance: walletBalance,
        onChannelSelected: (channel) {
          Navigator.of(context).pop(PaymentChannelResult(channel: channel));
        },
        onWalletPayment: () {
          Navigator.of(context).pop(PaymentChannelResult.wallet);
        },
        onCancel: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _PaymentChannelPopupState extends ConsumerState<PaymentChannelPopup> {
  int? _selectedChannelId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paymentFlowProvider.notifier)
          .fetchPaymentChannels(
            amount: widget.amount,
            paymentType: widget.paymentType,
          );
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _loadMore();
    }
  }

  void _loadMore() {
    final state = ref.read(paymentFlowProvider);
    if (!state.isLoadingMore && state.hasMoreChannels) {
      ref
          .read(paymentFlowProvider.notifier)
          .fetchMorePaymentChannels(
            amount: widget.amount,
            paymentType: widget.paymentType,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final paymentFlowState = ref.watch(paymentFlowProvider);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    final currencyState = ref.watch(currencyProvider);

    final channels = paymentFlowState.availableChannels;
    final isLoading = paymentFlowState.isLoading;
    final isLoadingMore = paymentFlowState.isLoadingMore;
    final hasMore = paymentFlowState.hasMoreChannels;
    final error = paymentFlowState.errorMessage;

    final accentColor = theme.colorScheme.onPrimary;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Text(
                    i18n.translate('choosePaymentMethod'),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Amount display card
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withValues(alpha: 0.15),
                          accentColor.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.account_balance_wallet_outlined,
                            color: accentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              i18n.translate('amount'),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark
                                    ? Colors.white60
                                    : Colors.grey.shade600,
                              ),
                            ),
                            Text(
                              currencyState
                                  .convertFromBase(widget.amount)
                                  .toStringAsFixed(2),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Use Wallet button (only if wallet option is enabled and balance is sufficient)
            if (widget.showWalletOption && widget.onWalletPayment != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: widget.onWalletPayment,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          i18n.translate('useWallet'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildContent(
                context,
                theme,
                isDark,
                i18n,
                channels,
                isLoading,
                isLoadingMore,
                hasMore,
                error,
                accentColor,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  if (!isLoading && error == null && channels.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 14,
                            color: Colors.green.shade400,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            i18n.translate('securePayment'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade400,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  Row(
                    children: [
                      if (_selectedChannelId != null) ...[
                        Expanded(
                          child: _buildButton(
                            context,
                            label: i18n.translate('cancel'),
                            onPressed:
                                widget.onCancel ??
                                () => Navigator.of(context).pop(),
                            isPrimary: false,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      Expanded(
                        flex: _selectedChannelId != null ? 2 : 1,
                        child: _buildButton(
                          context,
                          label: i18n.translate('pay'),
                          onPressed:
                              _selectedChannelId == null || channels.isEmpty
                              ? null
                              : () {
                                  final selectedChannel = channels.firstWhere(
                                    (c) => c.id == _selectedChannelId,
                                  );

                                  ref
                                      .read(paymentFlowProvider.notifier)
                                      .selectChannel(selectedChannel);

                                  widget.onChannelSelected?.call(
                                    selectedChannel,
                                  );
                                },
                          isPrimary: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "支付小贴士\n1.跳转后请及时付款，超时支付无法到账，需要重新发起。 \n2.支付成功后会有一定延迟，请耐心等待，当等待时间过长时，欢迎骚扰客服小姐姐。 \n3.当选择的支付方式无法支付时，请切换不同支付方式尝试",
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    dynamic i18n,
    List<PaymentChannel> channels,
    bool isLoading,
    bool isLoadingMore,
    bool hasMore,
    String? error,
    Color accentColor,
  ) {
    if (isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: accentColor,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                i18n.translate('loading'),
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                ref
                    .read(paymentFlowProvider.notifier)
                    .fetchPaymentChannels(
                      amount: widget.amount,
                      paymentType: widget.paymentType,
                    );
              },
              icon: const Icon(Icons.refresh_rounded),
              label: Text(i18n.translate('retry')),
              style: TextButton.styleFrom(foregroundColor: accentColor),
            ),
          ],
        ),
      );
    }

    if (channels.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.payment_outlined,
                size: 40,
                color: isDark ? Colors.white38 : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              i18n.translate('noPaymentMethodsAvailable'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white60 : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.45,
      ),
      child: ListView.separated(
        controller: _scrollController,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: channels.length + (hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          if (index >= channels.length) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: isLoadingMore
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: accentColor,
                          strokeWidth: 2,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            );
          }
          final channel = channels[index];
          final isSelected = _selectedChannelId == channel.id;

          return PaymentChannelTile(
            channel: channel,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                _selectedChannelId = channel.id;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
    required bool isPrimary,
  }) {
    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade700,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        foregroundColor: Colors.white70,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }
}
