import Flutter
import Foundation
import AbrevvaSDK
import CoreBluetooth

internal class AbrevvaBleStreamHandler: NSObject, FlutterStreamHandler {
    internal var eventSink: FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        return nil
    }
}

@MainActor
public class AbrevvaBle: NSObject, @preconcurrency FlutterPlugin {
    public static func register(with registrar: any FlutterPluginRegistrar) {

    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            initialize(call, result: result)
        case "isEnabled":
            isEnabled(call, result: result)
        case "isLocationEnabled":
            isLocationEnabled(result)
        case "stopEnabledNotifications":
            stopEnabledNotifications(call, result: result)
        case "openLocationSettings":
            openLocationSettings(call, result: result)
        case "openBluetoothSettings":
            openBluetoothSettings(call, result: result)
        case "openAppSettings":
            openAppSettings(call, result: result)
        case "stopScan":
            stopScan(call, result: result)
        case "connect":
            connect(call, result: result)
        case "disconnect":
            disconnect(call, result: result)
        case "read":
            read(call, result: result)
        case "write":
            write(call, result: result)
        case "disengage":
            disengage(call, result: result)
        case "disengageWithXvnResponse":
            disengageWithXvnResponse(call, result: result)
        case "stopNotifications":
            stopNotifications(call, result: result)
        case "signalize":
            signalize(call, result: result)
        case "startEnabledNotifications":
            startEnabledNotifications(call, result: result)
        case "startScan":
            startScan(call, result: result)
        case "startNotifications":
            startNotifications(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private var bleManager: BleManager?
    private var bleDeviceMap = [String: BleDevice]()
    internal let streamHandler =  AbrevvaBleStreamHandler()

    internal let connectStreamHandler = AbrevvaBleStreamHandler()
    internal let startScanStreamHandler = AbrevvaBleStreamHandler()
    internal let startNotificationsStreamHandler = AbrevvaBleStreamHandler()
    internal let startEnabledNotificationsEventChannel = AbrevvaBleStreamHandler()

    @objc
    func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.bleManager = BleManager { success, message in
            if success {
                result(success)
            } else {
                result(FlutterError(code: message!, message: nil, details: nil))
            }
        }
    }

    @objc
    func isEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        let enabled: Bool = bleManager.isBleEnabled()
        result(enabled)
    }

    @objc
    func isLocationEnabled(_ result: @escaping FlutterResult) {
        result(FlutterError(code: "isLocationEnabled(): not available on iOS", message: nil,details: nil))
    }

