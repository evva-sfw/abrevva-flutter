import Flutter
import UIKit

public class AbrevvaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channelBle = FlutterMethodChannel(name: "AbrevvaBle", binaryMessenger: registrar.messenger())
    let instanceBle = AbrevvaBle()
      registrar.addMethodCallDelegate(instanceBle, channel: channelBle)
      
    let channelCrypto = FlutterMethodChannel(name: "AbrevvaCrypto", binaryMessenger: registrar.messenger())
    registrar.addMethodCallDelegate(AbrevvaCrypto(), channel: channelCrypto)

    let bleEventChannel = FlutterEventChannel(name: "AbrevvaBleEvents", binaryMessenger: registrar.messenger())
    bleEventChannel.setStreamHandler(instanceBle.streamHandler)
    
    let connectEventChannel = FlutterEventChannel(name: "connectEventChannel", binaryMessenger: registrar.messenger())
    let startScanEventChannel = FlutterEventChannel(name: "startScanEventChannel", binaryMessenger: registrar.messenger())
    let startNotificationsEventChannel = FlutterEventChannel(name: "startNotificationsEventChannel", binaryMessenger: registrar.messenger())
    let startEnabledNotificationsEventChannel = FlutterEventChannel(name: "startEnabledNotificationsEventChannel", binaryMessenger: registrar.messenger())
    startScanEventChannel.setStreamHandler(instanceBle.connectStreamHandler)
    startScanEventChannel.setStreamHandler(instanceBle.startScanStreamHandler)
    startNotificationsEventChannel.setStreamHandler(instanceBle.startNotificationsStreamHandler)
    startEnabledNotificationsEventChannel.setStreamHandler(instanceBle.startEnabledNotificationsEventChannel)
  }
}
