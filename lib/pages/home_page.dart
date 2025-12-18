import 'dart:async';
import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../widgets/game_button.dart';
import '../widgets/modal_container.dart';
import '../widgets/modal_header.dart';
import '../widgets/modal_footer.dart';
import '../widgets/instruction_item.dart';
import '../widgets/ad_banner.dart';
import '../widgets/sound_toggle_button.dart';
import '../services/level_progression_service.dart';
import '../services/audio_service.dart';
import '../services/app_update_service.dart';
import '../widgets/update_dialog.dart';
import '../utils/game_utils.dart';
import 'game_page.dart';
import 'other_games_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _cardsAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _cardsAnimation;
  late Animation<double> _particleAnimation;
  late PageController _pageController;
  int _currentPageIndex = 0;
  
  List<int> _unlockedLevels = [1]; // Default to only level 1 unlocked
  List<int> _completedLevels = []; // Track completed levels
  int _lastOpenedLevel = 1; // Track the last opened level

  @override
  void initState() {
    super.initState();
    final int totalPages = (AppConstants.maxLevel / 9).ceil();
    _pageController = PageController();
    // Animations disabled
    
    // Defer heavy operations to prevent blocking UI rendering
    // Use microtask to ensure UI is rendered first, then run background tasks
    Future.microtask(() async {
      if (!mounted) return;
      
      try {
        // Initialize audio service (non-blocking, fire-and-forget)
        AudioService.instance.initialize();
        
        // Load unlocked levels (async, won't block UI)
        _loadUnlockedLevels();
      } catch (e) {
        // Silent error - use defaults if loading fails
        if (mounted) {
          setState(() {
            _unlockedLevels = [1];
            _completedLevels = [];
          });
        }
      }
    });
    
    // Check for app updates after UI is fully loaded and responsive
    // Longer delay ensures UI is interactive before network call
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkForUpdates();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadUnlockedLevels() async {
    try {
      final unlockedLevels = await LevelProgressionService.getUnlockedLevels()
          .timeout(const Duration(seconds: 3), onTimeout: () => [1]);
      final completedLevels = await LevelProgressionService.getCompletedLevels()
          .timeout(const Duration(seconds: 3), onTimeout: () => <int>[]);
      final lastOpenedLevel = await LevelProgressionService.getLastOpenedLevel()
          .timeout(const Duration(seconds: 3), onTimeout: () => 1);
      
      if (mounted) {
        setState(() {
          _unlockedLevels = unlockedLevels;
          _completedLevels = completedLevels;
          _lastOpenedLevel = lastOpenedLevel;
        });
      }
    } catch (e) {
      // Silent error - use defaults to prevent crash
      if (mounted) {
        setState(() {
          _unlockedLevels = [1];
          _completedLevels = [];
          _lastOpenedLevel = 1;
        });
      }
    }
  }

  Future<void> _checkForUpdates() async {
    if (!mounted) return;
    
    try {
      // Use timeout to prevent ANR - never wait more than 8 seconds
      final isUpdateAvailable = await AppUpdateService.instance
          .isUpdateAvailable()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => false,
          );

      if (!isUpdateAvailable || !mounted) return;

      // Only show the update dialog once per day
      final shouldShowToday =
          await AppUpdateService.instance.shouldShowUpdatePromptToday();

      if (shouldShowToday && mounted && context.mounted) {
        UpdateDialog.show(context);
        // Record that we've shown it for today
        AppUpdateService.instance.recordUpdatePromptShown();
      }
    } catch (e) {
      // Silent error handling - never interrupt user experience
      // Don't even log in production to avoid any overhead
    }
  }

  // Responsive breakpoints and helper methods
  bool _isSmallMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width < 360 || size.height < 600;
  }
  
  bool _isMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 360 && size.width < 768;
  }
  
  bool _isLargeMobile(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 600 && size.width < 768;
  }
  
  bool _isTablet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width >= 768 && size.width < 1024;
  }
  
  
  // Get responsive values
  double _getResponsiveValue(BuildContext context, {
    required double smallMobile,
    required double mobile,
    required double largeMobile,
    required double tablet,
    required double desktop,
  }) {
    if (_isSmallMobile(context)) return smallMobile;
    if (_isMobile(context)) return mobile;
    if (_isLargeMobile(context)) return largeMobile;
    if (_isTablet(context)) return tablet;
    return desktop;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundImage,
        child: SafeArea(
          child: Column(
            children: [
              // Main content area
              Expanded(
                child: Stack(
                  children: [
                    // Animated background particles
                    _buildAnimatedBackground(),
                    // Main content
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: _getResponsiveValue(context,
                          smallMobile: 12.0,
                          mobile: 16.0,
                          largeMobile: 20.0,
                          tablet: 24.0,
                          desktop: 32.0,
                        ),
                        vertical: _getResponsiveValue(context,
                          smallMobile: 8.0,
                          mobile: 12.0,
                          largeMobile: 16.0,
                          tablet: 20.0,
                          desktop: 24.0,
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: _getResponsiveValue(context,
                            smallMobile: 32.0,
                            mobile: 40.0,
                            largeMobile: 48.0,
                            tablet: 56.0,
                            desktop: 64.0,
                          )),
                          _buildHeader(context),
                          SizedBox(height: _getResponsiveValue(context,
                            smallMobile: 16.0,
                            mobile: 20.0,
                            largeMobile: 24.0,
                            tablet: 28.0,
                            desktop: 32.0,
                          )),
                          Expanded(
                            child: _buildLevelGrid(context),
                          ),
                        ],
                      ),
                    ),
                    // Top corner buttons
                    Positioned(
                      top: _getResponsiveValue(context,
                        smallMobile: 4.0,
                        mobile: 6.0,
                        largeMobile: 8.0,
                        tablet: 10.0,
                        desktop: 12.0,
                      ),
                      left: _getResponsiveValue(context,
                        smallMobile: 12.0,
                        mobile: 16.0,
                        largeMobile: 20.0,
                        tablet: 24.0,
                        desktop: 28.0,
                      ),
                      child: _buildHowToPlayButton(context),
                    ),
                    Positioned(
                      top: _getResponsiveValue(context,
                        smallMobile: 4.0,
                        mobile: 6.0,
                        largeMobile: 8.0,
                        tablet: 10.0,
                        desktop: 12.0,
                      ),
                      right: _getResponsiveValue(context,
                        smallMobile: 12.0,
                        mobile: 16.0,
                        largeMobile: 20.0,
                        tablet: 24.0,
                        desktop: 28.0,
                      ),
                      child: _buildSoundButton(context),
                    ),
                  ],
                ),
              ),
              // Explore More Games section - positioned above ad banner
              _buildExploreMoreSection(context),
              // Ad banner at the bottom - independent from other elements
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    // Animation disabled - return empty container
    return const SizedBox.shrink();
  }

  Widget _buildHeader(BuildContext context) {
    // Responsive font sizes for all screen sizes - smaller logo
    final fontSize = _getResponsiveValue(context,
      smallMobile: 28.0,
      mobile: 32.0,
      largeMobile: 36.0,
      tablet: 40.0,
      desktop: 44.0,
    );
    
    final letterSpacing = _getResponsiveValue(context,
      smallMobile: 1.5,
      mobile: 2.0,
      largeMobile: 2.5,
      tablet: 3.0,
      desktop: 3.5,
    );
    
    final topMargin = _getResponsiveValue(context,
      smallMobile: 8.0,
      mobile: 12.0,
      largeMobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    
    final lineWidth = _getResponsiveValue(context,
      smallMobile: 70.0,
      mobile: 80.0,
      largeMobile: 90.0,
      tablet: 100.0,
      desktop: 110.0,
    );
    
    final lineHeight = _getResponsiveValue(context,
      smallMobile: 2.0,
      mobile: 2.5,
      largeMobile: 3.0,
      tablet: 3.5,
      desktop: 4.0,
    );
    
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Column(
        children: [
          // Main title text - matching splash screen
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.logoGradientStart,
                AppColors.logoGradientMid,
                AppColors.logoGradientEnd,
              ],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            child: Text(
              'SLIDING NUMBER',
              style: GoogleFonts.orbitron(
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: letterSpacing,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.8),
                    offset: const Offset(2, 2),
                    blurRadius: 6,
                  ),
                  Shadow(
                    color: AppColors.primaryGold.withValues(alpha: 0.5),
                    offset: const Offset(0, 0),
                    blurRadius: 15,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: _getResponsiveValue(context,
            smallMobile: 8.0,
            mobile: 10.0,
            largeMobile: 12.0,
            tablet: 14.0,
            desktop: 16.0,
          )),
          // Line below logo - matching splash screen
          Container(
            height: lineHeight,
            width: lineWidth,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildLevelGrid(BuildContext context) {
    // Carousel with 3x3 grid per page
    const int itemsPerPage = 9; // 3 rows × 3 columns
    final int totalPages = (AppConstants.maxLevel / itemsPerPage).ceil();
    
    final crossAxisSpacing = _getResponsiveValue(context,
      smallMobile: 8.0,
      mobile: 10.0,
      largeMobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    
    final mainAxisSpacing = _getResponsiveValue(context,
      smallMobile: 8.0,
      mobile: 10.0,
      largeMobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );
    
    final childAspectRatio = _getResponsiveValue(context,
      smallMobile: 0.9,
      mobile: 0.9,
      largeMobile: 0.9,
      tablet: 0.9,
      desktop: 0.9,
    );
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Calculate the height needed for 3 rows
            final availableWidth = constraints.maxWidth;
            final itemWidth = (availableWidth - (crossAxisSpacing * 2)) / 3;
            final itemHeight = itemWidth / childAspectRatio;
            final gridHeight = (itemHeight * 3) + (mainAxisSpacing * 2);
            
            return SizedBox(
              height: gridHeight,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                  });
                },
                itemCount: totalPages,
                itemBuilder: (context, pageIndex) {
                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3, // Fixed 3 columns
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: childAspectRatio,
                    ),
                    itemCount: itemsPerPage,
                    itemBuilder: (context, gridIndex) {
                      final levelIndex = (pageIndex * itemsPerPage) + gridIndex;
                      if (levelIndex >= AppConstants.maxLevel) {
                        // Empty slot for last page if not full
                        return const SizedBox.shrink();
                      }
                      final level = levelIndex + 1;
                      final gridDimensions = GameUtils.calculateGridSize(level);
                      return _buildLevelCard(context, level, gridDimensions.rows, gridDimensions.columns, levelIndex);
                    },
                  );
                },
              ),
            );
          },
        ),
        // Page indicators with gap from carousel
        if (totalPages > 1)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                totalPages,
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.jumpToPage(index);
                  },
                  child: Container(
                    width: _currentPageIndex == index ? 24.0 : 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: _currentPageIndex == index
                          ? const LinearGradient(
                              colors: [
                                AppColors.primaryGold,
                                AppColors.primaryGoldDark,
                              ],
                            )
                          : null,
                      color: _currentPageIndex == index
                          ? null
                          : AppColors.primaryGold.withValues(alpha: 0.3),
                      boxShadow: _currentPageIndex == index
                          ? [
                              BoxShadow(
                                color: AppColors.primaryGold.withValues(alpha: 0.6),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHowToPlayButton(BuildContext context) {
    final buttonSize = _getResponsiveValue(context,
      smallMobile: 38.0,
      mobile: 42.0,
      largeMobile: 46.0,
      tablet: 50.0,
      desktop: 54.0,
    );
    
    return GestureDetector(
      onTap: () {
        AudioService.instance.playClickSound();
        _showHowToPlayModal(context);
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2A2F4D),
              Color(0xFF1A1F3A),
            ],
          ),
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: AppColors.primaryGold.withValues(alpha: 0.4),
            width: 2.0,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.help_outline_rounded,
          color: AppColors.primaryGold,
          size: buttonSize * 0.6,
        ),
      ),
    );
  }

  Widget _buildSoundButton(BuildContext context) {
    final buttonSize = _getResponsiveValue(context,
      smallMobile: 38.0,
      mobile: 42.0,
      largeMobile: 46.0,
      tablet: 50.0,
      desktop: 54.0,
    );
    
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(milliseconds: 100))
          .map((_) => AudioService.instance.isSoundEnabled),
      builder: (context, snapshot) {
        final isSoundEnabled = snapshot.data ?? AudioService.instance.isSoundEnabled;
        return GestureDetector(
          onTap: () async {
            await AudioService.instance.toggleSound();
            AudioService.instance.playClickSound();
          },
          child: Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A2F4D),
                  Color(0xFF1A1F3A),
                ],
              ),
              borderRadius: BorderRadius.circular(14.0),
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.4),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isSoundEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: AppColors.primaryGold,
              size: buttonSize * 0.6,
            ),
          ),
        );
      },
    );
  }

  Widget _buildExploreMoreSection(BuildContext context) {
    final buttonSpacing = _getResponsiveValue(context,
      smallMobile: 12.0,
      mobile: 16.0,
      largeMobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    
    final gamesButtonWidth = _getResponsiveValue(context,
      smallMobile: 140.0,
      mobile: 150.0,
      largeMobile: 160.0,
      tablet: 170.0,
      desktop: 180.0,
    );
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(context,
          smallMobile: 12.0,
          mobile: 14.0,
          largeMobile: 16.0,
          tablet: 18.0,
          desktop: 20.0,
        ),
        vertical: _getResponsiveValue(context,
          smallMobile: 6.0,
          mobile: 8.0,
          largeMobile: 10.0,
          tablet: 12.0,
          desktop: 14.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [
                  AppColors.primaryGold,
                  AppColors.primaryGoldLight,
                  AppColors.primaryGold,
                ],
                stops: [0.0, 0.5, 1.0],
              ).createShader(bounds),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_rounded,
                    color: Colors.white,
                    size: _getResponsiveValue(context,
                      smallMobile: 18.0,
                      mobile: 20.0,
                      largeMobile: 22.0,
                      tablet: 24.0,
                      desktop: 26.0,
                    ),
                  ),
                  SizedBox(width: _getResponsiveValue(context,
                    smallMobile: 6.0,
                    mobile: 8.0,
                    largeMobile: 10.0,
                    tablet: 12.0,
                    desktop: 14.0,
                  )),
                  Text(
                    'Explore More Games',
                    style: GoogleFonts.orbitron(
                      fontSize: _getResponsiveValue(context,
                        smallMobile: 12.0,
                        mobile: 14.0,
                        largeMobile: 16.0,
                        tablet: 18.0,
                        desktop: 20.0,
                      ),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      shadows: [
                        Shadow(
                          color: AppColors.primaryGold.withValues(alpha: 0.6),
                          offset: const Offset(0, 2),
                          blurRadius: 10,
                        ),
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          offset: const Offset(0, 1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: _getResponsiveValue(context,
            smallMobile: 6.0,
            mobile: 8.0,
            largeMobile: 10.0,
            tablet: 12.0,
            desktop: 14.0,
          )),
          Row(
            children: [
              Expanded(
                child: _buildGameButton(
                  context,
                  label: 'Mobile Games',
                  onPressed: () {
                    AudioService.instance.playClickSound();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const OtherGamesPage(),
                      ),
                    );
                  },
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9F7AEA), Color(0xFF805AD5)],
                  ),
                  icon: Icons.smartphone_rounded,
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: _buildGameButton(
                  context,
                  label: 'Web Games',
                  onPressed: () {
                    AudioService.instance.playClickSound();
                    _launchWebGamesUrl(context);
                  },
                  gradient: const LinearGradient(
                    colors: [AppColors.info, AppColors.infoDark],
                  ),
                  icon: Icons.computer_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _launchWebGamesUrl(BuildContext context) async {
    const String url = 'https://freegametoplay.com';
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open web games link'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening web games: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }


  Widget _buildAnimatedButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Color? color,
    Gradient? gradient,
    required dynamic icon,
  }) {
    return Container(
            decoration: BoxDecoration(
              color: color,
              gradient: gradient,
              borderRadius: BorderRadius.circular(_getResponsiveValue(context,
                smallMobile: 8.0,
                mobile: 10.0,
                largeMobile: 12.0,
                tablet: 14.0,
                desktop: 16.0,
              )),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (gradient?.colors.first ?? color!).withValues(alpha: 0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: (gradient?.colors.first ?? color!).withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(_getResponsiveValue(context,
                  smallMobile: 8.0,
                  mobile: 10.0,
                  largeMobile: 12.0,
                  tablet: 14.0,
                  desktop: 16.0,
                )),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: _getResponsiveValue(context,
                      smallMobile: 6.0,
                      mobile: 8.0,
                      largeMobile: 10.0,
                      tablet: 12.0,
                      desktop: 14.0,
                    ),
                    horizontal: _getResponsiveValue(context,
                      smallMobile: 8.0,
                      mobile: 10.0,
                      largeMobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon is String)
                        Text(
                          icon,
                          style: TextStyle(fontSize: _getResponsiveValue(context,
                            smallMobile: 16.0,
                            mobile: 18.0,
                            largeMobile: 20.0,
                            tablet: 22.0,
                            desktop: 24.0,
                          )),
                        )
                      else if (icon is IconData)
                        Icon(
                          icon,
                          size: _getResponsiveValue(context,
                            smallMobile: 16.0,
                            mobile: 18.0,
                            largeMobile: 20.0,
                            tablet: 22.0,
                            desktop: 24.0,
                          ),
                          color: Colors.white,
                        ),
                      if (label.isNotEmpty) ...[
                        SizedBox(width: _getResponsiveValue(context,
                          smallMobile: 6.0,
                          mobile: 8.0,
                          largeMobile: 10.0,
                          tablet: 12.0,
                          desktop: 14.0,
                        )),
                        Flexible(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: _getResponsiveValue(context,
                                smallMobile: 12.0,
                                mobile: 14.0,
                                largeMobile: 16.0,
                                tablet: 18.0,
                                desktop: 20.0,
                              ),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
  }


  Widget _buildGameButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    required Gradient gradient,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(_getResponsiveValue(context,
          smallMobile: 14.0,
          mobile: 16.0,
          largeMobile: 18.0,
          tablet: 20.0,
          desktop: 22.0,
        )),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.4),
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.5),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(_getResponsiveValue(context,
            smallMobile: 14.0,
            mobile: 16.0,
            largeMobile: 18.0,
            tablet: 20.0,
            desktop: 22.0,
          )),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: _getResponsiveValue(context,
                      smallMobile: 8.0,
                      mobile: 10.0,
                      largeMobile: 12.0,
                      tablet: 14.0,
                      desktop: 16.0,
                    ),
                    horizontal: _getResponsiveValue(context,
                      smallMobile: 10.0,
                      mobile: 12.0,
                      largeMobile: 14.0,
                      tablet: 16.0,
                      desktop: 18.0,
                    ),
                  ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: _getResponsiveValue(context,
                    smallMobile: 22.0,
                    mobile: 24.0,
                    largeMobile: 26.0,
                    tablet: 28.0,
                    desktop: 30.0,
                  ),
                  color: Colors.white,
                ),
                SizedBox(width: _getResponsiveValue(context,
                  smallMobile: 6.0,
                  mobile: 8.0,
                  largeMobile: 10.0,
                  tablet: 12.0,
                  desktop: 14.0,
                )),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.orbitron(
                      fontSize: _getResponsiveValue(context,
                        smallMobile: 12.0,
                        mobile: 14.0,
                        largeMobile: 16.0,
                        tablet: 18.0,
                        desktop: 20.0,
                      ),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          offset: const Offset(2, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelCard(BuildContext context, int level, int rows, int columns, int index) {
    final maxDimension = rows > columns ? rows : columns;
    final difficulty = _getDifficultyText(maxDimension);
    final isUnlocked = _unlockedLevels.contains(level);
    final isCompleted = _completedLevels.contains(level);
    
    // Calculate responsive values
    final cardPadding = _getResponsiveValue(context,
      smallMobile: 4.0,
      mobile: 5.0,
      largeMobile: 6.0,
      tablet: 8.0,
      desktop: 10.0,
    );
    
    final iconSize = _getResponsiveValue(context,
      smallMobile: 28.0,
      mobile: 32.0,
      largeMobile: 36.0,
      tablet: 40.0,
      desktop: 44.0,
    );
    
    final checkmarkSpacing = _getResponsiveValue(context,
      smallMobile: 4.0,
      mobile: 5.0,
      largeMobile: 6.0,
      tablet: 7.0,
      desktop: 8.0,
    );
    
    final checkmarkSize = _getResponsiveValue(context,
      smallMobile: 12.0,
      mobile: 14.0,
      largeMobile: 16.0,
      tablet: 18.0,
      desktop: 20.0,
    );
    
    final gridSpacing = _getResponsiveValue(context,
      smallMobile: 1.0,
      mobile: 1.5,
      largeMobile: 2.0,
      tablet: 2.5,
      desktop: 3.0,
    );
    
    final gridPaddingH = _getResponsiveValue(context,
      smallMobile: 3.0,
      mobile: 4.0,
      largeMobile: 5.0,
      tablet: 6.0,
      desktop: 7.0,
    );
    
    final gridPaddingV = _getResponsiveValue(context,
      smallMobile: 1.0,
      mobile: 1.5,
      largeMobile: 2.0,
      tablet: 2.5,
      desktop: 3.0,
    );
    
    final gridFontSize = _getResponsiveValue(context,
      smallMobile: 7.0,
      mobile: 8.0,
      largeMobile: 9.0,
      tablet: 10.0,
      desktop: 11.0,
    );
    
    final statusSpacing = _getResponsiveValue(context,
      smallMobile: 0.5,
      mobile: 1.0,
      largeMobile: 1.5,
      tablet: 2.0,
      desktop: 2.5,
    );
    
    final statusFontSize = _getResponsiveValue(context,
      smallMobile: 6.0,
      mobile: 7.0,
      largeMobile: 8.0,
      tablet: 9.0,
      desktop: 10.0,
    );
    
    return _LevelCard(
      level: level,
      rows: rows,
      columns: columns,
      difficulty: difficulty,
      isUnlocked: isUnlocked,
      isCompleted: isCompleted,
      isLastOpened: level == _lastOpenedLevel,
      cardPadding: cardPadding,
      iconSize: iconSize,
      checkmarkSpacing: checkmarkSpacing,
      checkmarkSize: checkmarkSize,
      gridSpacing: gridSpacing,
      gridPaddingH: gridPaddingH,
      gridPaddingV: gridPaddingV,
      gridFontSize: gridFontSize,
      statusSpacing: statusSpacing,
      statusFontSize: statusFontSize,
      onTap: isUnlocked ? () {
        AudioService.instance.playClickSound();
        _startLevel(context, level);
      } : null,
    );
  }



  String _getDifficultyText(int gridSize) {
    if (gridSize <= 4) return 'Easy';
    if (gridSize <= 6) return 'Medium';
    if (gridSize <= 8) return 'Hard';
    return 'Expert';
  }

  void _startLevel(BuildContext context, int level) async {
    // Save the last opened level
    await LevelProgressionService.setLastOpenedLevel(level);
    if (mounted) {
      setState(() {
        _lastOpenedLevel = level;
      });
    }
    
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GamePage(initialLevel: level),
      ),
    );
    // Refresh unlocked levels when returning from game
    _loadUnlockedLevels();
  }


  void _showModalDialog(BuildContext context, {required Widget child}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(16),
            child: ModalContainer(child: child),
          ),
        );
      },
    );
  }

  void _showHowToPlayModal(BuildContext context) {
    _showModalDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalHeader(
            title: 'How to Play',
            showCloseButton: true,
            onClose: () => Navigator.of(context).pop(),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InstructionItem(
                  icon: '🎯',
                  text: 'Arrange numbers in order, from 1 to the highest.',
                ),
                InstructionItem(
                  icon: '👆',
                  text: 'Tap or swipe tiles next to the empty space to move them.',
                ),
                InstructionItem(
                  icon: '⏱️',
                  text: 'Complete each level as quickly as possible!',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _LevelCard extends StatefulWidget {
  final int level;
  final int rows;
  final int columns;
  final String difficulty;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isLastOpened;
  final VoidCallback? onTap;
  final double cardPadding;
  final double iconSize;
  final double checkmarkSpacing;
  final double checkmarkSize;
  final double gridSpacing;
  final double gridPaddingH;
  final double gridPaddingV;
  final double gridFontSize;
  final double statusSpacing;
  final double statusFontSize;

  const _LevelCard({
    required this.level,
    required this.rows,
    required this.columns,
    required this.difficulty,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isLastOpened,
    this.onTap,
    required this.cardPadding,
    required this.iconSize,
    required this.checkmarkSpacing,
    required this.checkmarkSize,
    required this.gridSpacing,
    required this.gridPaddingH,
    required this.gridPaddingV,
    required this.gridFontSize,
    required this.statusSpacing,
    required this.statusFontSize,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> with SingleTickerProviderStateMixin {
  // Animations disabled

  @override
  Widget build(BuildContext context) {
    // Show actual grid dimensions (rows x columns)
    final gridSizeText = '${widget.rows}X${widget.columns}';
    
    return GestureDetector(
      onTap: widget.isUnlocked ? widget.onTap : null,
      child: Opacity(
        opacity: widget.isUnlocked ? 1.0 : 0.6,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.woodButtonFill,
            borderRadius: BorderRadius.circular(16),
            // Outer dark brown border for wooden inset effect
            border: Border.all(
              color: AppColors.woodButtonBorderDark,
              width: 2.5,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(2.5), // Creates the inset effect
            decoration: BoxDecoration(
              color: AppColors.woodButtonFill,
              borderRadius: BorderRadius.circular(13.5),
              // Inner lighter brown border
              border: Border.all(
                color: AppColors.woodButtonBorderLight,
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.isUnlocked ? widget.onTap : null,
                borderRadius: BorderRadius.circular(13.5),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  padding: EdgeInsets.all(widget.cardPadding * 1.5),
                  child: Stack(
                    children: [
                      // Main content - centered
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Level number - larger and more prominent
                            Text(
                              '${widget.level}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                fontSize: widget.iconSize * 0.65,
                                fontWeight: FontWeight.w900,
                                color: AppColors.woodButtonText,
                                letterSpacing: 1.5,
                              ),
                            ),
                            SizedBox(height: widget.cardPadding * 0.8),
                            // Grid size text - smaller
                            Text(
                              gridSizeText,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.orbitron(
                                fontSize: widget.iconSize * 0.35,
                                fontWeight: FontWeight.w700,
                                color: AppColors.woodButtonText.withValues(alpha: 0.8),
                                letterSpacing: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Lock icon for locked levels - positioned at top right
                      if (!widget.isUnlocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.lock,
                            color: AppColors.woodButtonText.withValues(alpha: 0.7),
                            size: widget.iconSize * 0.35,
                          ),
                        ),
                      // Dot indicator for last opened level - positioned at top right (only if unlocked, not based on completion)
                      if (widget.isLastOpened && widget.isUnlocked)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGold,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryGold.withValues(alpha: 0.6),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _getLevelGradient(int level) {
    // Use golden gradient to match game board tiles
    return [const Color(0xFFE9AF51), const Color(0xFFD4A046)];
  }

  List<Color> _getLockedGradient() {
    return [Colors.grey.shade700, Colors.grey.shade900];
  }

  List<Color> _getCardGradient() {
    if (widget.isCompleted) {
      // Vibrant emerald gradient for completed levels
      return [
        AppColors.completed,
        AppColors.completedDark,
      ];
    } else if (widget.isUnlocked) {
      // Bright cyan/blue gradient for unlocked levels
      return [
        AppColors.info,
        AppColors.infoDark,
      ];
    } else {
      return _getLockedGradient();
    }
  }

  Color _getCardBorderColor() {
    if (widget.isCompleted) {
      return Colors.white.withValues(alpha: 0.5);
    } else if (widget.isUnlocked) {
      return Colors.white.withValues(alpha: 0.4);
    } else {
      return Colors.grey.withValues(alpha: 0.3);
    }
  }

  List<BoxShadow> _getCardShadows() {
    if (widget.isCompleted) {
      return [
        // Strong glow shadow with emerald color
        BoxShadow(
          color: AppColors.completed.withValues(alpha: 0.6),
          blurRadius: 20,
          offset: const Offset(0, 6),
          spreadRadius: 4,
        ),
        BoxShadow(
          color: AppColors.completed.withValues(alpha: 0.4),
          blurRadius: 30,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        // Dark shadow for depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        // Strong glow shadow with cyan/blue color
        BoxShadow(
          color: AppColors.info.withValues(alpha: 0.5),
          blurRadius: 18,
          offset: const Offset(0, 6),
          spreadRadius: 3,
        ),
        BoxShadow(
          color: AppColors.info.withValues(alpha: 0.3),
          blurRadius: 25,
          offset: const Offset(0, 8),
          spreadRadius: 2,
        ),
        // Dark shadow for depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];
    } else {
      return [
        // Subtle locked state shadows
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
      ];
    }
  }

  Color _getLevelNumberColor() {
    if (widget.isCompleted) {
      return Colors.white;
    } else if (widget.isUnlocked) {
      return Colors.white;
    } else {
      return Colors.grey.shade400;
    }
  }

  List<Shadow> _getLevelNumberShadows() {
    if (widget.isCompleted) {
      return [
        Shadow(
          color: Colors.black.withValues(alpha: 0.9),
          offset: const Offset(2, 2),
          blurRadius: 6,
        ),
        Shadow(
          color: AppColors.completedAccent.withValues(alpha: 0.3),
          offset: const Offset(-1, -1),
          blurRadius: 4,
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        Shadow(
          color: Colors.black.withValues(alpha: 0.9),
          offset: const Offset(2, 2),
          blurRadius: 6,
        ),
        Shadow(
          color: AppColors.infoLight.withValues(alpha: 0.3),
          offset: const Offset(-1, -1),
          blurRadius: 4,
        ),
      ];
    } else {
      return [
        Shadow(
          color: Colors.black.withValues(alpha: 0.7),
          offset: const Offset(1, 1),
          blurRadius: 3,
        ),
      ];
    }
  }

  List<Color> _getIconContainerGradient() {
    if (widget.isCompleted) {
      return [
        Colors.white.withValues(alpha: 0.25),
        Colors.white.withValues(alpha: 0.1),
      ];
    } else if (widget.isUnlocked) {
      return [
        Colors.white.withValues(alpha: 0.25),
        Colors.white.withValues(alpha: 0.1),
      ];
    } else {
      return [
        Colors.grey.withValues(alpha: 0.2),
        Colors.grey.withValues(alpha: 0.1),
      ];
    }
  }

  Color _getIconContainerBorderColor() {
    if (widget.isCompleted) {
      return Colors.white.withValues(alpha: 0.4);
    } else if (widget.isUnlocked) {
      return Colors.white.withValues(alpha: 0.4);
    } else {
      return Colors.grey.withValues(alpha: 0.3);
    }
  }

  List<BoxShadow> _getIconContainerShadows() {
    if (widget.isCompleted) {
      return [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 4,
          offset: const Offset(0, -1),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];
    }
  }

  String _getStatusText() {
    if (widget.isCompleted) {
      return 'Completed';
    } else if (widget.isUnlocked) {
      return widget.difficulty;
    } else {
      return 'Locked';
    }
  }

  Color _getStatusTextColor() {
    if (widget.isCompleted) {
      return AppColors.completedAccent.withValues(alpha: 0.9);
    } else if (widget.isUnlocked) {
      return Colors.white.withValues(alpha: 0.9);
    } else {
      return Colors.grey.shade400;
    }
  }

  List<Shadow>? _getStatusTextShadows() {
    if (widget.isCompleted) {
      return [
        Shadow(
          color: Colors.black87,
          offset: const Offset(0.5, 0.5),
          blurRadius: 1,
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        Shadow(
          color: Colors.black87,
          offset: const Offset(0.5, 0.5),
          blurRadius: 1,
        ),
      ];
    } else {
      return null;
    }
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;
  
  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create small twinkling stars
    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i * 0.08 + animationValue * 0.1)) % size.width;
      final y = (size.height * (i * 0.12 + animationValue * 0.08)) % size.height;
      final radius = 1.0 + (i % 2) * 0.5;
      final alpha = (0.3 + (math.sin(animationValue * 4 * math.pi + i) + 1) * 0.2);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create medium glowing stars
    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i * 0.15 + animationValue * 0.05)) % size.width;
      final y = (size.height * (i * 0.18 + animationValue * 0.06)) % size.height;
      final radius = 2.0 + (i % 3) * 1.0;
      final alpha = (0.2 + (math.cos(animationValue * 3 * math.pi + i) + 1) * 0.15);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create large glowing orbs
    for (int i = 0; i < 8; i++) {
      final x = (size.width * (i * 0.25 + animationValue * 0.03)) % size.width;
      final y = (size.height * (i * 0.3 + animationValue * 0.04)) % size.height;
      final radius = 4.0 + (i % 2) * 2.0;
      final alpha = (0.1 + (math.sin(animationValue * 2 * math.pi + i) + 1) * 0.08);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create distant nebula-like effects
    for (int i = 0; i < 3; i++) {
      final x = (size.width * (i * 0.4 + animationValue * 0.02)) % size.width;
      final y = (size.height * (i * 0.5 + animationValue * 0.03)) % size.height;
      final radius = 15.0 + i * 5.0;
      final alpha = (0.03 + (math.cos(animationValue * 1.5 * math.pi + i) + 1) * 0.02);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
