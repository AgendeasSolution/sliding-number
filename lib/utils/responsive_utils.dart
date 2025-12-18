import 'package:flutter/material.dart';

/// Utility class for responsive design calculations
/// Eliminates code duplication across pages
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Breakpoint definitions
  static const double smallMobileBreakpoint = 360.0;
  static const double mobileBreakpoint = 768.0;
  static const double largeMobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;

  /// Check if device is small mobile
  static bool isSmallMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < smallMobileBreakpoint || size.height < 600;
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= smallMobileBreakpoint && size.width < mobileBreakpoint;
  }

  /// Check if device is large mobile
  static bool isLargeMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= largeMobileBreakpoint && size.width < mobileBreakpoint;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= mobileBreakpoint && size.width < tabletBreakpoint;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= tabletBreakpoint;
  }

  /// Get responsive value based on screen size
  /// Returns appropriate value for current device type
  static double getResponsiveValue(
    BuildContext context, {
    required double smallMobile,
    required double mobile,
    required double largeMobile,
    required double tablet,
    required double desktop,
  }) {
    if (isSmallMobile(context)) return smallMobile;
    if (isMobile(context)) return mobile;
    if (isLargeMobile(context)) return largeMobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive integer value
  static int getResponsiveInt(
    BuildContext context, {
    required int smallMobile,
    required int mobile,
    required int largeMobile,
    required int tablet,
    required int desktop,
  }) {
    return getResponsiveValue(
      context,
      smallMobile: smallMobile.toDouble(),
      mobile: mobile.toDouble(),
      largeMobile: largeMobile.toDouble(),
      tablet: tablet.toDouble(),
      desktop: desktop.toDouble(),
    ).toInt();
  }

  /// Get responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    required EdgeInsets smallMobile,
    required EdgeInsets mobile,
    required EdgeInsets largeMobile,
    required EdgeInsets tablet,
    required EdgeInsets desktop,
  }) {
    if (isSmallMobile(context)) return smallMobile;
    if (isMobile(context)) return mobile;
    if (isLargeMobile(context)) return largeMobile;
    if (isTablet(context)) return tablet;
    return desktop;
  }

  /// Get responsive symmetric padding
  static EdgeInsets getResponsiveSymmetricPadding(
    BuildContext context, {
    required double horizontal,
    required double vertical,
  }) {
    return EdgeInsets.symmetric(
      horizontal: getResponsiveValue(
        context,
        smallMobile: horizontal * 0.75,
        mobile: horizontal,
        largeMobile: horizontal * 1.25,
        tablet: horizontal * 1.5,
        desktop: horizontal * 2.0,
      ),
      vertical: getResponsiveValue(
        context,
        smallMobile: vertical * 0.75,
        mobile: vertical,
        largeMobile: vertical * 1.25,
        tablet: vertical * 1.5,
        desktop: vertical * 2.0,
      ),
    );
  }
}
