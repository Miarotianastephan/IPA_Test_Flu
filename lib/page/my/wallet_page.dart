import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/wingtop_game_provider.dart';
import 'package:live_app/utils/toast_util.dart';
import 'package:live_app/widgets/html_text_field.dart';

import '../../provider/currency_provider.dart';
import '../../provider/wallet_provider.dart';
import '../../services/payment_orchestrator.dart';

class WalletPage extends ConsumerStatefulWidget {
  const WalletPage({super.key});

  @override
  ConsumerState<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends ConsumerState<WalletPage>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  bool _isLoadingRecharge = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    Future.microtask(() => _loadInitialData());
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && !_tabController.indexIsChanging) {
      _onRefreshGameCoins();
    }
  }

  Future<void> _loadInitialData() async {
    await ref.read(wingtopGameProvider.notifier).loadAllStats();
  }

  Future<void> _onRefreshWallet() async {
    await Future.wait([
      ref.read(walletProvider.notifier).loadBalance(),
      _onRefreshGameCoins(),
    ]);
  }

  Future<void> _onRefreshGameCoins() async {
    await ref.read(wingtopGameProvider.notifier).loadAllStats();
  }

  Future<void> _onRecharge() async {
    if (_isLoadingRecharge) return;

    setState(() {
      _isLoadingRecharge = true;
    });

    final orchestrator = PaymentOrchestrator(ref, context);
    final success = await orchestrator.rechargeWallet(
      onPopupShown: () {
        if (mounted) {
          setState(() {
            _isLoadingRecharge = false;
          });
        }
      },
    );

    if (success && mounted) {
      _onRefreshWallet();
    }
  }

  Future<void> _showTransferDialog() async {
    final walletNotifier = ref.read(walletProvider.notifier);
    final currencyState = ref.read(currencyProvider);
    final availableBalanceBase = walletNotifier.availableBalance;
    final availableBalanceLocal = currencyState.convertFromBase(
      availableBalanceBase,
    );

    if (availableBalanceBase <= 0) {
      ToastUtil.error(
        ref
            .read(i18nNotifierProvider.notifier)
            .translate('insufficientBalanceForTransfer'),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    bool isLoading = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        final i18n = ref.read(i18nNotifierProvider.notifier);
        String translate(String key) => i18n.translate(key);
        return StatefulBuilder(
          builder: (context, setState) {
            final enteredAmount = double.tryParse(amountController.text) ?? 0.0;
            final enteredAmountBase = currencyState.convertToBase(
              enteredAmount,
            );
            final isValidAmount =
                enteredAmount > 0 && enteredAmountBase <= availableBalanceBase;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade600,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFE65100).withOpacity(0.15),
                                    const Color(0xFFF57C00).withOpacity(0.08),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.swap_horiz,
                                color: Color(0xFFE65100),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translate('transferToGame'),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    translate('moveFundsToGameCoins'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isLoading
                                  ? null
                                  : () => Navigator.pop(context),
                              icon: Icon(
                                Icons.close,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade900,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Colors.grey.shade400,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    translate('availableBalance'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    availableBalanceLocal.toStringAsFixed(2),
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  amountController.text = availableBalanceLocal
                                      .toStringAsFixed(2);
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFE65100,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    translate('max'),
                                    style: TextStyle(
                                      color: const Color(0xFFE65100),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: HtmlTextField(
                          controller: amountController,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: translate('amount'),
                            labelStyle: TextStyle(color: Colors.grey.shade500),
                            prefixText: '',
                            prefixStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white.withOpacity(0.85),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(
                                color: Colors.grey.shade700,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(
                                color: Color(0xFFE65100),
                                width: 1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 16,
                            ),
                            errorText:
                                enteredAmount > 0 &&
                                    enteredAmountBase > availableBalanceBase
                                ? translate('exceedsAvailableBalance')
                                : null,
                            errorStyle: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: isLoading || !isValidAmount
                                ? null
                                : () async {
                                    setState(() => isLoading = true);

                                    try {
                                      final amountInBase = currencyState
                                          .convertToBase(enteredAmount);
                                      final updatedBalance = await ref
                                          .read(wingtopGameProvider.notifier)
                                          .transferToGame(amount: amountInBase);

                                      if (updatedBalance != null) {
                                        ref
                                            .read(walletProvider.notifier)
                                            .loadBalance();
                                        if (mounted) {
                                          Navigator.pop(context);
                                          ToastUtil.success(
                                            translate('transferSuccessful'),
                                          );
                                          _onRefreshGameCoins();
                                        }
                                      } else {
                                        ToastUtil.error(
                                          translate('transferFailed'),
                                        );
                                      }
                                    } catch (e) {
                                      ToastUtil.error('Transfer error: $e');
                                    } finally {
                                      setState(() => isLoading = false);
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE65100),
                              disabledBackgroundColor: Colors.grey.shade800,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.sports_esports_outlined,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        isValidAmount
                                            ? translate('transfer') +
                                                  ' ${enteredAmount.toStringAsFixed(2)}'
                                            : translate('enterAmount'),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    return Scaffold(
      backgroundColor: const Color.fromARGB(67, 77, 77, 77),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          translate('myWallet'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: translate('refresh'),
            onPressed: () {
              _onRefreshWallet();
            },
          ),
        ],
      ),
      body: _buildWalletTab(theme),
    );
  }

  Widget _buildWalletTab(ThemeData theme) {
    final walletState = ref.watch(walletProvider);
    final currencyState = ref.watch(currencyProvider);
    final gameState = ref.watch(wingtopGameProvider);

    return RefreshIndicator(
      onRefresh: _onRefreshWallet,
      color: Colors.white,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildBalanceCard(theme, walletState, currencyState),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: _buildGameStatsSection(
                theme,
                gameState,
                currencyState,
                ref,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(ThemeData theme, walletState, currencyState) {
    final balance = walletState.balance;
    final isLoading = walletState.isLoading;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);

    final localBalance = balance != null
        ? currencyState.convertFromBase(balance.balance)
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.primaryColor,
            theme.primaryColor.withBlue(
              (theme.primaryColor.blue * 0.7).toInt().clamp(0, 255),
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          const CircuitOverlay(color: Colors.white, opacity: 0.08),
          Positioned(right: 24, bottom: 24, child: const ChipDecoration()),
          Positioned(
            right: -40,
            top: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(62, 255, 255, 255),
              ),
            ),
          ),
          Positioned(
            left: -20,
            bottom: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            translate('myWallet'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      translate('totalBalance'),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (isLoading)
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    else
                      Text(
                        localBalance.toStringAsFixed(2),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(right: 60),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: walletState.isLoading || _isLoadingRecharge
                                ? null
                                : _onRecharge,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isLoadingRecharge)
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.primaryColor,
                                      ),
                                    )
                                  else
                                    Icon(
                                      Icons.add_circle_outline,
                                      color: theme.primaryColor,
                                      size: 18,
                                    ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      translate('rechargeWallet'),
                                      style: TextStyle(
                                        color: theme.primaryColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (localBalance > 0) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _showTransferDialog,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.swap_horiz,
                                      color: Colors.amber.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        translate('toGame'),
                                        style: TextStyle(
                                          color: Colors.amber.shade700,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatsSection(
    ThemeData theme,
    WingtopGameState gameState,
    CurrencyState currencyState,
    WidgetRef ref,
  ) {
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(Icons.bar_chart_outlined, size: 24, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                translate('gameStats'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.money,
                label: translate('totalRecharged'),
                value: gameState.totalRechargeAmount != null
                    ? currencyState
                          .convertFromBase(gameState.totalRechargeAmount!)
                          .toStringAsFixed(2)
                    : '--',
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                theme,
                icon: Icons.calendar_today,
                label: translate('playDays'),
                value: gameState.playDays != null
                    ? '${gameState.playDays}'
                    : '--',
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildFirstRechargeCard(theme, gameState, ref),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.15), color.withOpacity(0.08)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFirstRechargeCard(
    ThemeData theme,
    WingtopGameState gameState,
    WidgetRef ref,
  ) {
    final firstRecharge = gameState.firstRecharge;
    final i18n = ref.read(i18nNotifierProvider.notifier);
    String translate(String key) => i18n.translate(key);
    final hasFirstRecharge =
        firstRecharge != null && firstRecharge['hasFirstRecharge'] == true;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.15),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              hasFirstRecharge ? Icons.check_circle : Icons.card_giftcard,
              color: hasFirstRecharge ? Colors.green : Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  translate('firstRecharge'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hasFirstRecharge
                      ? translate('completed')
                      : translate('makeFirstRecharge'),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: hasFirstRecharge
                        ? Colors.green
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (!hasFirstRecharge)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showTransferDialog,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    translate('recharge'),
                    style: TextStyle(
                      color: Colors.amber.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CircuitOverlay extends StatelessWidget {
  const CircuitOverlay({
    super.key,
    this.color = const Color(0xFF44D3A8),
    this.opacity = 0.25,
  });

  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _CircuitPainter(color.withOpacity(opacity)),
        ),
      ),
    );
  }
}

class _CircuitPainter extends CustomPainter {
  _CircuitPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2;
    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.2)
      ..lineTo(size.width * 0.4, size.height * 0.2)
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.3,
      )
      ..lineTo(size.width * 0.8, size.height * 0.5)
      ..quadraticBezierTo(
        size.width * 0.85,
        size.height * 0.55,
        size.width * 0.9,
        size.height * 0.55,
      );

    canvas.drawPath(path, p);

    final b1 = Path()
      ..moveTo(size.width * 0.6, size.height * 0.3)
      ..lineTo(size.width * 0.55, size.height * 0.4)
      ..lineTo(size.width * 0.5, size.height * 0.45);
    canvas.drawPath(b1, p);

    final b2 = Path()
      ..moveTo(size.width * 0.4, size.height * 0.2)
      ..lineTo(size.width * 0.35, size.height * 0.28)
      ..lineTo(size.width * 0.3, size.height * 0.3);
    canvas.drawPath(b2, p);

    final node = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    for (final o in [
      Offset(size.width * 0.4, size.height * 0.2),
      Offset(size.width * 0.6, size.height * 0.3),
      Offset(size.width * 0.8, size.height * 0.5),
      Offset(size.width * 0.9, size.height * 0.55),
    ]) {
      canvas.drawCircle(o, 3, node);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChipDecoration extends StatelessWidget {
  const ChipDecoration({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 38,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5E6A9), Color(0xFFD4B463)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFB8A463), width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(1, 2)),
        ],
      ),
      child: CustomPaint(painter: _ChipPainter()),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = const Color(0xFFB8A463)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = Rect.fromLTWH(6, 6, size.width - 12, size.height - 12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      stroke,
    );

    for (double y = rect.top + 4; y < rect.bottom; y += 6) {
      canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), stroke);
    }

    for (double x = rect.left + 8; x < rect.right; x += 10) {
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), stroke);
    }

    final centerRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * 0.35,
      height: rect.height * 0.45,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(centerRect, const Radius.circular(2)),
      stroke,
    );

    final node = Paint()..color = const Color(0xFFB8A463);
    for (final o in [
      Offset(rect.left + 4, rect.top + 4),
      Offset(rect.right - 4, rect.top + 4),
      Offset(rect.left + 4, rect.bottom - 4),
      Offset(rect.right - 4, rect.bottom - 4),
    ]) {
      canvas.drawCircle(o, 2, node);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
