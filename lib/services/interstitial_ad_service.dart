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
  
  /// Production ad unit ID from AdMob console
  static const String _productionAdUnitId = 'ca-app-pub-3772142815301617/4980344726';

  /// Current ad unit ID (using production for live app)
  /// Change to _testAdUnitId for development/testing
  static const String _adUnitId = _productionAdUnitId;

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;

  /// Load interstitial ad
  Future<void> loadAd() async {
    if (_isLoading || _isAdReady) return;

    _isLoading = true;
    print('Loading interstitial ad...');

    try {
      await InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            print('Interstitial ad loaded successfully');
            _interstitialAd = ad;
            _isAdReady = true;
            _isLoading = false;
            
            // Set up ad callbacks
            _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('Interstitial ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('Interstitial ad dismissed - calling callback immediately');
                // Call the callback immediately when ad is dismissed
                _onAdDismissedCallback?.call();
                _onAdDismissedCallback = null; // Clear callback
                _disposeAd();
                print('Callback called and ad disposed');
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Interstitial ad failed to show: $error');
                _disposeAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('Interstitial ad failed to load: $error');
            _isLoading = false;
            _isAdReady = false;
          },
        ),
      );
    } catch (e) {
      print('Error loading interstitial ad: $e');
      _isLoading = false;
      _isAdReady = false;
    }
  }

  /// Show interstitial ad if ready
  Future<bool> showAd({VoidCallback? onAdDismissed}) async {
    print('showAd called - isAdReady: $_isAdReady, ad: ${_interstitialAd != null}');
    
    if (!_isAdReady || _interstitialAd == null) {
      print('Interstitial ad not ready, loading new ad...');
      await loadAd();
      print('After loadAd - isAdReady: $_isAdReady, ad: ${_interstitialAd != null}');
      return false;
    }

    try {
      print('Attempting to show interstitial ad...');
      // Store the callback for when ad is dismissed
      _onAdDismissedCallback = onAdDismissed;
      await _interstitialAd!.show();
      print('Interstitial ad shown successfully');
      return true;
    } catch (e) {
      print('Error showing interstitial ad: $e');
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
    
    print('Interstitial ad probability check: ${shouldShowAd ? "SHOW" : "SKIP"} (${(probability * 100).toInt()}% chance)');
    
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
      print('Ad not ready for showAdAlways, loading...');
      await loadAd();
      
      // Wait a bit for the ad to load
      int attempts = 0;
      while (!_isAdReady && attempts < 3) {
        await Future.delayed(const Duration(milliseconds: 300));
        attempts++;
        print('Waiting for ad to load... attempt $attempts');
      }
    }
    
    return await showAdWithCustomProbability(1.0, onAdDismissed: onAdDismissed); // 100% probability
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
