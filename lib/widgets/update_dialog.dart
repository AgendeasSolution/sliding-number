import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../widgets/game_button.dart';
import '../services/app_update_service.dart';
import '../services/audio_service.dart';

/// Update dialog widget that shows when a new version is available
class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      enableDrag: true,
      builder: (context) => const UpdateDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Responsive values
    final screenSize = MediaQuery.of(context).size;
    final isSmallMobile = screenSize.width < 360;
    final isMobile = screenSize.width >= 360 && screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;

    // Responsive padding
    final horizontalPadding =
        isSmallMobile ? 16.0 : isMobile ? 20.0 : isTablet ? 24.0 : 28.0;
    final verticalPadding =
        isSmallMobile ? 16.0 : isMobile ? 20.0 : isTablet ? 24.0 : 28.0;

    // Responsive icon size (larger)
    final iconSize =
        isSmallMobile ? 80.0 : isMobile ? 100.0 : isTablet ? 120.0 : 140.0;

    // Responsive font sizes
    final titleFontSize =
        isSmallMobile ? 18.0 : isMobile ? 20.0 : isTablet ? 22.0 : 24.0;
    final descriptionFontSize =
        isSmallMobile ? 14.0 : isMobile ? 15.0 : isTablet ? 16.0 : 17.0;
    final closeIconSize =
        isSmallMobile ? 20.0 : isMobile ? 22.0 : isTablet ? 24.0 : 26.0;

    // Responsive spacing
    final iconSpacing =
        isSmallMobile ? 16.0 : isMobile ? 18.0 : isTablet ? 20.0 : 22.0;
    final textSpacing =
        isSmallMobile ? 10.0 : isMobile ? 12.0 : isTablet ? 14.0 : 16.0;
    final buttonSpacing =
        isSmallMobile ? 10.0 : isMobile ? 12.0 : isTablet ? 14.0 : 16.0;

    // Bottom padding for safe area
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        // Wood-style bottom sheet to match game theme
        color: AppColors.woodButtonFill,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppConstants.modalBorderRadius),
          topRight: Radius.circular(AppConstants.modalBorderRadius),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.woodButtonBorderDark,
            width: 2,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isSmallMobile
                    ? 12.0
                    : isMobile
                        ? 14.0
                        : isTablet
                            ? 16.0
                            : 18.0,
              ),
              decoration: BoxDecoration(
                color: AppColors.woodBackground.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.modalBorderRadius),
                  topRight: Radius.circular(AppConstants.modalBorderRadius),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.woodButtonBorderLight.withValues(alpha: 0.6),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title
                  Expanded(
                    child: Text(
                      'Update Available',
                      style: GoogleFonts.inter(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w800,
                        color: AppColors.woodTitleMain,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // Close button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        AudioService.instance.playClickSound();
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.woodButtonFill,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.woodButtonBorderDark,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: closeIconSize,
                          color: AppColors.woodButtonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: Column(
                children: [
                  // Update icon using asset image (no circle)
                  Image.asset(
                    'assets/img/game_icon.png',
                    width: iconSize,
                    height: iconSize,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: iconSpacing),
                  // Title
                  Text(
                    'New Version Available!',
                    style: GoogleFonts.inter(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.woodTitleMain,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: textSpacing),
                  // Description
                  Text(
                    'A new version of Sliding Number is available. Update now to enjoy the latest features and improvements!',
                    style: GoogleFonts.inter(
                      fontSize: descriptionFontSize,
                      color: AppColors.woodButtonText.withValues(alpha: 0.9),
                      height: 1.5,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Buttons in same row
            Padding(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                0,
                horizontalPadding,
                bottomPadding > 0 ? bottomPadding : verticalPadding,
              ),
              child: Row(
                children: [
                  // Update button with golden gradient
                  Expanded(
                    child: GameButton(
                      label: 'Update Now',
                      onPressed: () {
                        AudioService.instance.playClickSound();
                        AppUpdateService.instance.launchStorePage();
                      },
                      gradient: const LinearGradient(
                        colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
                      ),
                    ),
                  ),
                  SizedBox(width: buttonSpacing),
                  // Later button
                  Expanded(
                    child: GameButton(
                      label: 'Later',
                      onPressed: () {
                        AudioService.instance.playClickSound();
                        Navigator.of(context).pop();
                      },
                      gradient: const LinearGradient(
                        colors: [AppColors.neutral, AppColors.neutralDark],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
