import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal Push Notification Service
/// Handles initialization and management of OneSignal push notifications
class OneSignalService {
  static final OneSignalService _instance = OneSignalService._internal();
  factory OneSignalService() => _instance;
  OneSignalService._internal();

  static OneSignalService get instance => _instance;

  // OneSignal App ID
  static const String _oneSignalAppId = 'ca8a28cf-d411-49b6-8d9b-0437b2612312';

  bool _isInitialized = false;

  /// Check if OneSignal is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize OneSignal SDK
  /// This should be called once during app startup in main.dart
  Future<void> initialize() async {
    if (_isInitialized) {
      return; // Already initialized
    }

    try {
      // Set App ID (synchronous call)
      OneSignal.initialize(_oneSignalAppId);

      // Set up notification handlers BEFORE requesting permission
      // This ensures handlers are ready when permission is granted
      _setupNotificationHandlers();

      // Request permission to show notifications (iOS)
      // This is async but we don't need to await it - it will complete in background
      OneSignal.Notifications.requestPermission(true);

      _isInitialized = true;
    } catch (e) {
      // Silent error handling - app should continue to work even if OneSignal fails
      _isInitialized = false;
    }
  }

  /// Set up notification event handlers
  void _setupNotificationHandlers() {
    // Handle notification received while app is in foreground
    OneSignal.Notifications.addForegroundWillDisplayListener((event) {
      // Notification will be displayed automatically
      // You can access event.notification for custom handling if needed
      // This is a void callback - no return value needed
    });

    // Handle notification clicked/tapped
    OneSignal.Notifications.addClickListener((event) {
      // Handle notification click
      // You can navigate to specific screens based on notification data
      final notification = event.notification;
      if (notification.additionalData != null) {
        // Handle custom data from notification
        // Example: Navigate to a specific screen
      }
    });

    // Handle permission changes
    OneSignal.Notifications.addPermissionObserver((state) {
      // Handle permission state changes
      // state.permission - true if granted, false if denied
    });

    // Handle subscription state changes
    OneSignal.User.pushSubscription.addObserver((state) {
      // Handle subscription state changes
      // state.current.id - OneSignal user ID
      // state.current.token - Push token
    });
  }

  /// Get the current OneSignal user ID
  /// Returns null if not initialized or user ID is not available
  Future<String?> getUserId() async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final subscription = OneSignal.User.pushSubscription;
      return subscription.id;
    } catch (e) {
      return null;
    }
  }

  /// Get the current push token
  /// Returns null if not initialized or token is not available
  Future<String?> getPushToken() async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final subscription = OneSignal.User.pushSubscription;
      return subscription.token;
    } catch (e) {
      return null;
    }
  }

  /// Check if push notifications are enabled
  Future<bool> isPushEnabled() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      final permission = OneSignal.Notifications.permission;
      return permission;
    } catch (e) {
      return false;
    }
  }

  /// Send a tag to OneSignal (for user segmentation)
  /// Example: setTag('user_level', '5') or setTag('premium', 'true')
  Future<void> setTag(String key, String value) async {
    if (!_isInitialized) {
      return;
    }

    try {
      // Use addTags with a map containing single tag
      await OneSignal.User.addTags({key: value});
    } catch (e) {
      // Silent error handling
    }
  }

  /// Send multiple tags to OneSignal
  Future<void> setTags(Map<String, String> tags) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await OneSignal.User.addTags(tags);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Remove a tag from OneSignal
  Future<void> removeTag(String key) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await OneSignal.User.removeTag(key);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Set user email (optional, for email notifications)
  Future<void> setEmail(String email) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await OneSignal.User.addEmail(email);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Set user external ID (optional, for linking with your backend)
  Future<void> setExternalUserId(String externalId) async {
    if (!_isInitialized) {
      return;
    }

    try {
      await OneSignal.User.addAlias('external_id', externalId);
    } catch (e) {
      // Silent error handling
    }
  }

  /// Prompt user for push notification permission (iOS)
  /// On Android, permission is typically granted automatically
  Future<bool> promptForPushPermission() async {
    if (!_isInitialized) {
      return false;
    }

    try {
      final permission = await OneSignal.Notifications.requestPermission(true);
      return permission;
    } catch (e) {
      return false;
    }
  }
}

