import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to manage interstitial ads
class InterstitialAdService {
  static InterstitialAdService? _instance;
  static InterstitialAdService get instance => _instance ??= InterstitialAdService._();
  
  InterstitialAdService._();

  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  bool _isLoading = false;
  VoidCallback? _onAdDismissedCallback;

  /// Test ad unit ID for development
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  
  /// Production ad unit IDs from AdMob console
  // Android production ad unit ID
  static const String _productionAdUnitIdAndroid = 'ca-app-pub-3772142815301617/4980344726';
  
  // iOS production ad unit ID
  static const String _productionAdUnitIdIOS = 'ca-app-pub-3772142815301617/5695662924';

  /// Get platform-specific production ad unit ID
  static String get _productionAdUnitId {
    if (Platform.isIOS) {
      return _productionAdUnitIdIOS;
    }
    return _productionAdUnitIdAndroid;
  }

  /// Current ad unit ID (using production for live app)
  /// Change to _testAdUnitId for development/testing
  static String get _adUnitId => _productionAdUnitId;

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;

  /// Load interstitial ad
  Future<void> loadAd() async {
    if (_isLoading || _isAdReady) return;

    _isLoading = true;

    try {
      await InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isAdReady = true;
            _isLoading = false;
            
            // Set up ad callbacks
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                // Ad showed full screen content
              },
              onAdDismissedFullScreenContent: (ad) {
                // Call the callback immediately when ad is dismissed
                _onAdDismissedCallback?.call();
                _onAdDismissedCallback = null; // Clear callback
                _disposeAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                _disposeAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            _isAdReady = false;
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      _isAdReady = false;
    }
  }

  /// Show interstitial ad if ready
  Future<bool> showAd({VoidCallback? onAdDismissed}) async {
    if (!_isAdReady || _interstitialAd == null) {
      await loadAd();
      return false;
    }

    try {
      // Store the callback for when ad is dismissed
      _onAdDismissedCallback = onAdDismissed;
      await _interstitialAd!.show();
      return true;
    } catch (e) {
      _disposeAd();
      return false;
    }
  }

  /// Show interstitial ad with 50% probability
  /// Returns true if ad was shown, false if not shown (due to probability or other reasons)
  Future<bool> showAdWithProbability({VoidCallback? onAdDismissed}) async {
    return await showAdWithCustomProbability(0.5, onAdDismissed: onAdDismissed); // 50% probability
  }

  /// Show interstitial ad with custom probability (0.0 to 1.0)
  /// Returns true if ad was shown, false if not shown (due to probability or other reasons)
  Future<bool> showAdWithCustomProbability(double probability, {VoidCallback? onAdDismissed}) async {
    // Generate random number between 0 and 1
    final random = Random();
    final shouldShowAd = random.nextDouble() < probability;
    
    if (!shouldShowAd) {
      return false; // Skip showing ad
    }

    // Try to show ad if probability allows
    return await showAd(onAdDismissed: onAdDismissed);
  }

  /// Show interstitial ad with 100% probability (always show)
  /// Returns true if ad was shown, false if not shown (due to loading errors)
  Future<bool> showAdAlways({VoidCallback? onAdDismissed}) async {
    // Ensure we have an ad loaded first
    if (!_isAdReady || _interstitialAd == null) {
      await loadAd();
      
      // Wait a bit for the ad to load
      int attempts = 0;
      while (!_isAdReady && attempts < 3) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
      }
    }
    
    return await showAdWithCustomProbability(1.0, onAdDismissed: onAdDismissed); // 100% probability
  }

  /// Show interstitial ad for exit - try to load quickly, but don't wait too long
  /// Returns true if ad was shown, false if not shown (due to not being ready)
  Future<bool> showAdForExit({VoidCallback? onAdDismissed}) async {
    // If ad is already loaded, show it immediately
    if (_isAdReady && _interstitialAd != null) {
      return await showAdWithCustomProbability(1.0, onAdDismissed: onAdDismissed);
    }
    
    // Try to load ad quickly with minimal waiting
    if (!_isLoading) {
      await loadAd();
      
      // Wait briefly for ad to load (only 1 attempt with 200ms delay)
      int attempts = 0;
      while (!_isAdReady && attempts < 1) {
        await Future.delayed(const Duration(milliseconds: 200));
        attempts++;
      }
    }
    
    // Show ad if it's ready, otherwise skip
    if (_isAdReady && _interstitialAd != null) {
      return await showAdWithCustomProbability(1.0, onAdDismissed: onAdDismissed);
    }
    
    return false; // Skip ad if not ready to avoid delay
  }

  /// Preload ad for better user experience
  Future<void> preloadAd() async {
    if (!_isAdReady && !_isLoading) {
      await loadAd();
    }
  }

  /// Dispose current ad
  void _disposeAd() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }

  /// Dispose service
  void dispose() {
    _disposeAd();
  }
}
