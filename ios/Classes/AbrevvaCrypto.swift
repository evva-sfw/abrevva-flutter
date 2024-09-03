import Flutter
import UIKit
import AbrevvaSDK

public class AbrevvaCrypto: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "AbrevvaCrypto", binaryMessenger: registrar.messenger())
    let instance = AbrevvaCrypto()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "encrypt":
        encrypt(call, result: result)
    case "decrypt":
        decrypt(call, result: result)
    case "generateKeyPair":
        generateKeyPair(result)
    case "computeSharedSecret":
        computeSharedSecret(call, result: result)
    case "encryptFile":
        encryptFile(call, result: result)
    case "decryptFile":
        decryptFile(call, result: result)
    case "decryptFileFromURL":
        decryptFileFromURL(call, result: result)
    case "random":
        random(call, result: result)
    case "derive":
        derive(call, result: result)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

    private let X25519Impl = X25519()
    private let AesGcmImpl = AesGcm()
    private let AesCcmImpl = AesCcm()
    private let SimpleSecureRandomImpl = SimpleSecureRandom()
    private let HKDFImpl = HKDFWrapper()

    @objc
    func encrypt(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let key = (args["key"] ?? "") as? String,
           let iv = (args["iv"] ?? "") as? String,
           let adata = (args["adata"] ?? "") as? String,
           let pt = (args["pt"] ?? "") as? String,
           let tagLength = (args["tagLength"] ?? 0) as? Int {
            
            let keyHex = [UInt8](hex: "0x" + key)
            let ivHex = [UInt8](hex: "0x" + iv)
            let adataHex = [UInt8](hex: "0x" + adata)
            let ptHex = [UInt8](hex: "0x" + pt)
            
            let ct = self.AesCcmImpl.encrypt(key: keyHex, iv: ivHex, adata: adataHex, pt: ptHex, tagLength: tagLength)
            if (ct.isEmpty) {
                result(FlutterError(code: "encrypt(): encrypt failed", message: nil, details: nil))
            }
            else {
                result([
                    "cipherText": [UInt8](ct[..<pt.count]).toHexString(),
                    "authTag": [UInt8](ct[pt.count...]).toHexString(),
                ])
            }
        }
    }

    @objc
    func decrypt(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let key = (args["key"] ?? "") as? String,
           let iv = (args["iv"] ?? "") as? String,
           let adata = (args["adata"] ?? "") as? String,
           let ct = (args["ct"] ?? "") as? String,
           let tagLength = (args["tagLength"] ?? 0) as? Int {
            
            let keyHex = [UInt8](hex: "0x" + key)
            let ivHex = [UInt8](hex: "0x" + iv)
            let adataHex = [UInt8](hex: "0x" + adata)
            let ctHex = [UInt8](hex: "0x" + ct)
            
            let pt = self.AesCcmImpl.decrypt(key: keyHex, iv: ivHex, adata: adataHex, ct: ctHex, tagLength: tagLength).toHexString()
            if pt.isEmpty {
                result(FlutterError(code: "decrypt(): decryption failed", message: nil, details: nil))
            } else {
                result([
                    "plainText": pt,
                    "authOk": true,
                ])
            }
        }
    }
    
    @objc
    func generateKeyPair(_ result: @escaping FlutterResult) {
        let keyPair = self.X25519Impl.generateKeyPair()
        result(["privateKey": keyPair[0].toHexString(), "publicKey":keyPair[1].toHexString()])

    }

    @objc
    func computeSharedSecret(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any> {
            let privateKeyData = Data(hex: "0x" + ((args["privateKey"] ?? "") as! String))
            let publicKeyData = Data(hex: "0x" + ((args["peerPublicKey"] ?? "") as! String))
            print("privateKey: \((args["privateKey"] ?? ""))")
            print("publicKey: \((args["peerPublicKey"] ?? ""))")
            let sharedSecret = self.X25519Impl.computeSharedSecret(
                privateKeyData: privateKeyData,
                publicKeyData: publicKeyData
            )
            result([
                "sharedSecret": sharedSecret?.toHexString(),
            ])
        }
    }

    @objc
    func encryptFile(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let sharedSecret = (args["sharedSecret"] ?? "") as? String,
           let ptPath = (args["ptPath"] ?? "") as? String,
           let ctPath = (args["ctPath"] ?? "") as? String {
            let sharedSecretHex = [UInt8](hex: "0x" + sharedSecret)
            let operationResult = self.AesGcmImpl.encryptFile(key: sharedSecretHex, pathPt: ptPath, pathCt: ctPath)
            if operationResult == false {
                result(FlutterError(code: "encryptFile(): encryption failed", message: nil, details: nil))
            } else {
                result([
                    "opOk": operationResult,
                ])
            }
        }
    }

    @objc
    func decryptFile(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let ctPath = (args["ctPath"] ?? "") as? String,
           let ptPath = (args["ptPath"] ?? "") as? String,
           let sharedSecret = (args["sharedSecret"] ?? "") as? String{
            
            let sharedSecretHex = [UInt8](hex: "0x" + sharedSecret)
        
            let url = URL(fileURLWithPath: ctPath)
            
            let data: Data
            do {
                data = try Data(contentsOf: url, options: .mappedIfSafe)
            } catch {
                return result(FlutterError(code: "decryptFile(): failed to load data from file", message: nil, details: nil))
            }
            
            let operationResult = self.AesGcmImpl.decryptFile(key: sharedSecretHex, data: data, pathPt: ptPath)
            if operationResult == false {
                result(FlutterError(code: "decryptFile(): encryption has failed", message: nil, details: nil))
            } else {
                result([
                    "opOk": operationResult,
                ])
            }
        }
    }

    @objc
    func decryptFileFromURL(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let sharedSecret = (args["sharedSecret"] ?? "") as? String,
           let ptPath = (args["ptPath"] ?? "") as? String,
           let urlStr = (args["url"] ?? "") as? String {
            
            let sharedSecretHex = [UInt8](hex: "0x" + sharedSecret)
            let url = URL(string: urlStr)
            let data: Data
            
            do {
                data = try Data(contentsOf: url!)
            } catch {
                return result(FlutterError(code: "decryptFileFromURL(): failed to load data", message: nil, details: nil))
            }
            
            let operationResult = self.AesGcmImpl.decryptFile(key: sharedSecretHex, data: data, pathPt: ptPath)
            if operationResult == false {
                return result(FlutterError(code: "decryptFileFromURL(): decryption has failed", message: nil, details: nil))
            } else {
                result([
                    "opOk": operationResult,
                ])
            }
        }
    }

    @objc
    func random(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
        let args = call.arguments as? Dictionary<String, Any>
        let numBytes = (args?["numBytes"] ?? 0) as! Int
            
        let rnd = self.SimpleSecureRandomImpl.random(numBytes).toHexString()

        if rnd.isEmpty {
            result("random(): random generation failed")
        } else {
            result([
                "value": rnd,
            ])
        }
    }

    @objc
    func derive(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? Dictionary<String, Any>,
           let key = (args["key"] ?? "") as? String,
           let salt = (args["salt"] ?? "") as? String,
           let info = (args["info"] ?? "") as? String,
           let length = (args["length"] ?? 0) as? Int {
            
            
            let keyHex = [UInt8](hex: "0x" + key)
            let saltHex = [UInt8](hex: "0x" + salt)
            let infoHex = [UInt8](hex: "0x" + info)
            
            let derived = self.HKDFImpl.derive(key: keyHex, salt: saltHex, info: infoHex, length: length).toHexString()
            if derived.isEmpty {
                return result(FlutterError(code: "derive(): derivation failed", message: nil, details: nil))
            } else {
                result([
                    "value": derived,
                ])
            }
        }
    }
}
