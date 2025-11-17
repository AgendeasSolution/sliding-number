import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'pages/splash_page.dart';
import 'theme/app_theme.dart';
import 'services/audio_service.dart';
import 'services/onesignal_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set up global error handler ONCE (not in build method)
  // This prevents crashes and handles errors gracefully
  FlutterError.onError = (FlutterErrorDetails details) {
    // In debug mode, show errors for development
    // In production, silently handle to prevent crashes
    if (kDebugMode) {
      FlutterError.presentError(details);
    }
    // In production, errors are handled silently to prevent app crashes
  };
  
  // Set preferred orientations first (non-blocking)
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style for better splash experience
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Run app immediately to show splash screen (non-blocking)
  runApp(const SlidingTileApp());
  
  // Initialize services in background (non-blocking)
  // Fire and forget - don't await to prevent blocking
  _initializeServicesInBackground();
}

// Initialize services asynchronously without blocking app startup
// This function is fire-and-forget to prevent any blocking
Future<void> _initializeServicesInBackground() async {
  try {
    // Run all initializations in parallel with individual error handling
    // eagerError: false ensures one failure doesn't stop others
    await Future.wait([
      _initializeAds(),
      _initializeAudio(),
      _initializeOneSignal(),
    ], eagerError: false);
  } catch (e) {
    // Top-level catch - should never happen due to eagerError: false
    // But added for extra safety
  }
}

Future<void> _initializeAds() async {
  try {
    // Timeout prevents hanging - ads are not critical for app launch
    // This initializes AdMob SDK, but error handling works for all ad providers
    await MobileAds.instance.initialize().timeout(
      const Duration(seconds: 5),
    );
  } catch (e) {
    // Silent error - ads are optional, app continues normally
    // Works with any ad provider - if initialization fails, app still runs
    // No logging to avoid performance overhead
  }
}

Future<void> _initializeAudio() async {
  try {
    // Timeout prevents hanging - audio is not critical for app launch
    await AudioService.instance.initialize().timeout(
      const Duration(seconds: 3),
    );
  } catch (e) {
    // Silent error - audio is optional, app continues normally
    // No logging to avoid performance overhead
  }
}

Future<void> _initializeOneSignal() async {
  try {
    // Timeout prevents hanging - push notifications are not critical for app launch
    await OneSignalService.instance.initialize().timeout(
      const Duration(seconds: 5),
    );
  } catch (e) {
    // Silent error - push notifications are optional, app continues normally
    // No logging to avoid performance overhead
  }
}

class SlidingTileApp extends StatelessWidget {
  const SlidingTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Error handler is set in main() - not here to avoid performance issues
    // build() is called frequently, so we don't want to set handlers here
    
    return MaterialApp(
      title: 'Sliding Number',
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
