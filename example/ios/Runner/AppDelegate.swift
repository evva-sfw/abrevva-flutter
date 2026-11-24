import CoreBluetooth
import Flutter
import UIKit

/// Flutter's Objective-C protocol omits actor isolation; this conformance inherits main-actor isolation from
/// FlutterAppDelegate.
@main
@objc
class AppDelegate: FlutterAppDelegate, @preconcurrency FlutterImplicitEngineDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
        GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    }
}
