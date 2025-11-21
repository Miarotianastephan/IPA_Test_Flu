import 'package:flutter/material.dart';

class SelectableItem<T> extends StatelessWidget {
  final T item;
  final String Function(T) getName;
  final void Function(T)? onTap;
  final VoidCallback? onBeforeTap;
  final Color textColor;
  final double fontSize;
  final Color backgroundColor;
  final double borderRadius;

  const SelectableItem({
    super.key,
    required this.item,
    required this.getName,
    this.onTap,
    this.onBeforeTap,
    required this.textColor,
    required this.fontSize,
    required this.backgroundColor,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onBeforeTap != null) onBeforeTap!();
        if (onTap != null) onTap!(item);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Text(
          getName(item),
          style: TextStyle(color: textColor, fontSize: fontSize),
        ),
      ),
    );
  }
}