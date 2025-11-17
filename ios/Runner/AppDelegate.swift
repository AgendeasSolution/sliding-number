import Flutter
import UIKit
import FBSDKCoreKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Initialize Facebook SDK
    ApplicationDelegate.shared.application(
      application,
      didFinishLaunchingWithOptions: launchOptions
    )
    
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let appInfoChannel = FlutterMethodChannel(name: "com.fgtp.sliding_tile/app_info",
                                              binaryMessenger: controller.binaryMessenger)
    
    appInfoChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      if call.method == "getVersion" {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
          result(version)
        } else {
          result(FlutterError(code: "UNAVAILABLE",
                              message: "Version not available.",
                              details: nil))
        }
      } else {
        result(FlutterMethodNotImplemented)
      }
    })
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    // Handle Facebook SDK URL callbacks
    if ApplicationDelegate.shared.application(app, open: url, options: options) {
      return true
    }
    return super.application(app, open: url, options: options)
  }
}
