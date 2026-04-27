// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../models/vip_level.dart';
// import '../../provider/vip_provider.dart';
// import '../../provider/wallet_provider.dart';
// import '../../services/payment_orchestrator.dart';
// import '../../widgets/payment/payment_status_overlay.dart';

// /// VIP purchase page showing available VIP levels
// class VipPurchasePage extends ConsumerStatefulWidget {
//   const VipPurchasePage({super.key});

//   @override
//   ConsumerState<VipPurchasePage> createState() => _VipPurchasePageState();
// }

// class _VipPurchasePageState extends ConsumerState<VipPurchasePage> {
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     await Future.wait([
//       // ref.read(vipProvider.notifier).loadVipLevels(),
//       // ref.read(vipProvider.notifier).loadActiveVip(),
//       ref.read(walletProvider.notifier).loadBalance(),
//     ]);
//   }

//   Future<void> _onRefresh() async {
//     await _loadData();
//   }

//   Future<void> _purchaseVip(VipLevel level) async {
//     final walletState = ref.read(walletProvider);

//     // Check if user has sufficient balance
//     if (walletState.balance != null &&
//         walletState.balance!.hasSufficientBalance(level.price)) {
//       // Purchase with wallet
//       await _purchaseVipWithWallet(level);
//     } else {
//       // Need to recharge first or use direct payment
//       final shouldRecharge = await _showInsufficientBalanceDialog(level.price);
//       if (shouldRecharge == true && mounted) {
//         final orchestrator = PaymentOrchestrator(ref, context);
//         final success = await orchestrator.rechargeWallet();
//         if (success && mounted) {
//           // Try purchasing again after recharge
//           await _purchaseVip(level);
//         }
//       }
//     }
//   }

//   Future<void> _purchaseVipWithWallet(VipLevel level) async {
//     try {
//       PaymentStatusOverlay.showProcessing(context: context);

//       final success =
//           await ref.read(vipProvider.notifier).purchaseVipWithWallet(level.id);

//       if (mounted) {
//         Navigator.of(context).pop(); // Close processing dialog
//       }

//       if (success) {
//         // Refresh wallet balance
//         ref.read(walletProvider.notifier).refresh();

//         if (mounted) {
//           await PaymentStatusOverlay.showSuccess(
//             context: context,
//             orderNo: 'VIP-${DateTime.now().millisecondsSinceEpoch}',
//           );
//         }
//       } else {
//         if (mounted) {
//           await PaymentStatusOverlay.showFailure(
//             context: context,
//             errorMessage: 'Failed to purchase VIP',
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         Navigator.of(context).pop(); // Close processing
//         await PaymentStatusOverlay.showFailure(
//           context: context,
//           errorMessage: e.toString(),
//         );
//       }
//     }
//   }

//   Future<bool?> _showInsufficientBalanceDialog(double requiredAmount) {
//     return showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Insufficient Balance'),
//         content: Text(
//           'You need \$${requiredAmount.toStringAsFixed(2)} to purchase this VIP level. Would you like to recharge your wallet?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Cancel'),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             child: const Text('Recharge'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final vipState = ref.watch(vipProvider);
//     final walletState = ref.watch(walletProvider);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VIP Membership'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _onRefresh,
//           ),
//         ],
//       ),
//       body: RefreshIndicator(
//         onRefresh: _onRefresh,
//         child: vipState.isLoading && vipState.availableLevels.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : CustomScrollView(
//                 slivers: [
//                   // Active VIP Status Card
//                   if (vipState.hasActiveVip)
//                     SliverToBoxAdapter(
//                       child: _buildActiveVipCard(theme, vipState.activeVip!),
//                     ),

//                   // Wallet Balance
//                   SliverToBoxAdapter(
//                     child: _buildWalletBalanceCard(theme, walletState),
//                   ),

//                   // Available VIP Levels Header
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.all(16),
//                       child: Text(
//                         vipState.hasActiveVip
//                             ? 'Upgrade or Renew'
//                             : 'Choose Your VIP Level',
//                         style: theme.textTheme.titleLarge?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),

//                   // VIP Levels Grid
//                   if (vipState.availableLevels.isEmpty)
//                     const SliverFillRemaining(
//                       child: Center(
//                         child: Text('No VIP levels available'),
//                       ),
//                     )
//                   else
//                     SliverPadding(
//                       padding: const EdgeInsets.all(16),
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                             final level = vipState.availableLevels[index];
//                             return _buildVipLevelCard(theme, level);
//                           },
//                           childCount: vipState.availableLevels.length,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//       ),
//     );
//   }

//   Widget _buildActiveVipCard(ThemeData theme, activeVip) {
//     return Container(
//       margin: const EdgeInsets.all(16),
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.orange.withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.star, color: Colors.white, size: 32),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Active VIP',
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     Text(
//                       activeVip.vipLevel.name,
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Discount',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                     Text(
//                       '${activeVip.vipLevel.discountPercentage}% OFF',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: [
//                     Text(
//                       'Expires',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: Colors.white.withOpacity(0.9),
//                       ),
//                     ),
//                     Text(
//                       activeVip.expirationText,
//                       style: theme.textTheme.titleMedium?.copyWith(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWalletBalanceCard(ThemeData theme, walletState) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: theme.colorScheme.surfaceContainerHighest,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Row(
//             children: [
//               Icon(Icons.account_balance_wallet,
//                   color: theme.colorScheme.primary),
//               const SizedBox(width: 12),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Wallet Balance',
//                     style: theme.textTheme.bodyMedium?.copyWith(
//                       color: theme.colorScheme.onSurfaceVariant,
//                     ),
//                   ),
//                   if (walletState.isLoading)
//                     const SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: CircularProgressIndicator(strokeWidth: 2),
//                     )
//                   else
//                     Text(
//                       '\$${walletState.balance?.balance.toStringAsFixed(2) ?? '0.00'}',
//                       style: theme.textTheme.titleLarge?.copyWith(
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//           TextButton.icon(
//             onPressed: () async {
//               final orchestrator = PaymentOrchestrator(ref, context);
//               await orchestrator.rechargeWallet();
//               ref.read(walletProvider.notifier).refresh();
//             },
//             icon: const Icon(Icons.add),
//             label: const Text('Top Up'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVipLevelCard(ThemeData theme, VipLevel level) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       elevation: 2,
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         level.name,
//                         style: theme.textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         level.durationText,
//                         style: theme.textTheme.bodyMedium?.copyWith(
//                           color: theme.colorScheme.onSurfaceVariant,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                   decoration: BoxDecoration(
//                     color: theme.colorScheme.primaryContainer,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${level.discountPercentage}% OFF',
//                     style: theme.textTheme.titleMedium?.copyWith(
//                       color: theme.colorScheme.onPrimaryContainer,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),

//             // Benefits
//             ...level.benefits.map((benefit) => Padding(
//                   padding: const EdgeInsets.only(bottom: 8),
//                   child: Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: theme.colorScheme.primary,
//                         size: 20,
//                       ),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           benefit,
//                           style: theme.textTheme.bodyMedium,
//                         ),
//                       ),
//                     ],
//                   ),
//                 )),

//             const SizedBox(height: 16),

//             // Price and Purchase Button
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Price',
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: theme.colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                     Text(
//                       '\$${level.price.toStringAsFixed(2)}',
//                       style: theme.textTheme.headlineSmall?.copyWith(
//                         fontWeight: FontWeight.bold,
//                         color: theme.colorScheme.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 ElevatedButton(
//                   onPressed: () => _purchaseVip(level),
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 32,
//                       vertical: 12,
//                     ),
//                   ),
//                   child: const Text('Purchase'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
