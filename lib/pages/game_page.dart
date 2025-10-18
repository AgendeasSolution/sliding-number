import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../utils/game_utils.dart';
import '../widgets/game_board.dart';
import '../widgets/game_button.dart';
import '../widgets/modal_container.dart';
import '../widgets/modal_header.dart';
import '../widgets/modal_footer.dart';
import '../widgets/goal_board.dart';
import '../widgets/ad_banner.dart';

class GamePage extends StatefulWidget {
  final int initialLevel;
  
  const GamePage({super.key, this.initialLevel = 1});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GameState? _gameState;
  Timer? _timer;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // Initialize audio service
    AudioService.instance.initialize();
    // Preload interstitial ad for better user experience
    InterstitialAdService.instance.preloadAd();
  }

  Future<void> _initializeGame() async {
    final gameState = await GameService.initializeGame(widget.initialLevel);
    if (mounted) {
      setState(() {
        _gameState = gameState;
        _isInitializing = false;
      });
      // Start the game immediately without showing start modal
      _initGame();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    if (_gameState != null) {
      setState(() {
        _gameState = GameService.shuffleBoard(_gameState!);
        _startGame();
      });
    }
  }

  void _startGame() {
    if (_gameState != null && !_gameState!.isGameActive) {
      setState(() {
        _gameState = GameService.startGame(_gameState!);
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_gameState != null && _gameState!.isGameActive && !_gameState!.isWin) {
        setState(() {
          _gameState = GameService.updateTimer(_gameState!);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetToInitialState() {
    if (_gameState != null) {
      // Show interstitial ad with 50% probability
      InterstitialAdService.instance.showAdWithProbability(
        onAdDismissed: () {
          // This callback runs after the ad is dismissed
          _performReset();
        },
      ).then((adShown) {
        if (!adShown) {
          // If ad wasn't shown (50% chance), perform reset immediately
          _performReset();
        }
        // If ad was shown, reset will happen in the onAdDismissed callback
      });
    }
  }

  void _performReset() {
    if (_gameState != null) {
      setState(() {
        _gameState = GameService.resetToInitial(_gameState!);
        _startGame();
      });
    }
  }

  Future<void> _nextLevel() async {
    if (_gameState != null && _gameState!.currentLevel < _gameState!.maxLevel) {
      final newGameState = await GameService.nextLevel(_gameState!);
      setState(() {
        _gameState = newGameState;
        _initGame();
      });
    }
  }

  Future<void> _nextLevelWithAd() async {
    // Show interstitial ad with 100% probability before next level
    final adShown = await InterstitialAdService.instance.showAdAlways(
      onAdDismissed: () {
        // This callback runs after the ad is dismissed
        _proceedToNextLevel();
      },
    );

    if (!adShown) {
      // If ad wasn't shown (due to loading error), proceed immediately
      _proceedToNextLevel();
    }
    // If ad was shown, next level will happen in the onAdDismissed callback
  }

  Future<void> _proceedToNextLevel() async {
    if (_gameState != null && _gameState!.currentLevel < _gameState!.maxLevel) {
      final newGameState = await GameService.nextLevel(_gameState!);
      if (mounted) {
        setState(() {
          _gameState = newGameState;
          _initGame();
        });
      }
    }
  }

  Future<void> _playAgain() async {
    if (_gameState != null) {
      final newGameState = await GameService.playAgain(_gameState!);
      setState(() {
        _gameState = newGameState;
        _initGame();
      });
    }
  }

  void _exitGame() {
    // Show interstitial ad with 50% probability before exiting
    InterstitialAdService.instance.showAdWithProbability(
      onAdDismissed: () {
        // This callback runs after the ad is dismissed - exit immediately
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    ).then((adShown) {
      if (!adShown) {
        // If ad wasn't shown (50% chance), exit immediately
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
      // If ad was shown, exit will happen in the onAdDismissed callback
    });
  }

  void _moveTile(int row, int col) {
    if (_gameState != null) {
      setState(() {
        _gameState = GameService.moveTile(_gameState!, row, col);
        if (_gameState!.isWin) {
          _handleWin();
        } else {
          // Play slide sound for successful tile movement
          AudioService.instance.playSlideSound();
        }
      });
    }
  }

  void _handleWin() {
    _stopTimer();
    // Play win sound when level is completed
    AudioService.instance.playWinSound();
    _completeLevel();
  }

  Future<void> _completeLevel() async {
    if (_gameState != null) {
      // Unlock the next level
      _gameState = await GameService.completeLevel(_gameState!);
      _showWinModal();
    }
  }

  void _shuffleGame() async {
    if (_gameState != null) {
      // First, ensure we have an ad loaded
      await InterstitialAdService.instance.preloadAd();
      
      // Show interstitial ad as reward for shuffle
      final adShown = await InterstitialAdService.instance.showAdAlways(
        onAdDismissed: () {
          // This callback runs after the ad is dismissed - user gets the reward
          _performShuffle();
        },
      );
      
      if (!adShown) {
        // If ad wasn't shown (due to loading error), still give the reward
        _performShuffle();
      }
      // If ad was shown, shuffle will happen in the onAdDismissed callback
    }
  }

  void _performShuffle() {
    if (_gameState != null) {
      setState(() {
        _gameState = GameService.shuffleBoard(_gameState!);
        _startGame();
      });
      // Show feedback that user earned the shuffle reward
      _showShuffleRewardFeedback();
    }
  }

  void _showShuffleRewardFeedback() {
    // Show a brief snackbar to confirm the reward was earned
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.shuffle, color: Colors.white),
            SizedBox(width: 8),
            Text('🎉 Shuffle reward earned! Board shuffled!'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_gameState != null) {
      if (details.primaryVelocity! > 0) { // Swiped Down
        _moveTile(_gameState!.emptyTilePos.x - 1, _gameState!.emptyTilePos.y);
      } else if (details.primaryVelocity! < 0) { // Swiped Up
        _moveTile(_gameState!.emptyTilePos.x + 1, _gameState!.emptyTilePos.y);
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_gameState != null) {
      if (details.primaryVelocity! > 0) { // Swiped Right
        _moveTile(_gameState!.emptyTilePos.x, _gameState!.emptyTilePos.y - 1);
      } else if (details.primaryVelocity! < 0) { // Swiped Left
        _moveTile(_gameState!.emptyTilePos.x, _gameState!.emptyTilePos.y + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _gameState == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.backgroundGradient,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGold,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: AppTheme.backgroundGradient,
        child: SafeArea(
          child: Column(
            children: [
              // Header positioned at the top
              _buildHeader(),
              // Game board and bottom bar in same section
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GameBoard(
                        gameState: _gameState!,
                        onTileTap: _moveTile,
                        onVerticalDragEnd: _onVerticalDragEnd,
                        onHorizontalDragEnd: _onHorizontalDragEnd,
                      ),
                      const SizedBox(height: 20), // 20px gap between game board and bottom bar
                      _buildBottomBar(),
                    ],
                  ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildExitButton(),
          _buildLevelDisplay(),
          _buildResetButton(),
        ],
      ),
    );
  }

  Widget _buildExitButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.error, AppColors.errorDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            AudioService.instance.playClickSound();
            _exitGame();
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

  Widget _buildLevelDisplay() {
    return Text(
      'Level ${_gameState?.currentLevel ?? 0}',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGold,
      ),
    );
  }

  Widget _buildResetButton() {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.warning, AppColors.warningDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            AudioService.instance.playClickSound();
            _resetToInitialState();
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
            Icons.refresh,
            color: AppColors.textWhite,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.gameBoardBackground, AppColors.tileBackgroundLight],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gameBoardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, -6),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Shuffle button on the left
          _buildShuffleButton(),
          // Time display in the center
          _buildTimeDisplay(),
          // Goal button on the right
          _buildGoalButton(),
        ],
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.logoGradientStart.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: AppColors.textPrimary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            GameUtils.formatTime(_gameState?.secondsElapsed ?? 0),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShuffleButton() {
    return GameButton(
      icon: Icons.shuffle,
      onPressed: () {
        AudioService.instance.playClickSound();
        _shuffleGame();
      }, // Watch ad to earn shuffle reward
      gradient: const LinearGradient(
        colors: [AppColors.logoGradientStart, AppColors.logoGradientEnd],
      ),
    );
  }

  Widget _buildGoalButton() {
    return GameButton(
      icon: Icons.flag,
      onPressed: () {
        AudioService.instance.playClickSound();
        _showGoalModal();
      },
      gradient: const LinearGradient(
        colors: [AppColors.success, AppColors.successDark],
      ),
    );
  }

  // --- Modals / Dialogs ---

  void _showModalDialog({required Widget child}) {
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


  void _showWinModal() {
    if (_gameState == null) return;
    
    final bool isGameComplete = _gameState!.isGameComplete;

    _showModalDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalHeader(
            title: isGameComplete ? '🏆 Game Complete!' : '🎉 Level ${_gameState!.currentLevel} Complete!',
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
                    _buildGameStatItem('⏱️', 'TIME', GameUtils.formatTime(_gameState!.secondsElapsed)),
                    Container(
                      height: 40,
                      width: 1,
                      color: AppColors.primaryGold.withValues(alpha: 0.3),
                    ),
                    _buildGameStatItem('🎯', 'MOVES', '${_gameState!.movesCount}'),
                  ],
                ),
              ],
            ),
          ),
          ModalFooter(
            child: _buildGameButton(
              context,
              label: isGameComplete ? 'PLAY AGAIN' : 'NEXT LEVEL',
              icon: isGameComplete ? '🔄' : '🚀', // Next level shows ad 100% of the time
              onPressed: () {
                AudioService.instance.playClickSound();
                Navigator.of(context).pop();
                if (isGameComplete) {
                  _playAgain();
                } else {
                  _nextLevelWithAd();
                }
              },
              isPrimary: true,
            ),
          ),
        ],
      ),
    );
  }

  void _showGoalModal() {
    if (_gameState == null) return;
    
    _showModalDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ModalHeader(
            title: '🎯 Goal - Level ${_gameState!.currentLevel}',
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
                GoalBoard(gameState: _gameState!),
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
}
