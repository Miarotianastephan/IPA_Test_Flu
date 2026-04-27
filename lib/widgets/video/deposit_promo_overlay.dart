import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:live_app/provider/i18n_provider.dart';

enum DepositPromoDisplayMode { fullscreen, compact }

class DepositPromoOverlay extends ConsumerWidget {
  final VoidCallback onDepositPressed;
  final DepositPromoDisplayMode displayMode;

  const DepositPromoOverlay({
    super.key,
    required this.onDepositPressed,
    this.displayMode = DepositPromoDisplayMode.fullscreen,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    final content = _buildContent(i18n);

    if (displayMode == DepositPromoDisplayMode.fullscreen) {
      return Positioned.fill(
        child: Container(
          color: Colors.black54,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: content,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
      ),
      child: content,
    );
  }

  Widget _buildContent(dynamic i18n) {
    final isCompact = displayMode == DepositPromoDisplayMode.compact;
    final iconSize = isCompact ? 28.0 : 48.0;
    final iconPadding = isCompact ? 10.0 : 16.0;
    final titleFontSize = isCompact ? 16.0 : 24.0;
    final messageFontSize = isCompact ? 12.0 : 16.0;
    final spacing = isCompact ? 8.0 : 24.0;
    final smallSpacing = isCompact ? 6.0 : 12.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isCompact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          padding: EdgeInsets.all(iconPadding),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Colors.amber.shade400, Colors.orange.shade600],
            ),
          ),
          child: Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: iconSize,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          i18n.translate('vipMembership'),
          style: TextStyle(
            color: Colors.white,
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: smallSpacing),
        Text(
          i18n.translate('vipFirstDepositUnlockMessage'),
          style: TextStyle(color: Colors.white70, fontSize: messageFontSize),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: spacing),
        _DepositButton(onPressed: onDepositPressed, compact: isCompact),
      ],
    );
  }
}

class _DepositButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final bool compact;

  const _DepositButton({required this.onPressed, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final i18n = ref.read(i18nNotifierProvider.notifier);

    final horizontalPadding = compact ? 16.0 : 24.0;
    final verticalPadding = compact ? 8.0 : 12.0;
    final iconSize = compact ? 16.0 : 20.0;
    final fontSize = compact ? 13.0 : 16.0;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.amber.shade400, Colors.orange.shade600],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.videogame_asset, color: Colors.white, size: iconSize),
            const SizedBox(width: 8),
            Text(
              i18n.translate('goToGame'),
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
