import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/games_data.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';
import '../services/audio_service.dart';
import '../widgets/ad_banner.dart';

class OtherGamesPage extends StatefulWidget {
  const OtherGamesPage({super.key});

  @override
  State<OtherGamesPage> createState() => _OtherGamesPageState();
}

class _OtherGamesPageState extends State<OtherGamesPage>
    with TickerProviderStateMixin {
  late AnimationController _cardsAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _cardsAnimation;
  late Animation<double> _particleAnimation;

  final List<GameModel> _games = GamesData.getOtherGames();

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
  }

  @override
  void dispose() {
    _cardsAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  // Responsive breakpoints
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

  bool _isIOS() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.iOS;
  }

  Future<void> _launchGameUrl(GameModel game) async {
    AudioService.instance.playClickSound();
    
    final String url = _isIOS() ? game.appstoreUrl : game.playstoreUrl;
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open store link'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening store: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Container(
            decoration: AppTheme.backgroundGradient,
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        _buildAnimatedBackground(),
                        Column(
                          children: [
                            _buildHeader(context),
                            Expanded(
                              child: _buildGamesGrid(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: const AdBanner(),
            ),
          ),
        ],
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
    final fontSize = _getResponsiveValue(context,
      smallMobile: 18.0,
      mobile: 20.0,
      largeMobile: 22.0,
      tablet: 24.0,
      desktop: 26.0,
    );

    return Padding(
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 0.0,
        bottom: 12.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBackButton(),
          Expanded(
            child: Center(
              child: Text(
                'FGTP Labs',
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.logoGradientStart.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            AudioService.instance.playClickSound();
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.textWhite,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context) {
    final crossAxisCount = _getResponsiveValue(context,
      smallMobile: 2.0,
      mobile: 2.0,
      largeMobile: 2.0,
      tablet: 3.0,
      desktop: 4.0,
    ).toInt();

    final crossAxisSpacing = _getResponsiveValue(context,
      smallMobile: 12.0,
      mobile: 16.0,
      largeMobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    final mainAxisSpacing = _getResponsiveValue(context,
      smallMobile: 12.0,
      mobile: 16.0,
      largeMobile: 20.0,
      tablet: 24.0,
      desktop: 28.0,
    );

    final childAspectRatio = _getResponsiveValue(context,
      smallMobile: 0.65,
      mobile: 0.65,
      largeMobile: 0.65,
      tablet: 0.7,
      desktop: 0.75,
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _getResponsiveValue(context,
          smallMobile: 12.0,
          mobile: 16.0,
          largeMobile: 20.0,
          tablet: 24.0,
          desktop: 32.0,
        ),
      ),
      child: GridView.builder(
        padding: EdgeInsets.only(
          top: _getResponsiveValue(context,
            smallMobile: 4.0,
            mobile: 6.0,
            largeMobile: 8.0,
            tablet: 10.0,
            desktop: 12.0,
          ),
          bottom: _getResponsiveValue(context,
            smallMobile: 100.0,
            mobile: 100.0,
            largeMobile: 100.0,
            tablet: 100.0,
            desktop: 100.0,
          ),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
        ),
        itemCount: _games.length,
        itemBuilder: (context, index) {
          final game = _games[index];
          return _GameCard(
            game: game,
            index: index,
            onTap: () => _launchGameUrl(game),
            responsiveValue: _getResponsiveValue,
          );
        },
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  final GameModel game;
  final int index;
  final VoidCallback onTap;
  final double Function(BuildContext, {
    required double smallMobile,
    required double mobile,
    required double largeMobile,
    required double tablet,
    required double desktop,
  }) responsiveValue;

  const _GameCard({
    required this.game,
    required this.index,
    required this.onTap,
    required this.responsiveValue,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

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
    final cardPadding = widget.responsiveValue(context,
      smallMobile: 8.0,
      mobile: 10.0,
      largeMobile: 12.0,
      tablet: 14.0,
      desktop: 16.0,
    );

    final imageRadius = widget.responsiveValue(context,
      smallMobile: 16.0,
      mobile: 18.0,
      largeMobile: 20.0,
      tablet: 22.0,
      desktop: 24.0,
    );

    final titleFontSize = widget.responsiveValue(context,
      smallMobile: 14.0,
      mobile: 16.0,
      largeMobile: 18.0,
      tablet: 20.0,
      desktop: 22.0,
    );

    final buttonFontSize = widget.responsiveValue(context,
      smallMobile: 10.0,
      mobile: 12.0,
      largeMobile: 14.0,
      tablet: 16.0,
      desktop: 18.0,
    );

    return GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => _hoverController.forward(),
            onTapUp: (_) => _hoverController.reverse(),
            onTapCancel: () => _hoverController.reverse(),
            child: AnimatedBuilder(
              animation: _hoverAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_hoverAnimation.value * 0.05),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getCardGradient(),
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(imageRadius),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3 + (_hoverAnimation.value * 0.2)),
                        width: 1.5 + (_hoverAnimation.value * 0.5),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: widget.onTap,
                        borderRadius: BorderRadius.circular(imageRadius),
                        child: Padding(
                          padding: EdgeInsets.all(cardPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              AspectRatio(
                                aspectRatio: 1.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(widget.responsiveValue(context,
                                    smallMobile: 8.0,
                                    mobile: 10.0,
                                    largeMobile: 12.0,
                                    tablet: 14.0,
                                    desktop: 16.0,
                                  )),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.2),
                                    ),
                                    child: Image.network(
                                      widget.game.image,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null) return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                    loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: AppColors.primaryGold,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: Colors.grey.shade800,
                                          child: Icon(
                                            Icons.gamepad,
                                            color: AppColors.primaryGold,
                                            size: widget.responsiveValue(context,
                                              smallMobile: 40.0,
                                              mobile: 48.0,
                                              largeMobile: 56.0,
                                              tablet: 64.0,
                                              desktop: 72.0,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: widget.responsiveValue(context,
                                smallMobile: 8.0,
                                mobile: 10.0,
                                largeMobile: 12.0,
                                tablet: 14.0,
                                desktop: 16.0,
                              )),
                              Expanded(
                                flex: 2,
                                child: Center(
                                  child: Text(
                                    widget.game.name,
                                    style: GoogleFonts.inter(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      shadows: const [
                                        Shadow(
                                          color: Colors.black87,
                                          offset: Offset(1, 1),
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              SizedBox(height: widget.responsiveValue(context,
                                smallMobile: 6.0,
                                mobile: 8.0,
                                largeMobile: 10.0,
                                tablet: 12.0,
                                desktop: 14.0,
                              )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primaryGold, AppColors.primaryGoldDark],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryGold.withValues(alpha: 0.5),
                                        blurRadius: 15,
                                        offset: const Offset(0, 6),
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: widget.onTap,
                                      borderRadius: BorderRadius.circular(12),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.play_arrow_rounded,
                                              color: Colors.white,
                                              size: widget.responsiveValue(context,
                                                smallMobile: 16.0,
                                                mobile: 18.0,
                                                largeMobile: 20.0,
                                                tablet: 22.0,
                                                desktop: 24.0,
                                              ),
                                            ),
                                            SizedBox(width: widget.responsiveValue(context,
                                              smallMobile: 4.0,
                                              mobile: 6.0,
                                              largeMobile: 8.0,
                                              tablet: 10.0,
                                              desktop: 12.0,
                                            )),
                                            Text(
                                              'Play Now',
                                              style: GoogleFonts.inter(
                                                fontSize: buttonFontSize,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: const [
                                                  Shadow(
                                                    color: Colors.black26,
                                                    offset: Offset(1, 1),
                                                    blurRadius: 2,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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

  List<Color> _getCardGradient() {
    // Same color for all cards
    return [AppColors.backgroundLight, AppColors.backgroundMedium];
  }
}

class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 50; i++) {
      final x = (size.width * (i * 0.08 + animationValue * 0.1)) % size.width;
      final y = (size.height * (i * 0.12 + animationValue * 0.08)) % size.height;
      final radius = 1.0 + (i % 2) * 0.5;
      final alpha = (0.3 + (math.sin(animationValue * 4 * math.pi + i) + 1) * 0.2);

      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    for (int i = 0; i < 15; i++) {
      final x = (size.width * (i * 0.15 + animationValue * 0.05)) % size.width;
      final y = (size.height * (i * 0.18 + animationValue * 0.06)) % size.height;
      final radius = 2.0 + (i % 3) * 1.0;
      final alpha = (0.2 + (math.cos(animationValue * 3 * math.pi + i) + 1) * 0.15);

      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    for (int i = 0; i < 8; i++) {
      final x = (size.width * (i * 0.25 + animationValue * 0.03)) % size.width;
      final y = (size.height * (i * 0.3 + animationValue * 0.04)) % size.height;
      final radius = 4.0 + (i % 2) * 2.0;
      final alpha = (0.1 + (math.sin(animationValue * 2 * math.pi + i) + 1) * 0.08);

      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

