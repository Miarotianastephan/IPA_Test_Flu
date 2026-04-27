import 'package:flutter/material.dart';

class LazyIndexedStack extends StatefulWidget {
  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.placeholder = const SizedBox.shrink(),
  });

  final int index;
  final List<Widget> children;
  final Widget placeholder;

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  final Set<int> _loadedIndexes = <int>{};

  @override
  void initState() {
    super.initState();
    _markLoaded(widget.index);
  }

  @override
  void didUpdateWidget(covariant LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    _loadedIndexes.removeWhere((index) => index >= widget.children.length);
    _markLoaded(widget.index);
  }

  void _markLoaded(int index) {
    if (index >= 0 && index < widget.children.length) {
      _loadedIndexes.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: widget.index,
      children: List<Widget>.generate(widget.children.length, (index) {
        return _loadedIndexes.contains(index)
            ? widget.children[index]
            : widget.placeholder;
      }),
    );
  }
}
