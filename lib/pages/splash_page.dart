import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../theme/app_theme.dart';
import 'home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _logoAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Ensure system UI is properly configured for splash
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    
    // Logo animation - starts immediately
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Text animation - starts after logo
    _textAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    // Particle animation - continuous
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _logoAnimation = CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    );
    
    _textAnimation = CurvedAnimation(
      parent: _textAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _particleAnimation = CurvedAnimation(
      parent: _particleAnimationController,
      curve: Curves.linear,
    );

    // Start animations
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 800), () {
      _textAnimationController.forward();
    });
    _particleAnimationController.repeat();
    
    // Navigate to home page after splash duration
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallMobile = screenSize.width < 360 || screenSize.height < 600;
    final isMobile = screenSize.width >= 360 && screenSize.width < 768;
    final isLargeMobile = screenSize.width >= 600 && screenSize.width < 768;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;
    
    // Responsive font sizes - smaller than home page
    final fontSize = isSmallMobile ? 24.0 : isMobile ? 28.0 : isLargeMobile ? 32.0 : isTablet ? 36.0 : 40.0;
    
    final letterSpacing = isSmallMobile ? 1.5 : isMobile ? 2.0 : isLargeMobile ? 2.5 : isTablet ? 3.0 : 3.5;
    
    final lineWidth = isSmallMobile ? 70.0 : isMobile ? 80.0 : isLargeMobile ? 90.0 : isTablet ? 100.0 : 110.0;
    
    final lineHeight = isSmallMobile ? 2.0 : isMobile ? 2.5 : isLargeMobile ? 3.0 : isTablet ? 3.5 : 4.0;
    
    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: Stack(
          children: [
            // Animated background particles
            _buildAnimatedBackground(),
            // Main content - Logo centered
            Center(
              child: AnimatedBuilder(
                animation: _logoAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoAnimation.value,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main title text - matching home page exactly, always single line
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: ShaderMask(
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
                              maxLines: 1,
                              overflow: TextOverflow.visible,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallMobile ? 10.0 : isMobile ? 12.0 : isLargeMobile ? 14.0 : isTablet ? 16.0 : 18.0),
                        // Line below logo - matching home page
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
                },
              ),
            ),
            // Bottom text with animation
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, (1 - _textAnimation.value) * 30),
                    child: Column(
                      children: [
                        Text(
                          'developed by',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'FGTP Labs',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(0, 2),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: SplashParticlePainter(_particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class SplashParticlePainter extends CustomPainter {
  final double animationValue;
  
  SplashParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create small twinkling stars
    for (int i = 0; i < 40; i++) {
      final x = (size.width * (i * 0.1 + animationValue * 0.08)) % size.width;
      final y = (size.height * (i * 0.15 + animationValue * 0.06)) % size.height;
      final radius = 1.0 + (i % 2) * 0.5;
      final alpha = (0.2 + (math.sin(animationValue * 3 * math.pi + i) + 1) * 0.15);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create medium glowing stars
    for (int i = 0; i < 12; i++) {
      final x = (size.width * (i * 0.2 + animationValue * 0.04)) % size.width;
      final y = (size.height * (i * 0.25 + animationValue * 0.05)) % size.height;
      final radius = 2.0 + (i % 3) * 1.0;
      final alpha = (0.15 + (math.cos(animationValue * 2.5 * math.pi + i) + 1) * 0.1);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Create large glowing orbs
    for (int i = 0; i < 6; i++) {
      final x = (size.width * (i * 0.3 + animationValue * 0.02)) % size.width;
      final y = (size.height * (i * 0.35 + animationValue * 0.03)) % size.height;
      final radius = 3.0 + (i % 2) * 1.5;
      final alpha = (0.08 + (math.sin(animationValue * 1.8 * math.pi + i) + 1) * 0.05);
      
      paint.color = AppColors.primaryGold.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