    @objc
    func startEnabledNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        bleManager.registerStateReceiver { enabled in
            self.startEnabledNotificationsEventChannel.eventSink?(["value": enabled])
        }
        result(nil)
    }

    @objc
    func stopEnabledNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        bleManager.unregisterStateReceiver()
        result(nil)
    }

    @objc
    func openLocationSettings(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(code: "openLocationSettings(): is not available on iOS", message: nil, details: nil))
    }

    @objc
    func openBluetoothSettings(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(FlutterError(code: "openBluetoothSettings(): is not available on iOS", message: nil, details: nil))
    }

    @objc
    func openAppSettings(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else {
            result(FlutterError(code: "openAppSettings(): cannot open app settings", message: nil, details: nil))
            return
        }

        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(settingsURL) {
                UIApplication.shared.open(settingsURL, completionHandler: { _ in
                    result(nil)
                })
            } else {
                result(FlutterError(code: "openAppSettings(): cannot open app settings", message: nil, details: nil))
            }
        }
    }

    @objc
    func startScan(_ call: FlutterMethodCall,  result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }
        let macFilter = args["macFilter"] as? String ?? nil
        let allowDuplicates = args["allowDuplicates"] as? Bool ?? false
        let timeout =   args["timeout"] as? Int ?? 10000

        bleManager.startScan({ device in
            self.bleDeviceMap[device.getAddress()] = device
            self.startScanStreamHandler.eventSink?(["event": "onScanResult", "value": self.getAdvertismentData(device) ])
        }, { error in
            self.startScanStreamHandler.eventSink?(["event": "onScanStart", "value": error == nil])
        }, { error in
            self.startScanStreamHandler.eventSink?(["event": "onScanStop", "value": error == nil])
        },
        macFilter,
        allowDuplicates,
        timeout
        )
        result(nil)
    }

    @objc
    func stopScan(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        bleManager.stopScan()
        result("success")
    }

    @objc
    func connect(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result, checkConnection: false) else { return }

        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }

        let timeout = optionsSwift["timeout"] as? Int ?? 10_000

        Task {
            let success = await self.bleManager!.connect(
                device, { address in
                    self.connectStreamHandler.eventSink?(["value": address ])
                },
                timeout
            )
            result(success)
        }
    }

    @objc
    func disconnect(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result, checkConnection: false) else { return }

        Task {
            let success = await self.bleManager!.disconnect(device)
            if success {
                result(nil)
            } else {
                result(FlutterError(code: "disconnect(): failed to disconnect from device", message: nil, details: nil))
            }
        }
    }

    @objc
    func read(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result) else { return }
        guard let characteristic = self.getCharacteristic(call, result: result) else { return }

        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }
        let timeout = optionsSwift["timeout"] as? Int ?? nil

        Task {
            let data = await device.read(characteristic.0, characteristic.1, timeout)
            if data != nil {
                result(["value": [UInt8](data!)])
            } else {
                result(FlutterError(code: "read(): failed to read data", message: nil, details: nil))
            }
        }
    }

    @objc
    func write(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result) else { return }
        guard let characteristic = self.getCharacteristic(call, result: result) else { return }
        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }
        guard let value = optionsSwift["value"] as? String else {
            result(FlutterError(code: "write(): value must be provided", message: nil, details: nil))
            return
        }
        let writeType = CBCharacteristicWriteType.withoutResponse
        let timeout = optionsSwift["timeout"] as? Int ?? nil

        Task {
            let success = await device.write(
                characteristic.0,
                characteristic.1,
                stringToData(value),
                writeType,
                timeout
            )
            if success {
                result(nil)
            } else {
                result(FlutterError(code: "write(): failed to write data", message: nil, details: nil))
            }
        }
    }

    @objc
    @available(*, deprecated, message: "Use disengageWithXvnResponse() instead.")
    func disengage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result, checkConnection: false) else { return }

        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }

        let mobileID = optionsSwift["mobileId"] as? String ?? ""
        let mobileDeviceKey = optionsSwift["mobileDeviceKey"] as? String ?? ""
        let mobileGroupID = optionsSwift["mobileGroupId"] as? String ?? ""
        let mobileAccessData = optionsSwift["mobileAccessData"] as? String ?? ""
        let isPermanentRelease = optionsSwift["isPermanentRelease"] as? Bool ?? false

        Task {
            let status = await self.bleManager!.disengage(
                device,
                mobileID,
                mobileDeviceKey,
                mobileGroupID,
                mobileAccessData,
                isPermanentRelease
            )
            result(status.rawValue)
        }
    }

    @objc
    func disengageWithXvnResponse(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result, checkConnection: false) else { return }

        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }

        let mobileID = optionsSwift["mobileId"] as? String ?? ""
        let mobileDeviceKey = optionsSwift["mobileDeviceKey"] as? String ?? ""
        let mobileGroupID = optionsSwift["mobileGroupId"] as? String ?? ""
        let mobileAccessData = optionsSwift["mobileAccessData"] as? String ?? ""
        let isPermanentRelease = optionsSwift["isPermanentRelease"] as? Bool ?? false

        Task {
            let response = await self.bleManager!.disengageWithXvnResponse(
                device,
                mobileID,
                mobileDeviceKey,
                mobileGroupID,
                mobileAccessData,
                isPermanentRelease
            )
            let xvnData = response.1?.toHexString() ?? nil

            result([
                "status": response.0.rawValue,
                "xvnData": xvnData as Any
            ])
        }
    }

    @objc
    func startNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(args) else { return }
        guard let characteristic = self.getCharacteristic(args) else { return }

        let timeout = args["timeout"] as? Int ?? nil

        Task {
            let success = await device.setNotifications(characteristic.0, characteristic.1, true, { value in
                let key =
                    "notification|\(device.getAddress())|" +
                    "\(characteristic.0.uuidString.lowercased())|" +
                    "\(characteristic.1.uuidString.lowercased())"
                DispatchQueue.main.async {
                    if value != nil {
                        self.startNotificationsStreamHandler.eventSink?([key: ["value": dataToString(value!)]])
                    } else {
                        self.startNotificationsStreamHandler.eventSink?(["status": "error", "description": "error in setNotifications()"])
                    }
                }
            }, timeout)
            if success {
                result(["value": success])
            } else {
                result(FlutterError(code: "stopNotifications(): failed to stop notifications", message: nil, details: nil))
            }
        }
    }

    @objc
    func stopNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result) else { return }
        guard let characteristic = self.getCharacteristic(call, result: result) else { return }

        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }

        let timeout = optionsSwift["timeout"] as? Int ?? nil

        Task {
            let success = await device.setNotifications(characteristic.0, characteristic.1, false, nil, timeout)
            if success {
                result(["value": success])
            } else {
                result(FlutterError(code: "stopNotifications(): failed to stop notifications", message: nil, details: nil))
            }
        }
    }

    @objc
    func signalize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return
        }
        guard let deviceID = optionsSwift["deviceId"] as? String else {
            result(FlutterError(code: "getDevice(): deviceId required", message: nil, details: nil))
            return
        }
        guard let device = self.bleDeviceMap[deviceID] else {
            result(FlutterError(code: "getDevice(): device not found", message: nil, details: nil))
            return
        }
        guard let bleManager = self.bleManager else {
            result(FlutterError(code: "bleManager: not found", message: nil, details: nil))
            return
        }
        Task {
            let ret = await bleManager.signalize(device)
            result(ret)
        }
    }

    private func getBleManager(_ result: @escaping FlutterResult) -> BleManager? {
        guard let bleManager = self.bleManager else {
            result(FlutterError(code: "getBleManager(): not initialized", message: nil, details: nil))
            return nil
        }
        return bleManager
    }

    private func getServiceUUIDs(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> [CBUUID]? {
        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return nil
        }
        let services = optionsSwift["services"] as? [String] ?? []
        let serviceUUIDs = services.map { service -> CBUUID in
            return CBUUID(string: service)
        }
        return serviceUUIDs
    }

    private func getDevice(_ call: FlutterMethodCall, result: @escaping FlutterResult, checkConnection: Bool = true) -> BleDevice? {
        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return nil
        }

        guard let deviceID = optionsSwift["deviceId"] as? String else {
            result(FlutterError(code: "getDevice(): deviceId required", message: nil, details: nil))
            return nil
        }
        guard let device = self.bleDeviceMap[deviceID] else {
            result(FlutterError(code: "getDevice(): device not found", message: nil, details: nil))
            return nil
        }
        if checkConnection {
            guard device.isConnected() else {
                result(FlutterError(code: "getDevice(): not connected to device", message: nil, details: nil))
                return nil
            }
        }
        return device
    }

    private func getDevice(_ args: [String: Any], checkConnection: Bool = true) -> BleDevice? {

        guard let deviceID = args["deviceId"] as? String else {
            self.streamHandler.eventSink?(["status": "error", "description": "getDevice(): deviceId required"])
            return nil
        }
        guard let device = self.bleDeviceMap[deviceID] else {
            self.streamHandler.eventSink?(["status": "error", "description": "getDevice(): device not found"])
            return nil
        }
        if checkConnection {
            guard device.isConnected() else {
                self.streamHandler.eventSink?(["status": "error", "description": "getDevice(): not connected to device"])
                return nil
            }
        }
        return device
    }

    private func getCharacteristic(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> (CBUUID, CBUUID)? {

        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return nil
        }

        guard let service = optionsSwift["service"] as? String else {
            result(FlutterError(code: "getCharacteristic(): service UUID required", message: nil, details: nil))
            return nil
        }

        let serviceUUID = CBUUID(string: service)

        guard let characteristic = optionsSwift["characteristic"] as? String else {
            result(FlutterError(code: "getCharacteristic(): characteristic UUID required", message: nil, details: nil))
            return nil
        }

        let characteristicUUID = CBUUID(string: characteristic)
        return (serviceUUID, characteristicUUID)
    }

    private func getCharacteristic(_ args: [String: Any]) -> (CBUUID, CBUUID)? {

        guard let service = args["service"] as? String else {
            self.streamHandler.eventSink?(["status": "error", "description": "getCharacteristic(): service UUID required"])
            return nil
        }

        let serviceUUID = CBUUID(string: service)

        guard let characteristic = args["characteristic"] as? String else {
            self.streamHandler.eventSink?(["status": "error", "description": "getCharacteristic(): characteristic UUID required"])
            return nil
        }

        let characteristicUUID = CBUUID(string: characteristic)
        return (serviceUUID, characteristicUUID)
    }

    private func getBleDeviceDict(_ device: BleDevice) -> [String: String] {
        var bleDevice = [
            "deviceId": device.getAddress()
        ]
        if device.getName() != nil {
            bleDevice["name"] = device.getName()
        }
        return bleDevice
    }

    private func getAdvertismentData(
        _ device: BleDevice
    ) -> [String: Any?] {
        var bleDeviceData: [String: Any?] = [
            "deviceId": device.getAddress(),
            "name": device.getName(),
            "raw": device.advertisementData?.rawData
        ]

        var advertismentData: [String: Any?] = [
            "rssi": device.advertisementData?.rssi
        ]
        if let isConnectable = device.advertisementData?.isConnectable {
            advertismentData["isConnectable"] = isConnectable
        }

        guard let mfData = device.advertisementData?.manufacturerData else {
            bleDeviceData["advertisementData"] = advertismentData
            return bleDeviceData
        }

        let manufacturerData: [String: Any?] = [
            "companyIdentifier": mfData.companyIdentifier,
            "version": mfData.version,
            "mainFirmwareVersionMajor": mfData.mainFirmwareVersionMajor,
            "mainFirmwareVersionMinor": mfData.mainFirmwareVersionMinor,
            "mainFirmwareVersionPatch": mfData.mainFirmwareVersionPatch,
            "componentHAL": mfData.componentHAL,
            "batteryStatus": mfData.batteryStatus ? "battery-full" : "battery-empty",
            "mainConstructionMode": mfData.mainConstructionMode,
            "subConstructionMode": mfData.subConstructionMode,
            "isOnline": mfData.isOnline,
            "officeModeEnabled": mfData.officeModeEnabled,
            "twoFactorRequired": mfData.twoFactorRequired,
            "officeModeActive": mfData.officeModeActive,
            "identifier": mfData.identifier,
            "subFirmwareVersionMajor": mfData.subFirmwareVersionMajor,
            "subFirmwareVersionMinor": mfData.subFirmwareVersionMinor,
            "subFirmwareVersionPatch": mfData.subFirmwareVersionPatch,
            "subComponentIdentifier": mfData.subComponentIdentifier,
            "componentType": getComponentType(mfData.componentType)
        ]

        advertismentData["manufacturerData"] = manufacturerData
        bleDeviceData["advertisementData"] = advertismentData
        return bleDeviceData
    }

    private func getComponentType(_ componentType: UInt8) -> String {
        switch componentType {
        case 98:
            "escutcheon"
        case 100:
            "handle"
        case 105:
            "iobox"
        case 109:
            "emzy"
        case 119:
            "wallreader"
        case 122:
            "cylinder"
        default:
            "unkown"
        }
    }
}
