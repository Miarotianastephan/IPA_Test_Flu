import 'package:flutter/material.dart';

class AutoScrollButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData icon;

  const AutoScrollButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.icon,
  });

  @override
  State<AutoScrollButton> createState() => _AutoScrollButtonState();
}

class _AutoScrollButtonState extends State<AutoScrollButton>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..addListener(() {
            if (_scrollController.hasClients) {
              _scrollController.jumpTo(
                _animationController.value *
                    _scrollController.position.maxScrollExtent,
              );
            }
          });
    _animationController.repeat(reverse: false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        maximumSize: const Size(160, 40),
      ),
      icon: Icon(widget.icon, color: Colors.black),
      label: SizedBox(
        width: 100,
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: Text(widget.text, style: const TextStyle(color: Colors.black)),
        ),
      ),
      onPressed: widget.onPressed,
    );
  }
}
