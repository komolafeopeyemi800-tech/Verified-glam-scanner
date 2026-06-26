import 'package:flutter/material.dart';

/// Responsive breakpoints for Verified Glam web (marketing + app shell).
/// Web-only — native mobile app uses its own layout.
class VGWebBreakpoints {
  VGWebBreakpoints._();

  static const double phone = 600;
  static const double compact = 900;
  static const double tablet = 768;
  static const double desktop = 1024;
  static const double wide = 1280;
  static const double maxContent = 1200;

  /// Fixed width of the desktop tool sidebar rail.
  static const double sidebarWidth = 260;

  static double widthOf(BuildContext context) => MediaQuery.sizeOf(context).width;

  static bool isPhone(BuildContext context) => widthOf(context) < phone;

  /// Stack two-column workspace / results layouts.
  static bool isCompact(BuildContext context) => widthOf(context) < compact;

  static bool isTablet(BuildContext context) => widthOf(context) >= tablet;

  static bool isDesktop(BuildContext context) => widthOf(context) >= desktop;

  static bool isWide(BuildContext context) => widthOf(context) >= wide;

  /// Use drawer instead of persistent sidebar in the web app shell.
  static bool useDrawerNav(BuildContext context) => widthOf(context) < desktop;

  /// Stack upload/tips in tool workspace when using drawer nav (phone + tablet).
  static bool stackToolWorkspace(BuildContext context) => useDrawerNav(context);

  /// Content area width inside the app shell (subtracts sidebar when visible).
  static double mainContentWidth(BuildContext context, {double sidebar = sidebarWidth}) {
    final w = widthOf(context);
    if (useDrawerNav(context)) return w;
    return w - sidebar;
  }

  static double contentPadding(BuildContext context) {
    final w = widthOf(context);
    if (w >= wide) return 48;
    if (w >= desktop) return 32;
    if (w >= tablet) return 24;
    return 16;
  }
}
