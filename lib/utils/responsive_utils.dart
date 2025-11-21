import 'dart:math' as math;

import 'package:flutter/material.dart';

class Breakpoints {
  static const double xs = 0;
  static const double sm = 600;
  static const double md = 840;
  static const double lg = 1024;
  static const double xl = 1440;
  static const double xxl = 1920;
}

enum DeviceType { mobile, phablet, tablet, laptop, desktop, largeDesktop }

extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;

  DeviceType get deviceType {
    if (screenWidth < Breakpoints.sm) return DeviceType.mobile;
    if (screenWidth < Breakpoints.md) return DeviceType.phablet;
    if (screenWidth < Breakpoints.lg) return DeviceType.tablet;
    if (screenWidth < Breakpoints.xl) return DeviceType.laptop;
    if (screenWidth < Breakpoints.xxl) return DeviceType.desktop;
    return DeviceType.largeDesktop;
  }

  bool get isMobile => deviceType == DeviceType.mobile;
  bool get isPhablet => deviceType == DeviceType.phablet;
  bool get isTablet => deviceType == DeviceType.tablet;
  bool get isLaptop => deviceType == DeviceType.laptop;
  bool get isDesktop => deviceType == DeviceType.desktop;
  bool get isLargeDesktop => deviceType == DeviceType.largeDesktop;

  bool get isMobileDevice =>
      deviceType == DeviceType.mobile || deviceType == DeviceType.phablet;
  bool get isTabletDevice => deviceType == DeviceType.tablet;
  bool get isDesktopDevice =>
      deviceType == DeviceType.laptop ||
      deviceType == DeviceType.desktop ||
      deviceType == DeviceType.largeDesktop;

  double get scale {
    const baseWidth = 375.0;
    return math.min(screenWidth / baseWidth, 2.0);
  }

  double get adaptiveScale {
    if (isMobile) {
      const minWidth = 320.0;
      const maxWidth = 599.0;
      const minScale = 0.85;
      const maxScale = 1.0;

      final clampedWidth = math.max(minWidth, math.min(screenWidth, maxWidth));
      return minScale +
          (clampedWidth - minWidth) /
              (maxWidth - minWidth) *
              (maxScale - minScale);
    }

    if (isPhablet) {
      const minWidth = 600.0;
      const maxWidth = 839.0;
      const minScale = 1.0;
      const maxScale = 1.2;

      final clampedWidth = math.max(minWidth, math.min(screenWidth, maxWidth));
      return minScale +
          (clampedWidth - minWidth) /
              (maxWidth - minWidth) *
              (maxScale - minScale);
    }

    if (isTablet) {
      return 1.3;
    }

    return 1.5;
  }

  T responsive<T>({
    required T mobile,
    T? phablet,
    T? tablet,
    T? laptop,
    T? desktop,
    T? largeDesktop,
  }) {
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.phablet:
        return phablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? phablet ?? mobile;
      case DeviceType.laptop:
        return laptop ?? tablet ?? phablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? laptop ?? tablet ?? phablet ?? mobile;
      case DeviceType.largeDesktop:
        return largeDesktop ?? desktop ?? laptop ?? tablet ?? phablet ?? mobile;
    }
  }
}

class ResponsiveDimensions {
  final BuildContext context;

  ResponsiveDimensions(this.context);

  double get videoCardImageRatio {
    return context.responsive(
      mobile: _getMobileImageRatio(),
      phablet: _getPhabletImageRatio(),
      tablet: _getTabletImageRatio(),
      laptop: _getLaptopImageRatio(),
      desktop: 5.0,
      largeDesktop: 5.5,
    );
  }

  double _getMobileImageRatio() {
    final width = context.screenWidth;

    if (width < 375) {
      return 3.5;
    } else if (width < 390) {
      return 3.5;
    } else if (width < 430) {
      return 3.6;
    } else {
      return 3.5;
    }
  }

  double _getPhabletImageRatio() {
    final width = context.screenWidth;

    if (width < 700) {
      return 3.2;
    } else if (width < 768) {
      return 3.4;
    } else {
      return 2.4;
    }
  }

  double _getTabletImageRatio() {
    final width = context.screenWidth;

    if (width < 900) {
      return 3.8;
    } else if (width < 1000) {
      return 4.0;
    } else {
      return 2.4;
    }
  }

  double _getLaptopImageRatio() {
    final width = context.screenWidth;

    if (width < 900) {
      return 3.8;
    } else if (width < 1000) {
      return 4.0;
    } else {
      return 2.4;
    }
  }

  double get videoCardAvatarSize {
    return context.responsive(
      mobile: 17.0 + (context.adaptiveScale - 0.85) * 20.0,
      phablet: 22.0,
      tablet: 26.0,
      laptop: 28.0,
      desktop: 32.0,
    );
  }

  double get videoCardTitleFontSize {
    return context.responsive(
      mobile: 11.0 + (context.adaptiveScale - 0.85) * 13.3,
      phablet: 13.0,
      tablet: 14.0,
      laptop: 15.0,
      desktop: 16.0,
    );
  }

  double get videoCardInfoFontSize {
    return context.responsive(
      mobile: 10.0 + (context.adaptiveScale - 0.85) * 13.3,
      phablet: 12.0,
      tablet: 13.0,
      laptop: 14.0,
      desktop: 14.0,
    );
  }

  double get videoCardNicknameFontSize {
    return context.responsive(
      mobile: 11.0 + (context.adaptiveScale - 0.85) * 13.3,
      phablet: 13.0,
      tablet: 14.0,
      laptop: 15.0,
      desktop: 15.0,
    );
  }

  double get videoCardIconSize {
    return context.responsive(
      mobile: 12.0 + (context.adaptiveScale - 0.85) * 20.0,
      phablet: 15.0,
      tablet: 16.0,
      laptop: 17.0,
      desktop: 17.0,
    );
  }

  double get videoCardHorizontalPadding {
    return context.responsive(
      mobile: 10.0,
      phablet: 12.0,
      tablet: 14.0,
      laptop: 16.0,
      desktop: 18.0,
    );
  }

  double get videoCardVerticalPadding {
    return context.responsive(
      mobile: 8.0,
      phablet: 9.0,
      tablet: 10.0,
      laptop: 11.0,
      desktop: 12.0,
    );
  }
}
