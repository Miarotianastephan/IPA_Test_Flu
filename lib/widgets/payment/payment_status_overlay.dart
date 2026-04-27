import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/payment_order.dart';
import '../../provider/i18n_provider.dart';

/// Payment status overlay for showing success/failure
class PaymentStatusOverlay extends ConsumerWidget {
  final PaymentOrderStatus status;
  final String? orderNo;
  final String? errorMessage;
  final VoidCallback? onDismiss;

  const PaymentStatusOverlay({
    super.key,
    required this.status,
    this.orderNo,
    this.errorMessage,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status icon
            _buildStatusIcon(theme),
            const SizedBox(height: 24),

            // Title
            Text(
              _getTitle(i18n),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Message
            Text(
              _getMessage(i18n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),

            // Order number
            if (orderNo != null && status == PaymentOrderStatus.success) ...[
              const SizedBox(height: 16),
              Column(
                children: [
                  Text(
                    i18n.translate('orderId'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    orderNo!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],

            // Error message (if failed)
            if (status == PaymentOrderStatus.failed &&
                errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (status != PaymentOrderStatus.pending) ...[
              const SizedBox(height: 24),

              Row(
                children: [
                  if (status == PaymentOrderStatus.failed) ...[
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            onDismiss ?? () => Navigator.of(context).pop(),
                        child: Text(
                          i18n.translate('tryAgain'),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onDismiss ?? () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _getButtonColor(theme),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        _getButtonText(i18n),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    switch (status) {
      case PaymentOrderStatus.success:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            size: 50,
            color: Colors.green.shade700,
          ),
        );

      case PaymentOrderStatus.failed:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.red.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error, size: 50, color: Colors.red.shade700),
        );

      case PaymentOrderStatus.pending:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            shape: BoxShape.circle,
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade700),
            ),
          ),
        );

      case PaymentOrderStatus.closed:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.cancel, size: 50, color: Colors.grey.shade700),
        );

      case PaymentOrderStatus.refunded:
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.refresh, size: 50, color: Colors.blue.shade700),
        );
    }
  }

  String _getTitle(dynamic i18n) {
    switch (status) {
      case PaymentOrderStatus.success:
        return i18n.translate('paymentSuccessful');
      case PaymentOrderStatus.failed:
        return i18n.translate('paymentFailed');
      case PaymentOrderStatus.pending:
        return i18n.translate('paymentProcessing');
      case PaymentOrderStatus.closed:
        return i18n.translate('paymentClosed');
      case PaymentOrderStatus.refunded:
        return i18n.translate('paymentRefunded');
    }
  }

  String _getMessage(dynamic i18n) {
    switch (status) {
      case PaymentOrderStatus.success:
        return i18n.translate('paymentSuccessMessage');
      case PaymentOrderStatus.failed:
        return i18n.translate('paymentFailedMessage');
      case PaymentOrderStatus.pending:
        return i18n.translate('paymentProcessingMessage');
      case PaymentOrderStatus.closed:
        return i18n.translate('paymentClosedMessage');
      case PaymentOrderStatus.refunded:
        return i18n.translate('paymentRefundedMessage');
    }
  }

  String _getButtonText(dynamic i18n) {
    switch (status) {
      case PaymentOrderStatus.success:
        return i18n.translate('continue');
      case PaymentOrderStatus.failed:
        return i18n.translate('close');
      case PaymentOrderStatus.pending:
        return i18n.translate('ok');
      case PaymentOrderStatus.closed:
      case PaymentOrderStatus.refunded:
        return i18n.translate('ok');
    }
  }

  Color _getButtonColor(ThemeData theme) {
    switch (status) {
      case PaymentOrderStatus.success:
        return Colors.green;
      case PaymentOrderStatus.failed:
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }

  static Future<void> showSuccess({
    required BuildContext context,
    required String orderNo,
  }) async {
    if (!context.mounted) return;
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentStatusOverlay(
        status: PaymentOrderStatus.success,
        orderNo: orderNo,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  static Future<void> showFailure({
    required BuildContext context,
    String? errorMessage,
    VoidCallback? onRetry,
  }) async {
    if (!context.mounted) return;
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentStatusOverlay(
        status: PaymentOrderStatus.failed,
        errorMessage: errorMessage,
        onDismiss: () {
          Navigator.of(context).pop();
          onRetry?.call();
        },
      ),
    );
  }

  static Future<void> showProcessing({required BuildContext context}) async {
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PaymentStatusOverlay(
        status: PaymentOrderStatus.pending,
        onDismiss: () => Navigator.of(context).pop(),
      ),
    );
  }

  /// Shows a "waiting for payment" dialog while polling is active.
  /// Returns a [PollingDialogController] to dismiss it programmatically.
  /// [onCancel] is called when the user taps the cancel button.
  static PollingDialogController showPollingPending({
    required BuildContext context,
    required VoidCallback onCancel,
  }) {
    final controller = PollingDialogController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        controller._dismiss = () {
          if (dialogContext.mounted) Navigator.of(dialogContext).pop();
        };
        return _PollingPendingDialog(
          onCancel: () {
            controller.dismiss();
            onCancel();
          },
        );
      },
    );
    return controller;
  }
}

class PollingDialogController {
  VoidCallback? _dismiss;

  void dismiss() {
    _dismiss?.call();
    _dismiss = null;
  }
}

class _PollingPendingDialog extends ConsumerWidget {
  final VoidCallback onCancel;

  const _PollingPendingDialog({required this.onCancel});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.orange.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              i18n.translate('paymentProcessing'),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              i18n.translate('paymentProcessingMessage'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.red.shade400,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  i18n.translate('cancel'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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
