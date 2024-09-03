import Flutter
import Foundation
import AbrevvaSDK
import CocoaMQTT
import CoreNFC

public class AbrevvaNfc: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "AbrevvaNfc", binaryMessenger: registrar.messenger())
        let instance = AbrevvaNfc()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "connect":
            connect()
        case "disconnect":
            disconnect()
        case "read":
            read()
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    let HOST =  "172.16.2.91" 
    let PORT: UInt16 = 1883
    let CLIENTID: String = "96380897-0eee-479e-80c3-84c0dde286cd"
    
    var clientID: String = ""
    
    private var mqtt5Client: MQTT5Client?
    private var nfcSession = NFCSession()
    
    @objc func connect() {
        var clientCertArray = getClientCertFromP12File(certName: "client-ios.p12", certPassword: "123")
        self.clientID = CLIENTID
        
        mqtt5Client = MQTT5Client(clientID: clientID, host: HOST, port: PORT, clientCertArray:clientCertArray)
        mqtt5Client?.setOnMessageRecieveHandler(handler: onMessageRecieveHandler)
        mqtt5Client?.setDidStateChangeToHandler(handler: didStateChangeToHandler)
        mqtt5Client?.connect()

//        nfcSession.setPublishKyOnHandler(handler: mqtt5Client!.publishKyOn)
//        nfcSession.setPublishKeyOffHander(handler: mqtt5Client!.publishKyOff)
    }
    
    @objc func disconnect() {
        mqtt5Client?.disconnect()
    }
    
    @objc func read() {
        nfcSession.beginSession()
    }
    
    func getClientCertFromP12File(certName: String, certPassword: String) -> CFArray? {
        let DOCUMENT_DIR = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).path
        let resourcePath: String? = "\(DOCUMENT_DIR)/\(certName)"
        
        guard let filePath = resourcePath, let p12Data = NSData(contentsOfFile: filePath) else {
            print("Failed to open the certificate file: \(certName)")
            return nil
        }
        
        // create key dictionary for reading p12 file
        let key = kSecImportExportPassphrase as String
        let options : NSDictionary = [key: certPassword]
        
        var items : CFArray?
        let securityError = SecPKCS12Import(p12Data, options, &items)
        guard securityError == errSecSuccess else {
            if securityError == errSecAuthFailed {
                print("ERROR: SecPKCS12Import returned errSecAuthFailed. Incorrect password?")
            } else  {
                print("ERROR SecPKCS12Import \(securityError)")
            }
            return nil
        }
        
        guard let theArray = items, CFArrayGetCount(theArray) > 0 else {
            return nil
        }
        
        let dictionary = (theArray as NSArray).object(at: 0)
        guard let identity = (dictionary as AnyObject).value(forKey: kSecImportItemIdentity as String) else {
            return nil
        }
        let certArray = [identity] as CFArray
        return certArray
    }
    
    public func onMessageRecieveHandler(message: CocoaMQTT5Message) {
        Task {
            if let resp = await self.nfcSession.send(apdu: NFCISO7816APDU(data: Data(message.payload))!) {
                var apduArr:[UInt8] = [UInt8](resp.0)
                apduArr.append(resp.1)
                apduArr.append(resp.2)
                print(apduArr)
                self.mqtt5Client?.publishMessage(topic: "readers/1/\(clientID)/f", payload: apduArr)
            }
        }
    }
    
    public func didStateChangeToHandler(state: CocoaMQTTConnState) {
        if state == .connected {
            self.mqtt5Client?.publishMessage(topic: "readers/1", message: Message(t: "cr", e: "on", oid: self.clientID, atr: nil))
            self.mqtt5Client?.subscribe(topics: [MqttSubscription.init(topic: "readers/1/\(clientID)/t")])

        }
        else if state == .disconnected {
            self.nfcSession.invalidateSession(message: "Connection to broker lost.")
        }
    }
    
    public func disconnectMqttClient() {
        self.mqtt5Client?.publishMessage(topic: "readers/1", message: Message(t: "cr", e: "off", oid: self.clientID, atr: nil))
        self.mqtt5Client?.disconnect()
        self.nfcSession.invalidateSession()
    }
    
}
