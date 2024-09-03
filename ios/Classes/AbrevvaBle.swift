import Flutter
import Foundation
import AbrevvaSDK
import CoreBluetooth

public class AbrevvaBle: NSObject, FlutterPlugin, FlutterStreamHandler {
    
    private var eventSink: FlutterEventSink? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
    }
    
    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        
        guard let args = arguments as? Dictionary<String, Any> else {
            events(["status": "error", "description": "Invalid args"])
            return nil
        }
        switch args["callbackName"] as? String {
            case "requestLEScan":
                requestLEScan(args)
            case "onEnabledChanged":
                startEnabledNotifications()
            case "startNotifications":
                startNotifications(args)
            default:
                events(["status": "error", "description": "Method not implemented"])
        }
        return nil
    }
    
    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
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
        case "stopLEScan":
            stopLEScan(call, result: result)
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
        case "stopNotifications":
            stopNotifications(call, result: result)
        case "signalize":
            signalize(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private var bleManager: BleManager?
    private var bleDeviceMap = [String: BleDevice]()

    @objc
    func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.bleManager = BleManager { success, message in
            if success {
                result(["status": "success"])
            } else {
                result(FlutterError(code: message!, message: nil, details: nil))
            }
        }
    }

    @objc
    func isEnabled(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        let enabled: Bool = bleManager.isBleEnabled()
        result(["value": enabled])
    }

    @objc
    func isLocationEnabled(_ result: @escaping FlutterResult) {
        result(FlutterError(code: "isLocationEnabled(): not available on iOS", message: nil,details: nil))
    }

    @objc
    func startEnabledNotifications() {
        guard let bleManager = self.getBleManager() else { return }
        bleManager.registerStateReceiver { enabled in
            self.eventSink?(["value": enabled])
        }
    }

    @objc
    func stopEnabledNotifications(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let bleManager = self.getBleManager(result) else { return }
        bleManager.unregisterStateReceiver()
        result("success")
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
                UIApplication.shared.open(settingsURL, completionHandler: { success in
                    result([
                        "value": success,
                    ])
                })
            } else {
                result(FlutterError(code: "openAppSettings(): cannot open app settings", message: nil, details: nil))
            }
        }
    }

    @objc
    func requestLEScan(_ args: Dictionary< String, Any>) {
        guard let bleManager = self.getBleManager() else { return }
        let name = args["name"] as? String ?? nil
        let namePrefix = args["namePrefix"] as? String ?? nil
        let allowDuplicates = args["allowDuplicates"] as? Bool ?? false
        let timeout =   args["timeout"] as? Int ?? 10000

        bleManager.startScan(
            name,
            namePrefix,
            allowDuplicates,
            { success in
                if success {
                    self.eventSink?(nil)
                } else {
                    self.eventSink?(["status": "error", "description" : "requestLEScan(): failed to start"])
                }
            }, { device, advertisementData, rssi in
                self.bleDeviceMap[device.getAddress()] = device
                let data = self.getScanResultDict(device, advertisementData, rssi)
                self.eventSink?(data)
            },{ address in
                self.eventSink?(["status": "connected", "address" : address])
            },{address in 
                self.eventSink?(["status": "disconnected", "address" : address])
            },
            timeout
        )
    }

    @objc
    func stopLEScan(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
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
        
        let timeout = optionsSwift["timeout"] as? Int ?? nil

        Task {
            let success = await self.bleManager!.connect(device, timeout)
            if success {
                result(["status": "success"])
            } else {
                result(FlutterError(code: "connect(): failed to connect to device", message: nil, details: nil))
            }
        }
    }

    @objc
    func disconnect(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard self.getBleManager(result) != nil else { return }
        guard let device = self.getDevice(call, result: result, checkConnection: false) else { return }

        Task {
            let success = await self.bleManager!.disconnect(device)
            if success {
                result("success")
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
                result(["value": [UInt8](data!)]);
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
                result(["status": "success"])
            } else {
                result(FlutterError(code: "write(): failed to write data", message: nil, details: nil))
            }
        }
    }

    @objc
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
        let timeout = optionsSwift["timeout"] as? Int ?? nil

        Task {
            let status = await self.bleManager!.disengage(
                device,
                mobileID,
                mobileDeviceKey,
                mobileGroupID,
                mobileAccessData,
                isPermanentRelease,
                timeout
            )
            result(["value": status.rawValue])
        }
    }

    @objc
    func startNotifications(_ args: Dictionary< String, Any>) {
        guard self.getBleManager() != nil else { return }
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
                        self.eventSink?([key : ["value": dataToString(value!)]])
                    } else {
                        self.eventSink?(["status": "error", "description": "error in setNotifications()"])
                    }
                }
            }, timeout)
            DispatchQueue.main.async {
                
                if success {
                    self.eventSink?(["status": "success"])
                } else {
                    self.eventSink?(["status": "error", "description":  "startNotifications(): failed to start notifications"])
                }
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
                result("success")
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
            _ = await bleManager.signalize(device)
            result("success")
        }
    }

    private func getBleManager(_ result: @escaping FlutterResult) -> BleManager? {
        guard let bleManager = self.bleManager else {
            result(FlutterError(code: "getBleManager(): not initialized", message: nil, details: nil))
            return nil
        }
        return bleManager
    }
    
    private func getBleManager() -> BleManager? {
        guard let bleManager = self.bleManager else {
            eventSink?(["status": "error", "description" : "getBleManager(): not initialized"])
            return nil
        }
        return bleManager
    }


    private func getServiceUUIDs(_ call: FlutterMethodCall, result: @escaping FlutterResult) -> [CBUUID]? {
        guard let optionsSwift = call.arguments as? [String: Any] else {
            result(FlutterError(code: "Failed to convert NSDictionary to Swift dictionary", message: nil, details: nil))
            return nil
        }
        let services = optionsSwift["services"] as? [String] ?? [] // TODO: Check if works as intended
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
    
    private func getDevice(_ args: Dictionary< String, Any>, checkConnection: Bool = true) -> BleDevice? {
        
        guard let deviceID = args["deviceId"] as? String else {
            self.eventSink?(["status": "error", "description": "getDevice(): deviceId required"])
            return nil
        }
        guard let device = self.bleDeviceMap[deviceID] else {
            self.eventSink?(["status": "error", "description": "getDevice(): device not found"])
            return nil
        }
        if checkConnection {
            guard device.isConnected() else {
                self.eventSink?(["status": "error", "description": "getDevice(): not connected to device"])
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
    
    private func getCharacteristic(_ args: Dictionary< String, Any>) -> (CBUUID, CBUUID)? {
        
        guard let service = args["service"] as? String else {
            self.eventSink?(["status": "error", "description" : "getCharacteristic(): service UUID required"])
            return nil
        }
        
        let serviceUUID = CBUUID(string: service)

        guard let characteristic = args["characteristic"] as? String else {
            self.eventSink?(["status": "error", "description" : "getCharacteristic(): characteristic UUID required"])
            return nil
        }
        
        let characteristicUUID = CBUUID(string: characteristic)
        return (serviceUUID, characteristicUUID)
    }

    private func getBleDeviceDict(_ device: BleDevice) -> [String: String] {
        var bleDevice = [
            "deviceId": device.getAddress(),
        ]
        if device.getName() != nil {
            bleDevice["name"] = device.getName()
        }
        return bleDevice
    }

    func getScanResultDict(
        _ device: BleDevice,
        _ advertisementData: [String: Any],
        _ rssi: NSNumber
    ) -> [String: Any] {
        
        var uuidMap = (advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] ?? []).map { uuid -> String in
            return CBUUIDToString(uuid)
        }
        
        var data = [
            "device": self.getBleDeviceDict(device),
            "rssi": rssi,
            "txPower": advertisementData[CBAdvertisementDataTxPowerLevelKey] ?? 127,
            "uuids":uuidMap.joined(separator: ":") ,
        ]

        let localName = advertisementData[CBAdvertisementDataLocalNameKey] as? String
        if localName != nil {
            data["localName"] = localName
        }

        let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        if manufacturerData != nil {
            data["manufacturerData"] = self.getManufacturerDataDict(data: manufacturerData!)
        }

        let serviceData = advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
        if serviceData != nil {
            data["serviceData"] = self.getServiceDataDict(data: serviceData!)
        }
        return data
    }

    func getManufacturerDataDict(data: Data) -> [String: String] {
        var company = 0
        var rest = ""
        for (index, byte) in data.enumerated() {
            if index == 0 {
                company += Int(byte)
            } else if index == 1 {
                company += Int(byte) * 256
            } else {
                rest += String(format: "%02hhx ", byte)
            }
        }
        return [String(company): rest]
    }

    func getServiceDataDict(data: [CBUUID: Data]) -> [String: String] {
        var result: [String: String] = [:]
        for (key, value) in data {
            result[CBUUIDToString(key)] = dataToString(value)
        }
        return result
    }
}
