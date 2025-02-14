import Flutter
import UIKit

public class AbrevvaPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channelBle = FlutterMethodChannel(name: "AbrevvaBle", binaryMessenger: registrar.messenger())
    let instanceBle = AbrevvaBle()
      registrar.addMethodCallDelegate(instanceBle, channel: channelBle)
      
    let channelCrypto = FlutterMethodChannel(name: "AbrevvaCrypto", binaryMessenger: registrar.messenger())
    let instanceCrypto = AbrevvaCrypto()
    registrar.addMethodCallDelegate(instanceCrypto, channel: channelCrypto)

    let bleEventChannel = FlutterEventChannel(name: "AbrevvaBleEvents", binaryMessenger: registrar.messenger())
    bleEventChannel.setStreamHandler(instanceBle)
  }
}
