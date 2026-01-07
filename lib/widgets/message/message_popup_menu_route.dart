import 'package:flutter/material.dart';

class MessagePopupMenuRoute<T> extends PopupRoute<T> {
  final Widget child;
  final RelativeRect position;
  final Duration duration;

  MessagePopupMenuRoute({
    required this.child,
    required this.position,
    required this.duration,
  });

  @override
  Duration get transitionDuration => duration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return CustomSingleChildLayout(
      delegate: _CustomPopupMenuRouteLayout(position),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );
  }
}

class _CustomPopupMenuRouteLayout extends SingleChildLayoutDelegate {
  final RelativeRect position;

  _CustomPopupMenuRouteLayout(this.position);

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // Force menu to shift left relative to button by subtracting child width.
    // Add a small margin (e.g. 10px) so the popup appears nicely aligned.
    double x = position.left - childSize.width + 10;
    double y = position.top;

    // Prevent going too far left (allow small negative for aesthetic)
    if (x < -20) x = -20;

    // Prevent going too far down
    if (y + childSize.height > size.height) {
      y = size.height - childSize.height;
    }

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_CustomPopupMenuRouteLayout oldDelegate) =>
      position != oldDelegate.position;
}
