import 'dart:ui';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../models/game_state.dart';
import '../services/game_service.dart';
import '../services/interstitial_ad_service.dart';
import '../services/rewarded_ad_service.dart';
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
  bool _isLeftSwapMode = false;
  bool _isRightSwapMode = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    // Initialize audio service
    AudioService.instance.initialize();
    // Preload interstitial ad for better user experience
    InterstitialAdService.instance.preloadAd();
    // Preload rewarded ad for swipe buttons
    RewardedAdService.instance.preloadAd();
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
      
      // Show interstitial ad with 75% probability when entering game screen
      // Call asynchronously so it doesn't block game initialization
      _showEntryAd();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _initGame() {
    if (mounted && _gameState != null) {
      setState(() {
        _gameState = GameService.shuffleBoard(_gameState!);
        _isLeftSwapMode = false;
        _isRightSwapMode = false;
        // Keep unlock state - once unlocked, stays unlocked for the session
        _startGame();
      });
    }
  }

  void _startGame() {
    if (mounted && _gameState != null && !_gameState!.isGameActive) {
      setState(() {
        _gameState = GameService.startGame(_gameState!);
      });
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _gameState != null && _gameState!.isGameActive && !_gameState!.isWin) {
        setState(() {
          _gameState = GameService.updateTimer(_gameState!);
        });
      } else {
        timer.cancel();
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
    if (mounted && _gameState != null) {
      setState(() {
        _gameState = GameService.resetToInitial(_gameState!);
        _isLeftSwapMode = false;
        _isRightSwapMode = false;
        // Keep unlock state - once unlocked, stays unlocked for the session
        _startGame();
      });
    }
  }

  Future<void> _showEntryAd() async {
    // Show interstitial ad with 75% probability when entering game screen
    // First ensure ad is loaded
    final service = InterstitialAdService.instance;
    
    // If ad is not ready, try to load it and wait a bit
    if (!service.isAdReady) {
      await service.preloadAd();
      
      // Wait for ad to load (max 1.5 seconds)
      int attempts = 0;
      while (!service.isAdReady && attempts < 5) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      }
    }
    
    // Now try to show ad with 75% probability
    await service.showAdWithCustomProbability(
      0.75,
      onAdDismissed: () {
        // Ad was shown and dismissed - no additional action needed
      },
    );
    // No callback needed if ad isn't shown - game continues normally
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
          _isLeftSwapMode = false;
          _isRightSwapMode = false;
          // Keep unlock state - once unlocked, stays unlocked across levels
          _initGame();
        });
      }
    }
  }

  Future<void> _playAgain() async {
    if (_gameState != null) {
      final newGameState = await GameService.playAgain(_gameState!);
      if (mounted) {
        setState(() {
          _gameState = newGameState;
          _isLeftSwapMode = false;
          _isRightSwapMode = false;
          // Keep unlock state - once unlocked, stays unlocked for the session
          _initGame();
        });
      }
    }
  }

  void _showExitConfirmation() {
    _showModalDialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              children: [
                const Text(
                  'Are you sure you want to exit?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ModalFooter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GameButton(
                    label: 'Cancel',
                    onPressed: () {
                      AudioService.instance.playClickSound();
                      Navigator.of(context).pop();
                    },
                    gradient: const LinearGradient(
                      colors: [AppColors.neutral, AppColors.neutralDark],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GameButton(
                    label: 'Exit',
                    onPressed: () {
                      AudioService.instance.playClickSound();
                      Navigator.of(context).pop();
                      _exitGame();
                    },
                    gradient: const LinearGradient(
                      colors: [AppColors.warning, AppColors.warningDark],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exitGame() async {
    // Show interstitial ad for exit - only if already loaded (no waiting)
    final adShown = await InterstitialAdService.instance.showAdForExit(
      onAdDismissed: () {
        // This callback runs after the ad is dismissed - exit immediately
        if (mounted) {
          Navigator.of(context).pop();
        }
      },
    );

    if (!adShown) {
      // If ad wasn't shown (not ready or loading error), exit immediately
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
    // If ad was shown, exit will happen in the onAdDismissed callback
  }

  void _moveTile(int row, int col) {
    if (mounted && _gameState != null) {
      // Check if we're in swap mode
      if (_isLeftSwapMode || _isRightSwapMode) {
        _performSwap(row, col);
        return;
      }
      
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

  void _performSwap(int row, int col) {
    if (_gameState == null) return;
    
    // Check if the clicked tile is empty
    final tileIndex = row * _gameState!.columns + col;
    if (_gameState!.board[tileIndex] == AppConstants.emptyTileValue) {
      // Can't swap empty tile - exit swap mode
      setState(() {
        _isLeftSwapMode = false;
        _isRightSwapMode = false;
      });
      return;
    }
    
    final isLeftSwap = _isLeftSwapMode;
    final targetCol = isLeftSwap ? col - 1 : col + 1;
    
    // Check if swap is valid (target column must be within bounds)
    if (targetCol < 0 || targetCol >= _gameState!.columns) {
      // Invalid swap - exit swap mode
      setState(() {
        _isLeftSwapMode = false;
        _isRightSwapMode = false;
      });
      return;
    }
    
    // Perform the swap
    setState(() {
      _gameState = GameService.swapTiles(_gameState!, row, col, row, targetCol);
      _isLeftSwapMode = false;
      _isRightSwapMode = false;
      
      if (_gameState!.isWin) {
        _handleWin();
      } else {
        // Play slide sound for successful swap
        AudioService.instance.playSlideSound();
      }
    });
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
    if (mounted && _gameState != null) {
      setState(() {
        _gameState = GameService.shuffleBoard(_gameState!);
        _isLeftSwapMode = false;
        _isRightSwapMode = false;
        // Keep unlock state - once unlocked, stays unlocked for the session
        _startGame();
      });
      // Show feedback that user earned the shuffle reward
      if (mounted) {
        _showShuffleRewardFeedback();
      }
    }
  }

  void _showShuffleRewardFeedback() {
    if (!mounted) return;
    // Show a brief snackbar to confirm the reward was earned
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shuffle, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '🎉 Shuffle reward earned! Board shuffled!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
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
    // Don't allow drag gestures when in swap mode
    if (_isLeftSwapMode || _isRightSwapMode) return;
    
    if (_gameState != null) {
      if (details.primaryVelocity! > 0) { // Swiped Down
        _moveTile(_gameState!.emptyTilePos.x - 1, _gameState!.emptyTilePos.y);
      } else if (details.primaryVelocity! < 0) { // Swiped Up
        _moveTile(_gameState!.emptyTilePos.x + 1, _gameState!.emptyTilePos.y);
      }
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    // Don't allow drag gestures when in swap mode
    if (_isLeftSwapMode || _isRightSwapMode) return;
    
    if (_gameState != null) {
      if (details.primaryVelocity! > 0) { // Swiped Right
        _moveTile(_gameState!.emptyTilePos.x, _gameState!.emptyTilePos.y - 1);
      } else if (details.primaryVelocity! < 0) { // Swiped Left
        _moveTile(_gameState!.emptyTilePos.x, _gameState!.emptyTilePos.y + 1);
      }
    }
  }

  void _onLeftSwipeButtonPressed() async {
    if (_gameState != null && _gameState!.isGameActive) {
      if (_isLeftSwapMode) {
        // Cancel swap mode if already active
        setState(() {
          _isLeftSwapMode = false;
        });
        AudioService.instance.playClickSound();
      } else {
        // Show rewarded ad every time to use left swipe feature
        AudioService.instance.playClickSound();
        await _showAdForLeftSwipe();
      }
    }
  }

  Future<void> _showAdForLeftSwipe() async {
    final adShown = await RewardedAdService.instance.showAd(
      onRewarded: (reward) {
        // User watched the ad and earned the reward - enable left swipe
        if (mounted) {
          setState(() {
            _isLeftSwapMode = true;
            _isRightSwapMode = false; // Cancel right swap mode if active
          });
          // Preload next ad for future use
          RewardedAdService.instance.preloadAd();
        }
      },
      onAdFailedToShow: () {
        // If ad fails to show, enable the feature anyway (graceful fallback)
        if (mounted) {
          setState(() {
            _isLeftSwapMode = true;
            _isRightSwapMode = false; // Cancel right swap mode if active
          });
        }
      },
    );

    // If ad wasn't shown (not ready), enable the feature anyway (graceful fallback)
    if (!adShown && mounted) {
      setState(() {
        _isLeftSwapMode = true;
        _isRightSwapMode = false; // Cancel right swap mode if active
      });
    }
  }

  void _onRightSwipeButtonPressed() async {
    if (_gameState != null && _gameState!.isGameActive) {
      if (_isRightSwapMode) {
        // Cancel swap mode if already active
        setState(() {
          _isRightSwapMode = false;
        });
        AudioService.instance.playClickSound();
      } else {
        // Show rewarded ad every time to use right swipe feature
        AudioService.instance.playClickSound();
        await _showAdForRightSwipe();
      }
    }
  }

  Future<void> _showAdForRightSwipe() async {
    final adShown = await RewardedAdService.instance.showAd(
      onRewarded: (reward) {
        // User watched the ad and earned the reward - enable right swipe
        if (mounted) {
          setState(() {
            _isRightSwapMode = true;
            _isLeftSwapMode = false; // Cancel left swap mode if active
          });
          // Preload next ad for future use
          RewardedAdService.instance.preloadAd();
        }
      },
      onAdFailedToShow: () {
        // If ad fails to show, enable the feature anyway (graceful fallback)
        if (mounted) {
          setState(() {
            _isRightSwapMode = true;
            _isLeftSwapMode = false; // Cancel left swap mode if active
          });
        }
      },
    );

    // If ad wasn't shown (not ready), enable the feature anyway (graceful fallback)
    if (!adShown && mounted) {
      setState(() {
        _isRightSwapMode = true;
        _isLeftSwapMode = false; // Cancel left swap mode if active
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing || _gameState == null) {
      return Scaffold(
        body: Container(
          decoration: AppTheme.backgroundImage,
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGold,
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: AppTheme.backgroundImage,
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
                          isSwapMode: _isLeftSwapMode || _isRightSwapMode,
                          swapDirection: _isLeftSwapMode ? 'left' : (_isRightSwapMode ? 'right' : null),
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
          _buildGoalButtonHeader(),
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
            _showExitConfirmation();
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

  Widget _buildGoalButtonHeader() {
    return SizedBox(
      width: 40,
      height: 40,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.success, AppColors.successDark],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            AudioService.instance.playClickSound();
            _showGoalModal();
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
            Icons.flag,
            color: AppColors.textWhite,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2F4D),
            Color(0xFF1A1F3A),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.4),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildSwipeButton(
            icon: Icons.arrow_back,
            label: _isLeftSwapMode ? 'Cancel' : 'Swipe Left',
            onPressed: _onLeftSwipeButtonPressed,
            isEnabled: _gameState?.isGameActive ?? false,
            isActive: _isLeftSwapMode,
          ),
          const SizedBox(width: 16),
          _buildSwipeButton(
            icon: Icons.arrow_forward,
            label: _isRightSwapMode ? 'Cancel' : 'Swipe Right',
            onPressed: _onRightSwipeButtonPressed,
            isEnabled: _gameState?.isGameActive ?? false,
            isActive: _isRightSwapMode,
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
    bool isEnabled = true,
    bool showWatchAd = false,
  }) {
    final bool isDisabled = !isEnabled;
    
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.neutralDark : color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDisabled
              ? []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: SizedBox(
            height: 80, // Reduced height for all buttons
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon at the top (without square container)
                Icon(
                  icon,
                  color: Colors.black,
                  size: 20,
                ),
                const SizedBox(height: 4),
                // Button name below icon - allow wrapping
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
                const SizedBox(height: 2),
                // Watch Ad text below button name
                Text(
                  showWatchAd && isEnabled ? 'Watch Ad' : '',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.black.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool isEnabled,
    bool isActive = false,
  }) {
    return Expanded(
      child: _buildUnifiedButton(
        icon: icon,
        label: label,
        onPressed: onPressed,
        color: isActive ? AppColors.logoGradientStart : AppColors.logoGradientStart,
        isEnabled: isEnabled,
        showWatchAd: !isActive && isEnabled,
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle button (left)
          Expanded(
            child: _buildUnifiedButton(
              icon: Icons.shuffle,
              label: 'Shuffle',
              onPressed: () {
                AudioService.instance.playClickSound();
                _shuffleGame();
              },
              color: AppColors.logoGradientStart,
              isEnabled: _gameState?.isGameActive ?? false,
              showWatchAd: _gameState?.isGameActive ?? false,
            ),
          ),
          const SizedBox(width: 8),
          // Swipe Left button (center-left)
          _buildSwipeButton(
            icon: Icons.arrow_back,
            label: _isLeftSwapMode ? 'Cancel' : 'Swipe Left',
            onPressed: _onLeftSwipeButtonPressed,
            isEnabled: _gameState?.isGameActive ?? false,
            isActive: _isLeftSwapMode,
          ),
          const SizedBox(width: 8),
          // Swipe Right button (center-right)
          _buildSwipeButton(
            icon: Icons.arrow_forward,
            label: _isRightSwapMode ? 'Cancel' : 'Swipe Right',
            onPressed: _onRightSwipeButtonPressed,
            isEnabled: _gameState?.isGameActive ?? false,
            isActive: _isRightSwapMode,
          ),
          const SizedBox(width: 8),
          // Reset button (right)
          Expanded(
            child: _buildUnifiedButton(
              icon: Icons.refresh,
              label: 'Reset',
              onPressed: () {
                AudioService.instance.playClickSound();
                _resetToInitialState();
              },
              color: AppColors.logoGradientStart,
              isEnabled: _gameState?.isGameActive ?? false,
              showWatchAd: _gameState?.isGameActive ?? false,
            ),
          ),
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
              : const LinearGradient(
                  colors: [
                    Color(0xFF2A2F4D),
                    Color(0xFF1A1F3A),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPrimary
                ? AppColors.logoGradientEnd.withValues(alpha: 0.8)
                : AppColors.primaryGold.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isPrimary
                  ? AppColors.logoGradientEnd.withValues(alpha: 0.4)
                  : AppColors.primaryGold.withValues(alpha: 0.3),
              blurRadius: 15,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
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
