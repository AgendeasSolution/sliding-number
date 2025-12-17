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
  
  List<int> _unlockedLevels = [1]; // Default to only level 1 unlocked
  List<int> _completedLevels = []; // Track completed levels

  @override
  void initState() {
    super.initState();
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutBack,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleAnimationController,
      curve: Curves.linear,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsAnimationController.forward();
    });
    _particleAnimationController.repeat();
    
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
    _cardsAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUnlockedLevels() async {
    try {
      final unlockedLevels = await LevelProgressionService.getUnlockedLevels()
          .timeout(const Duration(seconds: 3), onTimeout: () => [1]);
      final completedLevels = await LevelProgressionService.getCompletedLevels()
          .timeout(const Duration(seconds: 3), onTimeout: () => <int>[]);
      
      if (mounted) {
        setState(() {
          _unlockedLevels = unlockedLevels;
          _completedLevels = completedLevels;
        });
      }
    } catch (e) {
      // Silent error - use defaults to prevent crash
      if (mounted) {
        setState(() {
          _unlockedLevels = [1];
          _completedLevels = [];
        });
      }
    }
  }

  Future<void> _checkForUpdates() async {
    if (!mounted) return;
    
    try {
      // Use timeout to prevent ANR - never wait more than 8 seconds
      final isUpdateAvailable = await AppUpdateService.instance.isUpdateAvailable()
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => false,
          );
      
      if (isUpdateAvailable && mounted) {
        // Show update dialog only if still mounted
        if (mounted && context.mounted) {
          UpdateDialog.show(context);
        }
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
        decoration: AppTheme.backgroundGradient,
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
                            smallMobile: 8.0,
                            mobile: 12.0,
                            largeMobile: 16.0,
                            tablet: 20.0,
                            desktop: 24.0,
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
                            child: Column(
                              children: [
                                Expanded(child: _buildLevelGrid(context)),
                                SizedBox(height: _getResponsiveValue(context,
                                  smallMobile: 12.0,
                                  mobile: 16.0,
                                  largeMobile: 20.0,
                                  tablet: 24.0,
                                  desktop: 28.0,
                                )),
                                _buildActionButtons(context),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Ad banner at the bottom - independent from other elements
              const AdBanner(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    // Responsive font sizes for all screen sizes
    final fontSize = _getResponsiveValue(context,
      smallMobile: 32.0,
      mobile: 36.0,
      largeMobile: 42.0,
      tablet: 48.0,
      desktop: 56.0,
    );
    
    final letterSpacing = _getResponsiveValue(context,
      smallMobile: 0.5,
      mobile: 0.8,
      largeMobile: 1.0,
      tablet: 1.2,
      desktop: 1.5,
    );
    
    final lineWidth = _getResponsiveValue(context,
      smallMobile: 60.0,
      mobile: 70.0,
      largeMobile: 80.0,
      tablet: 90.0,
      desktop: 100.0,
    );
    
    final lineHeight = _getResponsiveValue(context,
      smallMobile: 2.0,
      mobile: 2.5,
      largeMobile: 3.0,
      tablet: 3.5,
      desktop: 4.0,
    );
    
    final topMargin = _getResponsiveValue(context,
      smallMobile: 8.0,
      mobile: 12.0,
      largeMobile: 16.0,
      tablet: 20.0,
      desktop: 24.0,
    );
    
    return Container(
      margin: EdgeInsets.only(top: topMargin),
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE9AF51), Color(0xFFD4A046)],
            ).createShader(bounds),
            child: Text(
              'Sliding Number',
              style: GoogleFonts.inter(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: letterSpacing,
                shadows: [
                  Shadow(
                    color: const Color(0xFFE9AF51).withValues(alpha: 0.5),
                    offset: const Offset(0, 0),
                    blurRadius: _getResponsiveValue(context,
                      smallMobile: 15.0,
                      mobile: 20.0,
                      largeMobile: 25.0,
                      tablet: 30.0,
                      desktop: 35.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: _getResponsiveValue(context,
            smallMobile: 4.0,
            mobile: 6.0,
            largeMobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
          )),
          Container(
            height: lineHeight,
            width: lineWidth,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9AF51), Color(0xFFD4A046)],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildLevelGrid(BuildContext context) {
    // Responsive grid configuration
    final crossAxisCount = _getResponsiveValue(context,
      smallMobile: 3.0,
      mobile: 3.0,
      largeMobile: 4.0,
      tablet: 5.0,
      desktop: 6.0,
    ).toInt();
    
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
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: AppConstants.maxLevel,
      itemBuilder: (context, index) {
        final level = index + 1;
        final gridDimensions = GameUtils.calculateGridSize(level);
        return _buildLevelCard(context, level, gridDimensions.rows, gridDimensions.columns, index);
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final buttonWidth = _getResponsiveValue(context,
      smallMobile: 140.0,
      mobile: 150.0,
      largeMobile: 160.0,
      tablet: 170.0,
      desktop: 180.0,
    );
    
    final buttonSpacing = _getResponsiveValue(context,
      smallMobile: 12.0,
      mobile: 16.0,
      largeMobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );
    
    final gamesButtonWidth = _getResponsiveValue(context,
      smallMobile: 130.0,
      mobile: 140.0,
      largeMobile: 150.0,
      tablet: 160.0,
      desktop: 170.0,
    );
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildAnimatedButton(
              context,
              label: '',
              onPressed: () {
                AudioService.instance.playClickSound();
                _showHowToPlayModal(context);
              },
              gradient: const LinearGradient(
                colors: [AppColors.neutral, AppColors.neutralDark],
              ),
              icon: Icons.help_outline,
            ),
            SizedBox(width: _getResponsiveValue(context,
              smallMobile: 6.0,
              mobile: 8.0,
              largeMobile: 10.0,
              tablet: 12.0,
              desktop: 14.0,
            )),
            _buildSoundButton(context),
          ],
        ),
        SizedBox(height: _getResponsiveValue(context,
          smallMobile: 12.0,
          mobile: 16.0,
          largeMobile: 20.0,
          tablet: 24.0,
          desktop: 28.0,
        )),
        Center(
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFE9AF51), Color(0xFFD4A046)],
            ).createShader(bounds),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
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
                  style: GoogleFonts.inter(
                    fontSize: _getResponsiveValue(context,
                      smallMobile: 12.0,
                      mobile: 14.0,
                      largeMobile: 16.0,
                      tablet: 18.0,
                      desktop: 20.0,
                    ),
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.8,
                    shadows: [
                      Shadow(
                        color: const Color(0xFFE9AF51).withValues(alpha: 0.5),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                      ),
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
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
          smallMobile: 8.0,
          mobile: 10.0,
          largeMobile: 12.0,
          tablet: 14.0,
          desktop: 16.0,
        )),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: gamesButtonWidth,
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
            SizedBox(
              width: gamesButtonWidth,
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

  Widget _buildSoundButton(BuildContext context) {
    return StreamBuilder<bool>(
      stream: Stream.periodic(const Duration(milliseconds: 100))
          .map((_) => AudioService.instance.isSoundEnabled),
      builder: (context, snapshot) {
        final isSoundEnabled = snapshot.data ?? AudioService.instance.isSoundEnabled;
        return Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.neutral, AppColors.neutralDark],
                  ),
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
                      color: AppColors.neutral.withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: AppColors.neutral.withValues(alpha: 0.2),
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
                    onTap: () {
                      AudioService.instance.playClickSound();
                      AudioService.instance.toggleSound();
                    },
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
                      child: Icon(
                        isSoundEnabled
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        size: _getResponsiveValue(context,
                          smallMobile: 16.0,
                          mobile: 18.0,
                          largeMobile: 20.0,
                          tablet: 22.0,
                          desktop: 24.0,
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              );
      },
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
                smallMobile: 10.0,
                mobile: 12.0,
                largeMobile: 14.0,
                tablet: 16.0,
                desktop: 18.0,
              )),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient.colors.first.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPressed,
                borderRadius: BorderRadius.circular(_getResponsiveValue(context,
                  smallMobile: 10.0,
                  mobile: 12.0,
                  largeMobile: 14.0,
                  tablet: 16.0,
                  desktop: 18.0,
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
                          smallMobile: 20.0,
                          mobile: 22.0,
                          largeMobile: 24.0,
                          tablet: 26.0,
                          desktop: 28.0,
                        ),
                        color: Colors.white,
                      ),
                      SizedBox(width: _getResponsiveValue(context,
                        smallMobile: 4.0,
                        mobile: 6.0,
                        largeMobile: 8.0,
                        tablet: 10.0,
                        desktop: 12.0,
                      )),
                      Flexible(
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: _getResponsiveValue(context,
                              smallMobile: 13.0,
                              mobile: 15.0,
                              largeMobile: 17.0,
                              tablet: 19.0,
                              desktop: 21.0,
                            ),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                offset: const Offset(0, 1),
                                blurRadius: 2,
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
          const ModalHeader(title: 'How to Play'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          ModalFooter(
            child: GameButton(
              label: '✕ Close',
              onPressed: () => Navigator.of(context).pop(),
              gradient: const LinearGradient(
                colors: [AppColors.neutral, AppColors.neutralDark],
              ),
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
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _hoverAnimation = CurvedAnimation(
      parent: _hoverController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isUnlocked ? widget.onTap : null,
      onTapDown: widget.isUnlocked ? (_) {
        setState(() => _isHovered = true);
        _hoverController.forward();
      } : null,
      onTapUp: widget.isUnlocked ? (_) {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      } : null,
      onTapCancel: widget.isUnlocked ? () {
        setState(() => _isHovered = false);
        _hoverController.reverse();
      } : null,
      child: AnimatedBuilder(
        animation: _hoverAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isUnlocked ? 1.0 + (_hoverAnimation.value * 0.05) : 1.0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getCardGradient(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _getCardBorderColor(),
                  width: 1.5 + (_hoverAnimation.value * 0.5),
                ),
                boxShadow: _getCardShadows(),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.isUnlocked ? widget.onTap : null,
                  borderRadius: BorderRadius.circular(24),
                    child: Container(
                    padding: EdgeInsets.all(widget.cardPadding),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Level number with glassmorphism effect, lock icon, or checkmark
                        Container(
                          width: widget.iconSize,
                          height: widget.iconSize,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: _getIconContainerGradient(),
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: _getIconContainerBorderColor(),
                              width: 1.5 + (_hoverAnimation.value * 0.5),
                            ),
                            boxShadow: _getIconContainerShadows(),
                          ),
                          child: Center(
                            child: _getIconWidget(),
                          ),
                        ),
                        // Checkmark icon for completed levels (outside the circle)
                        if (widget.isCompleted) ...[
                          SizedBox(height: widget.checkmarkSpacing),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.completedAccent,
                            size: widget.checkmarkSize + (_hoverAnimation.value * 2),
                          ),
                        ],
                        // Only show grid size and difficulty for non-completed levels
                        if (!widget.isCompleted) ...[
                          SizedBox(height: widget.gridSpacing + 4.0),
                          // Grid size indicator with enhanced styling
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.gridPaddingH,
                              vertical: widget.gridPaddingV,
                            ),
                            decoration: BoxDecoration(
                              color: widget.isUnlocked 
                                ? Colors.white.withValues(alpha: 0.15 + (_hoverAnimation.value * 0.05))
                                : Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.isUnlocked 
                                  ? Colors.white.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.1))
                                  : Colors.grey.withValues(alpha: 0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              '${widget.rows}×${widget.columns}',
                              style: TextStyle(
                                fontSize: widget.gridFontSize + (_hoverAnimation.value * 1),
                                fontWeight: FontWeight.bold,
                                color: widget.isUnlocked ? Colors.white : Colors.grey.shade400,
                                letterSpacing: 0.5,
                                shadows: widget.isUnlocked ? [
                                  Shadow(
                                    color: Colors.black87,
                                    offset: const Offset(1, 1),
                                    blurRadius: 2 + (_hoverAnimation.value * 1),
                                  ),
                                ] : null,
                              ),
                            ),
                          ),
                          SizedBox(height: widget.statusSpacing + 6.0),
                          // Difficulty indicator or locked text
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: widget.statusFontSize + (_hoverAnimation.value * 0.5),
                              fontWeight: FontWeight.w600,
                              color: _getStatusTextColor(),
                              letterSpacing: 0.3,
                              shadows: _getStatusTextShadows(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
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
      // Use same golden gradient as game tiles for consistency
      return [const Color(0xFFE9AF51), const Color(0xFFD4A046)];
    } else if (widget.isUnlocked) {
      return _getLevelGradient(widget.level);
    } else {
      return _getLockedGradient();
    }
  }

  Color _getCardBorderColor() {
    if (widget.isCompleted) {
      return AppColors.completedAccent.withValues(alpha: 0.8 + (_hoverAnimation.value * 0.2));
    } else if (widget.isUnlocked) {
      return Colors.white.withValues(alpha: 0.3 + (_hoverAnimation.value * 0.2));
    } else {
      return Colors.grey.withValues(alpha: 0.5);
    }
  }

  List<BoxShadow> _getCardShadows() {
    if (widget.isCompleted) {
      return [
        // Main glow shadow with reduced intensity
        BoxShadow(
          color: AppColors.completed.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.05)),
          blurRadius: 8 + (_hoverAnimation.value * 2),
          offset: const Offset(0, 3),
          spreadRadius: 1 + (_hoverAnimation.value * 0.5),
        ),
        // Gold accent glow with reduced intensity
        BoxShadow(
          color: AppColors.completedAccent.withValues(alpha: 0.15 + (_hoverAnimation.value * 0.03)),
          blurRadius: 10 + (_hoverAnimation.value * 3),
          offset: const Offset(0, 4),
          spreadRadius: 1.5 + (_hoverAnimation.value * 0.5),
        ),
        // Dark shadow for depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15 + (_hoverAnimation.value * 0.03)),
          blurRadius: 6 + (_hoverAnimation.value * 1.5),
          offset: const Offset(0, 2),
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        // Main glow shadow with hover enhancement
        BoxShadow(
          color: _getLevelGradient(widget.level).first.withValues(alpha: 0.3 + (_hoverAnimation.value * 0.1)),
          blurRadius: 12 + (_hoverAnimation.value * 4),
          offset: const Offset(0, 5),
          spreadRadius: 2 + (_hoverAnimation.value * 1),
        ),
        // Dark shadow for depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.05)),
          blurRadius: 8 + (_hoverAnimation.value * 2),
          offset: const Offset(0, 3),
        ),
      ];
    } else {
      return [
        // Locked state shadows
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 1,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.15),
          blurRadius: 5,
          offset: const Offset(0, 1),
        ),
      ];
    }
  }

  Widget _getIconWidget() {
    if (widget.isCompleted) {
      return Text(
        '${widget.level}',
        style: TextStyle(
          fontSize: 22 + (_hoverAnimation.value * 2),
          fontWeight: FontWeight.w900,
          color: AppColors.completedAccent,
          shadows: [
            Shadow(
              color: Colors.black87,
              offset: const Offset(1, 1),
              blurRadius: 4 + (_hoverAnimation.value * 2),
            ),
            Shadow(
              color: Colors.white24,
              offset: const Offset(-1, -1),
              blurRadius: 2 + (_hoverAnimation.value * 1),
            ),
          ],
        ),
      );
    } else if (widget.isUnlocked) {
      return Text(
        '${widget.level}',
        style: TextStyle(
          fontSize: 22 + (_hoverAnimation.value * 2),
          fontWeight: FontWeight.w900,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black87,
              offset: const Offset(1, 1),
              blurRadius: 4 + (_hoverAnimation.value * 2),
            ),
            Shadow(
              color: Colors.white24,
              offset: const Offset(-1, -1),
              blurRadius: 2 + (_hoverAnimation.value * 1),
            ),
          ],
        ),
      );
    } else {
      return Icon(
        Icons.lock,
        color: Colors.grey.shade400,
        size: 24,
      );
    }
  }

  List<Color> _getIconContainerGradient() {
    if (widget.isCompleted) {
      return [
        AppColors.completedAccent.withValues(alpha: 0.4 + (_hoverAnimation.value * 0.1)),
        AppColors.completedAccent.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.05)),
      ];
    } else if (widget.isUnlocked) {
      return [
        Colors.white.withValues(alpha: 0.25 + (_hoverAnimation.value * 0.1)),
        Colors.white.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
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
      return AppColors.completedAccent.withValues(alpha: 0.8 + (_hoverAnimation.value * 0.2));
    } else if (widget.isUnlocked) {
      return Colors.white.withValues(alpha: 0.4 + (_hoverAnimation.value * 0.2));
    } else {
      return Colors.grey.withValues(alpha: 0.3);
    }
  }

  List<BoxShadow> _getIconContainerShadows() {
    if (widget.isCompleted) {
      return [
        BoxShadow(
          color: AppColors.completedAccent.withValues(alpha: 0.15 + (_hoverAnimation.value * 0.05)),
          blurRadius: 6 + (_hoverAnimation.value * 2),
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
          blurRadius: 4 + (_hoverAnimation.value * 2),
          offset: const Offset(0, -1),
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
          blurRadius: 4 + (_hoverAnimation.value * 2),
          offset: const Offset(0, 1),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.05)),
          blurRadius: 4 + (_hoverAnimation.value * 2),
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
      return AppColors.completedAccent.withValues(alpha: 0.9 + (_hoverAnimation.value * 0.1));
    } else if (widget.isUnlocked) {
      return Colors.white.withValues(alpha: 0.9 + (_hoverAnimation.value * 0.1));
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
          blurRadius: 1 + (_hoverAnimation.value * 0.5),
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        Shadow(
          color: Colors.black87,
          offset: const Offset(0.5, 0.5),
          blurRadius: 1 + (_hoverAnimation.value * 0.5),
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
