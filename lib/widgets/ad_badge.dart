import 'package:flutter/material.dart';

class AdBadge extends StatelessWidget {
  final double? fontSize;
  final double? horizontalPadding;
  final double? verticalPadding;
  final double? borderRadius;

  const AdBadge({
    super.key,
    this.fontSize,
    this.horizontalPadding,
    this.verticalPadding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 6,
        vertical: verticalPadding ?? 2,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(borderRadius ?? 4),
      ),
      child: Text(
        'AD',
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
