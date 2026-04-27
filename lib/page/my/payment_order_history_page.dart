import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/page_params.dart';
import '../../models/payment_order.dart';
import '../../provider/api_provider.dart';

/// Payment order history page
class PaymentOrderHistoryPage extends ConsumerStatefulWidget {
  const PaymentOrderHistoryPage({super.key});

  @override
  ConsumerState<PaymentOrderHistoryPage> createState() =>
      _PaymentOrderHistoryPageState();
}

class _PaymentOrderHistoryPageState
    extends ConsumerState<PaymentOrderHistoryPage> {
  final ScrollController _scrollController = ScrollController();
  List<PaymentOrder> _orders = [];
  bool _isLoading = false;
  int _currentPage = 1;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadOrders(refresh: true);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders({bool refresh = false}) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      if (refresh) {
        _currentPage = 1;
        _orders = [];
        _hasMore = true;
      }
    });

    try {
      final paymentService = ref.read(paymentServiceProvider);
      final response = await paymentService.getOrderHistory(
        PageParams(page: _currentPage, limit: 20),
      );

      if (response.data != null) {
        final pageResponse = response.data!;
        setState(() {
          if (refresh) {
            _orders = pageResponse.list;
          } else {
            _orders.addAll(pageResponse.list);
          }
          final totalPages = (pageResponse.total / pageResponse.limit).ceil();
          _hasMore = _currentPage < totalPages;
          _currentPage++;
        });
      }
    } catch (e) {
      debugPrint('Failed to load orders: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load orders: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (_hasMore && !_isLoading) {
        _loadOrders();
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadOrders(refresh: true);
  }

  Future<void> _cancelOrder(PaymentOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text(
          'Are you sure you want to cancel order ${order.orderNo}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final paymentService = ref.read(paymentServiceProvider);
        await paymentService.cancelOrder(int.parse(order.id));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Order cancelled successfully')),
          );
          _onRefresh();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to cancel order: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _onRefresh),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: _orders.isEmpty && !_isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No payment orders yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                controller: _scrollController,
                itemCount: _orders.length + (_isLoading && _hasMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index < _orders.length) {
                    return _buildOrderItem(theme, _orders[index]);
                  } else {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                },
              ),
      ),
    );
  }

  Widget _buildOrderItem(ThemeData theme, PaymentOrder order) {
    final statusColor = _getStatusColor(order.status);
    final statusText = _getStatusText(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: () => _showOrderDetails(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      order.orderNo,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Amount and type
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        '${order.currency} ${order.amount.toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        _getBizTypeText(order.bizType),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Created date
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              // Actions for pending orders
              if (order.status == PaymentOrderStatus.pending) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => _cancelOrder(order),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(PaymentOrder order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Details',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildDetailRow('Order Number', order.orderNo),
              _buildDetailRow(
                'Amount',
                '${order.currency} ${order.amount.toStringAsFixed(2)}',
              ),
              _buildDetailRow('Status', _getStatusText(order.status)),
              _buildDetailRow('Type', _getBizTypeText(order.bizType)),
              _buildDetailRow('Created', _formatDate(order.createdAt)),
              if (order.paidAt != null)
                _buildDetailRow('Paid', _formatDate(order.paidAt!)),
              if (order.expiredAt != null)
                _buildDetailRow('Expires', _formatDate(order.expiredAt!)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getStatusColor(PaymentOrderStatus status) {
    switch (status) {
      case PaymentOrderStatus.pending:
        return Colors.orange;
      case PaymentOrderStatus.success:
        return Colors.green;
      case PaymentOrderStatus.failed:
        return Colors.red;
      case PaymentOrderStatus.closed:
        return Colors.grey;
      case PaymentOrderStatus.refunded:
        return Colors.blue;
    }
  }

  String _getStatusText(PaymentOrderStatus status) {
    switch (status) {
      case PaymentOrderStatus.pending:
        return 'Pending';
      case PaymentOrderStatus.success:
        return 'Success';
      case PaymentOrderStatus.failed:
        return 'Failed';
      case PaymentOrderStatus.closed:
        return 'Closed';
      case PaymentOrderStatus.refunded:
        return 'Refunded';
    }
  }

  String _getBizTypeText(BizType type) {
    switch (type) {
      case BizType.recharge:
        return 'Wallet Recharge';
      case BizType.resource:
        return 'Content Purchase';
      case BizType.vip:
        return 'VIP Subscription';
      case BizType.timePackage:
        return 'Time Package';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
