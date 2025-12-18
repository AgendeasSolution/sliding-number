import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// Service to check for app updates from Play Store and App Store
class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  factory AppUpdateService() => _instance;
  AppUpdateService._internal();

  static AppUpdateService get instance => _instance;

  // Platform channel for getting app version
  static const MethodChannel _channel = MethodChannel('com.fgtp.sliding_tile/app_info');

  // Package identifiers
  static const String _androidPackageName = 'com.fgtp.sliding_tile';
  static const String _iosBundleId = 'com.fgtp.slidingTile';
  static const String _iosAppId = '6754685051'; // App Store App ID
  static const String _lastUpdatePromptKey = 'last_update_prompt_timestamp';

  /// Get current app version using platform channels
  /// Returns null on any error or timeout to prevent blocking
  Future<String?> getCurrentVersion() async {
    try {
      if (kIsWeb) return null;
      
      // Short timeout to prevent ANR - platform channel should be fast
      final String? version = await _channel.invokeMethod('getVersion').timeout(
        const Duration(seconds: 2),
        onTimeout: () => null,
      );
      return version;
    } on PlatformException catch (e) {
      // Platform-specific errors (channel not available, etc.)
      // Silent error - never block the app for version check
      return null;
    } on TimeoutException {
      // Timeout occurred - return null to prevent blocking
      return null;
    } catch (e) {
      // Any other error - never block the app for version check
      return null;
    }
  }

  /// Get latest version from Play Store (Android)
  Future<String?> getLatestVersionFromPlayStore() async {
    try {
      // Play Store API endpoint
      final url = Uri.parse(
        'https://play.google.com/store/apps/details?id=$_androidPackageName&hl=en'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final body = response.body;
        
        // Parse version from HTML - Play Store HTML contains version in various formats
        // Try multiple patterns to find the version number
        
        // Pattern 1: Look for "Current Version" text followed by version number
        final versionPattern1 = RegExp(
          r'Current Version[^>]*>([^<]*?)(\d+\.\d+\.\d+)',
          caseSensitive: false,
        );
        final match1 = versionPattern1.firstMatch(body);
        if (match1 != null && match1.groupCount >= 2) {
          return match1.group(2);
        }

        // Pattern 2: Look for version in JSON-LD structured data
        final versionPattern2 = RegExp(
          r'"softwareVersion"\s*:\s*"(\d+\.\d+\.\d+)"',
          caseSensitive: false,
        );
        final match2 = versionPattern2.firstMatch(body);
        if (match2 != null && match2.groupCount >= 1) {
          return match2.group(1);
        }

        // Pattern 3: Look for version in meta tags
        final versionPattern3 = RegExp(
          r'<meta[^>]*itemprop="softwareVersion"[^>]*content="(\d+\.\d+\.\d+)"',
          caseSensitive: false,
        );
        final match3 = versionPattern3.firstMatch(body);
        if (match3 != null && match3.groupCount >= 1) {
          return match3.group(1);
        }

        // Pattern 4: Look for "Version X.X.X" pattern in text
        final versionPattern4 = RegExp(
          r'Version\s+(\d+\.\d+\.\d+)',
          caseSensitive: false,
        );
        final match4 = versionPattern4.firstMatch(body);
        if (match4 != null && match4.groupCount >= 1) {
          return match4.group(1);
        }
      }
    } catch (e) {
      // Silent error - failures should never interrupt the user experience
    }
    return null;
  }

  /// Get latest version from App Store (iOS)
  Future<String?> getLatestVersionFromAppStore() async {
    try {
      // App Store API endpoint
      final url = Uri.parse(
        'https://itunes.apple.com/lookup?bundleId=$_iosBundleId'
      );
      
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        
        if (jsonData['results'] != null && 
            jsonData['results'] is List && 
            (jsonData['results'] as List).isNotEmpty) {
          final appInfo = jsonData['results'][0];
          if (appInfo['version'] != null) {
            return appInfo['version'] as String;
          }
        }
      }
    } catch (e) {
      // Silent error - failures should never interrupt the user experience
    }
    return null;
  }

  /// Check if update is available
  /// Returns false on any error or timeout to prevent blocking the app
  Future<bool> isUpdateAvailable() async {
    try {
      // Add overall timeout to prevent ANR
      return await Future.any([
        _checkUpdateInternal(),
        Future.delayed(const Duration(seconds: 8), () => false),
      ]);
    } catch (e) {
      // Silent error - never block the app
      return false;
    }
  }

  Future<bool> _checkUpdateInternal() async {
    try {
      final currentVersion = await getCurrentVersion();
      if (currentVersion == null) return false;

      String? latestVersion;
      if (Platform.isAndroid) {
        latestVersion = await getLatestVersionFromPlayStore();
      } else if (Platform.isIOS) {
        latestVersion = await getLatestVersionFromAppStore();
      }

      if (latestVersion == null) return false;

      return _compareVersions(latestVersion, currentVersion) > 0;
    } catch (e) {
      return false;
    }
  }

  /// Returns true if we haven't shown the update dialog yet "today".
  /// This is based on calendar day (local time), not exact 24h difference,
  /// so the user will see at most one prompt per day.
  Future<bool> shouldShowUpdatePromptToday() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastTimestamp = prefs.getInt(_lastUpdatePromptKey);
      if (lastTimestamp == null) {
        return true;
      }

      final last = DateTime.fromMillisecondsSinceEpoch(lastTimestamp);
      final now = DateTime.now();

      final sameDay =
          last.year == now.year && last.month == now.month && last.day == now.day;

      return !sameDay;
    } catch (e) {
      // If anything goes wrong, default to showing (we still throttle by update check)
      return true;
    }
  }

  /// Record that we have just shown the update prompt.
  Future<void> recordUpdatePromptShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastUpdatePromptKey,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // Silent failure – never block UX because of storage issues
    }
  }

  /// Compare two version strings
  /// Returns: 1 if version1 > version2, -1 if version1 < version2, 0 if equal
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final v2Parts = version2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad with zeros to make equal length
    while (v1Parts.length < v2Parts.length) v1Parts.add(0);
    while (v2Parts.length < v1Parts.length) v2Parts.add(0);

    for (int i = 0; i < v1Parts.length; i++) {
      if (v1Parts[i] > v2Parts[i]) return 1;
      if (v1Parts[i] < v2Parts[i]) return -1;
    }
    return 0;
  }

  /// Launch app store page for update
  Future<void> launchStorePage() async {
    try {
      Uri storeUrl;
      if (Platform.isAndroid) {
        storeUrl = Uri.parse(
          'https://play.google.com/store/apps/details?id=$_androidPackageName'
        );
      } else if (Platform.isIOS) {
        storeUrl = Uri.parse(
          'https://apps.apple.com/app/id$_iosAppId'
        );
      } else {
        return;
      }

      if (await canLaunchUrl(storeUrl)) {
        await launchUrl(storeUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Silent error - failures should never interrupt the user experience
    }
  }

  /// Get store URL for the app
  String getStoreUrl() {
    if (Platform.isAndroid) {
      return 'https://play.google.com/store/apps/details?id=$_androidPackageName';
    } else if (Platform.isIOS) {
      return 'https://apps.apple.com/app/id$_iosAppId';
    }
    return '';
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

