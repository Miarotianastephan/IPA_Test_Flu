import 'package:flutter/material.dart';

class TikTokPageScrollPhysics extends ScrollPhysics {
  const TikTokPageScrollPhysics({super.parent});

  @override
  TikTokPageScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return TikTokPageScrollPhysics(parent: buildParent(ancestor));
  }

  double _getPage(ScrollMetrics position) {
    return position.pixels / position.viewportDimension;
  }

  double _getPixels(double page, ScrollMetrics position) {
    return page * position.viewportDimension;
  }

  double _getTargetPixels(
    ScrollMetrics position,
    Tolerance tolerance,
    double velocity,
  ) {
    final double page = _getPage(position);
    final int lowerPage = page.floor();
    final int upperPage = page.ceil();
    final double fractionFromLower = page - lowerPage;
    final double fractionFromUpper = upperPage - page;

    const double dragThreshold = 0.05;
    const double velocityThreshold = 10.0;

    if (velocity > velocityThreshold) {
      return _getPixels((lowerPage + 1).toDouble(), position);
    }
    if (velocity < -velocityThreshold) {
      return _getPixels(lowerPage.toDouble(), position);
    }

    if (fractionFromLower <= dragThreshold) {
      return _getPixels(lowerPage.toDouble(), position);
    }
    if (fractionFromUpper <= dragThreshold) {
      return _getPixels(upperPage.toDouble(), position);
    }

    return _getPixels(page.roundToDouble(), position);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }

    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);

    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }

  @override
  SpringDescription get spring =>
      const SpringDescription(mass: 1.0, stiffness: 100.0, damping: 20.0);

  @override
  bool get allowImplicitScrolling => false;
}
