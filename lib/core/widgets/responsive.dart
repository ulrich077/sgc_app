import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

enum ScreenType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static ScreenType of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppSizes.breakpointMobile) return ScreenType.mobile;
    if (width < AppSizes.breakpointTablet) return ScreenType.tablet;
    return ScreenType.desktop;
  }

  static bool isMobile(BuildContext context) =>
      of(context) == ScreenType.mobile;
  static bool isTablet(BuildContext context) =>
      of(context) == ScreenType.tablet;
  static bool isDesktop(BuildContext context) =>
      of(context) == ScreenType.desktop;
}
