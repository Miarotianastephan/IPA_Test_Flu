import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/models/vip.dart';
import 'package:live_app/page/vip_detail_page.dart';
import 'package:live_app/provider/currency_provider.dart';
import 'package:live_app/provider/i18n_provider.dart';
import 'package:live_app/provider/my_user_provider.dart';
import 'package:live_app/provider/vip_provider.dart';
import 'package:live_app/utils/json_utils.dart';
import 'package:live_app/widgets/encrypted_image.dart';
import 'package:live_app/widgets/payment/vip_purchase_dialog.dart';

class VipListPage extends ConsumerStatefulWidget {
  const VipListPage({super.key});

  @override
  ConsumerState<VipListPage> createState() => _VipListPageState();
}

class _VipListPageState extends ConsumerState<VipListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(vipProvider.notifier).loadVips().then((_) {
        if (mounted) _animController.forward();
      });
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vipProvider);
    final theme = Theme.of(context);
    final i18n = ref.read(i18nNotifierProvider.notifier);
    final currencyState = ref.watch(currencyProvider);
    final userVip = ref.watch(userProvider).user;
    final userVipId = userVip?.vip?.id;
    final sortedVips = [...state.vips]
      ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(i18n.translate("vipMembership"))),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (state.loading)
            SliverFillRemaining(child: _buildSkeletonLoader(theme))
          else if (state.error != null)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${i18n.translate('errorLoadingVips')}: ${state.error}",
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.read(vipProvider.notifier).loadVips();
                      },
                      child: Text(i18n.translate("retry")),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final vip = sortedVips[index];
                  return AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                          0,
                          50 * (1 - _animController.value) +
                              (index * 10).clamp(0, 30),
                        ),
                        child: Opacity(
                          opacity: (_animController.value - (index * 0.1))
                              .clamp(0.0, 1.0),
                          child: _buildVipCard(
                            context,
                            currencyState,
                            vip,
                            theme,
                            userVipId,
                            i18n,
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: sortedVips.length),
              ),
            ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildSkeletonLoader(ThemeData theme) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 180,
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const _ShimmerLoading(child: SizedBox.expand()),
        );
      },
    );
  }

  Widget _buildVipCard(
    BuildContext context,
    CurrencyState currencyState,
    Vip vip,
    ThemeData theme,
    String? userVipId,
    dynamic i18n,
  ) {
    final translation = vip.translations;

    final title = translation.name;
    final description = translation.description;

    final isRecommended = vip.isRecommended;
    final isCurrent = vip.id == userVipId;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: isRecommended
                ? const Color(0xFFFFD700).withOpacity(0.3)
                : Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VipDetailPage(vip: vip)),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: isRecommended
                  ? const LinearGradient(
                      colors: [Color(0xFF2C2C2C), Color(0xFF000000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        theme.cardColor,
                        theme.cardColor.withOpacity(0.95),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(24),
              border: isRecommended
                  ? Border.all(color: const Color(0xFFFFD700), width: 1.5)
                  : Border.all(color: theme.dividerColor.withOpacity(0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (vip.logoUrl.isNotEmpty)
                          EncryptedImage(
                            url: vip.logoUrl,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                          ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isRecommended
                                    ? Colors.white
                                    : theme.textTheme.titleLarge?.color,
                              ),
                            ),
                            if (isCurrent)
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Active Plan",
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    if (isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFD700), Color(0xFFFFA000)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFD700).withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          i18n.translate('recommended'),
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRecommended ? Colors.grey[400] : Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${vip.validDays} ${i18n.translate('days')}",
                      style: TextStyle(
                        fontSize: 14,
                        color: isRecommended
                            ? Colors.grey[400]
                            : Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyState
                              .convertFromBase(parseDouble(vip.basePrice))
                              .toStringAsFixed(2),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isRecommended
                                ? Colors.white
                                : theme.textTheme.titleLarge?.color,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!isCurrent) ...[
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRecommended
                            ? const Color(0xFFFFD700)
                            : theme.primaryColor,
                        foregroundColor: isRecommended
                            ? Colors.black
                            : Colors.white,
                        elevation: isRecommended ? 8 : 4,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: isRecommended
                              ? BorderSide.none
                              : BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      onPressed: () async {
                        await VipPurchaseDialog.show(
                          context: context,
                          ref: ref,
                          vip: vip,
                        );
                      },
                      child: Text(
                        i18n.translate('purchase'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShimmerLoading extends StatefulWidget {
  final Widget child;

  const _ShimmerLoading({required this.child});

  @override
  State<_ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<_ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFFEBEBF4),
                Color(0xFFF4F4F4),
                Color(0xFFEBEBF4),
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              transform: GradientRotation(_animation.value * 0.5),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}
