import Flutter
import UIKit

public class AbrevvaPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {

        /// Register `AbrevvaCrypto` Method Channel
        let channelCrypto = FlutterMethodChannel(name: "AbrevvaCrypto", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(AbrevvaCrypto(), channel: channelCrypto)

        /// Register `AbrevvaBle` Method Channel
        /// and create individual EventChannels for all Memberfunctions that require an EventChannel
        let channelBle = FlutterMethodChannel(name: "AbrevvaBle", binaryMessenger: registrar.messenger())
        let instanceBle = AbrevvaBle()
        registrar.addMethodCallDelegate(instanceBle, channel: channelBle)

        let connectEventChannel = FlutterEventChannel(
            name: "connectEventChannel", binaryMessenger: registrar.messenger()
        )
        let startScanEventChannel = FlutterEventChannel(
            name: "startScanEventChannel", binaryMessenger: registrar.messenger()
        )
        let startNotificationsEventChannel = FlutterEventChannel(
            name: "startNotificationsEventChannel", binaryMessenger: registrar.messenger()
        )
        let startEnabledNotificationsEventChannel = FlutterEventChannel(
            name: "startEnabledNotificationsEventChannel", binaryMessenger: registrar.messenger()
        )
        connectEventChannel.setStreamHandler(instanceBle.connectStreamHandler)
        startScanEventChannel.setStreamHandler(instanceBle.startScanStreamHandler)
        startNotificationsEventChannel.setStreamHandler(instanceBle.startNotificationsStreamHandler)
        startEnabledNotificationsEventChannel.setStreamHandler(instanceBle.startEnabledNotificationsEventChannel)

        /// Register `AbrevvaCodingStation` Method Channel
        let channelCodingStation = FlutterMethodChannel(
            name: "AbrevvaCodingStation", binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(AbrevvaCodingStation(), channel: channelCodingStation)

    }
}
