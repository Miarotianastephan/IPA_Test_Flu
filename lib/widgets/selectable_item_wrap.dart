import 'package:flutter/material.dart';
import 'package:live_app/widgets/selectable_item.dart';

class SelectableItemWrap<T> extends StatelessWidget {
  final List<T> items;
  final String Function(T item) getName;
  final void Function(T item)? onTap;
  final Color textColor;
  final double fontSize;
  final Color backgroundColor;
  final double borderRadius;
  final VoidCallback? onBeforeTap;

  const SelectableItemWrap({
    super.key,
    required this.items,
    required this.getName,
    this.onTap,
    this.textColor = Colors.white,
    this.fontSize = 12,
    this.backgroundColor = Colors.white24,
    this.borderRadius = 4,
    this.onBeforeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 4,
        runSpacing: 10,
        children: items
            .map(
              (item) => SelectableItem<T>(
                item: item,
                getName: getName,
                onTap: onTap,
                onBeforeTap: onBeforeTap,
                textColor: textColor,
                fontSize: fontSize,
                backgroundColor: backgroundColor,
                borderRadius: borderRadius,
              ),
            )
            .toList(),
      ),
    );
  }
}
