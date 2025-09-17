import 'dart:ui';
import 'dart:math' as math;
import 'dart:math' show Point;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';
import '../widgets/game_button.dart';
import '../widgets/modal_container.dart';
import '../widgets/modal_header.dart';
import '../widgets/modal_footer.dart';
import '../widgets/instruction_item.dart';
import '../widgets/goal_board.dart';
import '../widgets/ad_banner.dart';
import '../services/game_service.dart';
import '../services/level_progression_service.dart';
import '../models/game_state.dart';
import 'game_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late AnimationController _titleAnimationController;
  late AnimationController _cardsAnimationController;
  late AnimationController _particleAnimationController;
  late Animation<double> _titleAnimation;
  late Animation<double> _cardsAnimation;
  late Animation<double> _particleAnimation;
  
  List<int> _unlockedLevels = [1]; // Default to only level 1 unlocked
  List<int> _completedLevels = []; // Track completed levels

  @override
  void initState() {
    super.initState();
    _titleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _particleAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _titleAnimation = CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.elasticOut,
    );
    _cardsAnimation = CurvedAnimation(
      parent: _cardsAnimationController,
      curve: Curves.easeOutBack,
    );
    _particleAnimation = CurvedAnimation(
      parent: _particleAnimationController,
      curve: Curves.linear,
    );

    _titleAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _cardsAnimationController.forward();
    });
    _particleAnimationController.repeat();
    
    // Load unlocked levels
    _loadUnlockedLevels();
  }

  @override
  void dispose() {
    _titleAnimationController.dispose();
    _cardsAnimationController.dispose();
    _particleAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadUnlockedLevels() async {
    final unlockedLevels = await LevelProgressionService.getUnlockedLevels();
    final completedLevels = await LevelProgressionService.getCompletedLevels();
    if (mounted) {
      setState(() {
        _unlockedLevels = unlockedLevels;
        _completedLevels = completedLevels;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;
    
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
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: screenSize.height - MediaQuery.of(context).padding.top - 70, // Account for ad banner space
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: isSmallScreen ? 16.0 : 24.0,
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: isSmallScreen ? 10 : 20),
                              _buildHeader(context),
                              SizedBox(height: isSmallScreen ? 15 : 25),
                              _buildLevelGrid(context),
                              SizedBox(height: isSmallScreen ? 20 : 30),
                              _buildActionButtons(context),
                              SizedBox(height: isSmallScreen ? 10 : 15),
                            ],
                          ),
                        ),
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
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 768 && screenSize.width < 1024;
    final isDesktop = screenSize.width >= 1024;
    
    // Responsive font sizes - Made larger
    double fontSize;
    if (isDesktop) {
      fontSize = 72; // 4.5rem (increased from 3.5rem)
    } else if (isTablet) {
      fontSize = 56; // 3.5rem (increased from 2.5rem)
    } else {
      fontSize = 44; // 2.75rem (increased from 2rem)
    }
    
    return AnimatedBuilder(
      animation: _titleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _titleAnimation.value,
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
                ).createShader(bounds),
                child: Text(
                  'Sliding Number',
                  style: GoogleFonts.inter(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w800, // 800 (extra bold)
                    color: Colors.white, // This will be replaced by the gradient
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: AppColors.logoGradientStart.withValues(alpha: 0.5),
                        offset: const Offset(0, 0),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 3,
                width: 80,
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
    );
  }



  Widget _buildLevelGrid(BuildContext context) {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: AppConstants.maxLevel,
          itemBuilder: (context, index) {
            final level = index + 1;
            final gridSize = _getGridSize(level);
            return Transform.scale(
              scale: _cardsAnimation.value,
              child: Transform.translate(
                offset: Offset(0, (1 - _cardsAnimation.value) * 50),
                child: _buildLevelCard(context, level, gridSize, index),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child: _buildAnimatedButton(
          context,
          label: 'How to Play',
          onPressed: () => _showHowToPlayModal(context),
          gradient: const LinearGradient(
            colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
          ),
          icon: '🎮',
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(
    BuildContext context, {
    required String label,
    required VoidCallback onPressed,
    Color? color,
    Gradient? gradient,
    required String icon,
  }) {
    return AnimatedBuilder(
      animation: _cardsAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _cardsAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: color,
              gradient: gradient,
              borderRadius: BorderRadius.circular(20),
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
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 22),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
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
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLevelCard(BuildContext context, int level, int gridSize, int index) {
    final difficulty = _getDifficultyText(gridSize);
    final difficultyColor = _getDifficultyColor(gridSize);
    final isUnlocked = _unlockedLevels.contains(level);
    final isCompleted = _completedLevels.contains(level);
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 800 + (index * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: Transform.rotate(
            angle: (1 - value) * 0.05,
            child: _LevelCard(
              level: level,
              gridSize: gridSize,
              difficulty: difficulty,
              isUnlocked: isUnlocked,
              isCompleted: isCompleted,
              onTap: isUnlocked ? () => _startLevel(context, level) : null,
            ),
          ),
        );
      },
    );
  }

  List<Color> _getLevelGradient(int level) {
    if (level <= 3) {
      return [AppColors.success, AppColors.successDark];
    } else if (level <= 6) {
      return [AppColors.warning, AppColors.warningDark];
    } else if (level <= 9) {
      return [AppColors.info, AppColors.infoDark];
    } else {
      return [AppColors.error, AppColors.errorDark];
    }
  }

  Color _getDifficultyColor(int gridSize) {
    if (gridSize <= 4) return AppColors.success;
    if (gridSize <= 6) return AppColors.warning;
    if (gridSize <= 8) return AppColors.info;
    return AppColors.error;
  }

  int _getGridSize(int level) {
    return level + 2; // Level 1 = 3x3, Level 2 = 4x4, etc.
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

  void _showGoalModal(BuildContext context) async {
    // Create a sample game state for level 1 to show the goal
    final sampleGameState = await GameService.initializeGame(1);
    
    _showModalDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalHeader(
            title: '🎯 Goal',
            color: AppColors.success,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text(
                  'Arrange the numbers in this order:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                GoalBoard(gameState: sampleGameState),
                const SizedBox(height: 16),
                const Text(
                  'Each level increases the grid size, making it more challenging!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
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

  void _showGameOverModal(BuildContext context) {
    _showModalDialog(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ModalHeader(
            title: '🎉 Level 1 Complete!',
            color: AppColors.success,
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Game stats without background
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildGameStatItem('⏱️', 'TIME', '45s'),
                    Container(
                      height: 40,
                      width: 1,
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                    _buildGameStatItem('🎯', 'MOVES', '127'),
                  ],
                ),
              ],
            ),
          ),
          ModalFooter(
            child: _buildGameButton(
              context,
              label: 'NEXT LEVEL',
              icon: '🚀',
              onPressed: () {
                Navigator.of(context).pop();
                _startLevel(context, 2);
              },
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 32),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.primaryGold,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildGameButton(
    BuildContext context, {
    required String label,
    required String icon,
    required VoidCallback onPressed,
    required bool isPrimary,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          gradient: isPrimary
              ? const LinearGradient(
                  colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade800,
                    Colors.grey.shade900,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? AppColors.logoGradientEnd.withValues(alpha: 0.8)
                : Colors.grey.shade600,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.logoGradientEnd.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon.isNotEmpty) ...[
                    Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? Colors.black : Colors.white,
                        letterSpacing: 1.0,
                        shadows: isPrimary
                            ? [
                                const Shadow(
                                  color: Colors.white24,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ]
                            : [
                                const Shadow(
                                  color: Colors.black54,
                                  offset: Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String icon, String label, String value) {
    return Column(
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatefulWidget {
  final int level;
  final int gridSize;
  final String difficulty;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelCard({
    required this.level,
    required this.gridSize,
    required this.difficulty,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
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
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Level number with glassmorphism effect, lock icon, or checkmark
                        Container(
                          width: 48,
                          height: 48,
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
                          const SizedBox(height: 8),
                          Icon(
                            Icons.check_circle,
                            color: AppColors.completedAccent,
                            size: 20 + (_hoverAnimation.value * 2),
                          ),
                        ],
                        // Only show grid size and difficulty for non-completed levels
                        if (!widget.isCompleted) ...[
                          const SizedBox(height: 8),
                          // Grid size indicator with enhanced styling
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                              '${widget.gridSize}×${widget.gridSize}',
                              style: TextStyle(
                                fontSize: 12 + (_hoverAnimation.value * 1),
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
                          const SizedBox(height: 4),
                          // Difficulty indicator or locked text
                          Text(
                            _getStatusText(),
                            style: TextStyle(
                              fontSize: 10 + (_hoverAnimation.value * 0.5),
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
    if (level <= 3) {
      return [AppColors.success, AppColors.successDark];
    } else if (level <= 6) {
      return [AppColors.warning, AppColors.warningDark];
    } else if (level <= 9) {
      return [AppColors.info, AppColors.infoDark];
    } else {
      return [AppColors.error, AppColors.errorDark];
    }
  }

  List<Color> _getLockedGradient() {
    return [Colors.grey.shade700, Colors.grey.shade900];
  }

  List<Color> _getCardGradient() {
    if (widget.isCompleted) {
      return [AppColors.completed, AppColors.completedDark];
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
        // Main glow shadow with hover enhancement
        BoxShadow(
          color: AppColors.completed.withValues(alpha: 0.8 + (_hoverAnimation.value * 0.2)),
          blurRadius: 30 + (_hoverAnimation.value * 10),
          offset: const Offset(0, 12),
          spreadRadius: 6 + (_hoverAnimation.value * 2),
        ),
        // Gold accent glow
        BoxShadow(
          color: AppColors.completedAccent.withValues(alpha: 0.6 + (_hoverAnimation.value * 0.1)),
          blurRadius: 40 + (_hoverAnimation.value * 15),
          offset: const Offset(0, 18),
          spreadRadius: 8 + (_hoverAnimation.value * 3),
        ),
        // Dark shadow for depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4 + (_hoverAnimation.value * 0.1)),
          blurRadius: 20 + (_hoverAnimation.value * 5),
          offset: const Offset(0, 8),
        ),
        // Inner glow effect
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.1)),
          blurRadius: 15 + (_hoverAnimation.value * 5),
          offset: const Offset(0, -3),
          spreadRadius: -3,
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        // Main glow shadow with hover enhancement
        BoxShadow(
          color: _getLevelGradient(widget.level).first.withValues(alpha: 0.6 + (_hoverAnimation.value * 0.2)),
          blurRadius: 25 + (_hoverAnimation.value * 10),
          offset: const Offset(0, 10),
          spreadRadius: 4 + (_hoverAnimation.value * 2),
        ),
        // Secondary glow
        BoxShadow(
          color: _getLevelGradient(widget.level).first.withValues(alpha: 0.4 + (_hoverAnimation.value * 0.1)),
          blurRadius: 35 + (_hoverAnimation.value * 15),
          offset: const Offset(0, 15),
          spreadRadius: 6 + (_hoverAnimation.value * 3),
        ),
        // Dark shadow for depth
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4 + (_hoverAnimation.value * 0.1)),
          blurRadius: 20 + (_hoverAnimation.value * 5),
          offset: const Offset(0, 8),
        ),
        // Inner glow effect
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.1 + (_hoverAnimation.value * 0.1)),
          blurRadius: 10 + (_hoverAnimation.value * 5),
          offset: const Offset(0, -2),
          spreadRadius: -2,
        ),
      ];
    } else {
      return [
        // Locked state shadows
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.4),
          blurRadius: 15,
          offset: const Offset(0, 5),
          spreadRadius: 2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 10,
          offset: const Offset(0, 3),
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
          color: AppColors.completedAccent.withValues(alpha: 0.3 + (_hoverAnimation.value * 0.1)),
          blurRadius: 12 + (_hoverAnimation.value * 4),
          offset: const Offset(0, 3),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.1)),
          blurRadius: 8 + (_hoverAnimation.value * 4),
          offset: const Offset(0, -2),
        ),
      ];
    } else if (widget.isUnlocked) {
      return [
        BoxShadow(
          color: Colors.white.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.1)),
          blurRadius: 8 + (_hoverAnimation.value * 4),
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2 + (_hoverAnimation.value * 0.1)),
          blurRadius: 8 + (_hoverAnimation.value * 4),
          offset: const Offset(0, -2),
        ),
      ];
    } else {
      return [
        BoxShadow(
          color: Colors.grey.withValues(alpha: 0.1),
          blurRadius: 4,
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
