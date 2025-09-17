import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'pages/splash_page.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Google Mobile Ads SDK with error handling
  try {
    await MobileAds.instance.initialize();
    print('Google Mobile Ads initialized successfully');
  } catch (e) {
    print('Failed to initialize Google Mobile Ads: $e');
    // Continue running the app even if ads fail to initialize
  }
  
  // Set preferred orientations to portrait only
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
  
  runApp(const SlidingTileApp());
}

class SlidingTileApp extends StatelessWidget {
  const SlidingTileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Number',
      theme: AppTheme.darkTheme,
      home: const SplashPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
