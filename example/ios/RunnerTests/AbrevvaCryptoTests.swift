import XCTest
import Quick
import Nimble
import AbrevvaSDK
import Flutter

@testable import abrevva

final class AbrevvaCryptoTests: QuickSpec {
    override class func spec(){
        var cryptoModule: AbrevvaCrypto?
        var resolved: Bool? = nil
        beforeEach {
            cryptoModule = AbrevvaCrypto()
            resolved = nil
        }
        
        describe("encrypt()"){
            it("should resolve if encryption succeds"){
                let options: Dictionary<String, Any> = [
                    "key": "404142434445464748494a4b4c4d4e4f",
                    "iv": "10111213141516",
                    "adata": "0001020304050607",
                    "pt": "20212223",
                    "tagLength": 4,
                ]
                let call = FlutterMethodCall(methodName: "encrypt", arguments: options)
                
                cryptoModule?.encrypt(call) {data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                expect(resolved!).to(beTrue())
            }
            
            it("should reject if encryption fails"){
                let call = FlutterMethodCall(methodName: "encrypt", arguments: [:])
                
                cryptoModule?.encrypt(call) {data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                expect(resolved!).to(beFalse())
            }
        }
        describe("decrypt()"){
            it("should resolve if decryption succeds"){
                let options: Dictionary<String, Any> = [
                    "key": "404142434445464748494a4b4c4d4e4f",
                    "iv": "10111213141516",
                    "adata": "0001020304050607",
                    "ct": "7162015b4dac255d",
                    "tagLength": 4,
                ]
                let call = FlutterMethodCall(methodName: "decrypt", arguments: options)
                
                cryptoModule?.decrypt(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                
                expect(resolved!).to(beTrue())
            }
            
            it("should reject if decryption fails"){
                let call = FlutterMethodCall(methodName: "decrypt", arguments: [:])
                
                cryptoModule?.decrypt(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                
                expect(resolved!).to(beFalse())
            }
        }
        describe("generateKeyPair()"){
            it("should resolve with two keys"){
                
                cryptoModule!.generateKeyPair { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    let pair = data as! [String:String]
                    expect(pair["privateKey"]).toNot(beNil())
                    expect(pair["publicKey"]).toNot(beNil())
                    resolved = true
                }
                
                expect(resolved!).to(beTrue())
            }
        }
        describe("computeSharedSecret"){
            it("should resolve with a valid shared secret"){
                let options: Dictionary<String, Any> = [
                    "privateKey": "0468f4f0ec2f08c558246a866ce477d903fa577373f8622e1aa2e64e2e2c456d",
                    "peerPublicKey": "f764ef9667497e7bcb4cdbeb0bf86462638cf65637569a65a8b5ed23b9a79621"
                ]
                let secret = "34b78ecc79b605c85e0d995f8143990ffcee19b276fa55418c5232915c43af2c"
                let call = FlutterMethodCall(methodName: "computeSharedSecret", arguments: options)
                
                cryptoModule!.computeSharedSecret(call){ data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    let dataMap = data as? [String: String]
                    expect(dataMap?["sharedSecret"]).to(equal(secret))
                    resolved = true
                }
                
                expect(resolved!).to(beTrue())
            }
            it("should return nil if secret cannot be computed"){
                let options: Dictionary<String, Any> = [
                    "key": "InvalidKey",
                    "peerPublicKey": "f764ef9667497e7bcb4cdbeb0bf86462638cf65637569a65a8b5ed23b9a79621"
                ]
                let call = FlutterMethodCall(methodName: "computeSharedSecret", arguments: options)
                
                cryptoModule!.computeSharedSecret(call){ data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    let dataMap = data as! [String: Any]
                    expect(dataMap["sharedSecret"]).to(beNil())
                    resolved = true
                }
                
                expect(resolved!).to(beTrue())
            }
        }
        describe("encryptFile"){
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let directoryPath = docDir.first!.path + "/aes_gcm_test"

            beforeEach {

                print("DOCDIR: \(directoryPath)")
                try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false)
            }
            afterEach {
                try? FileManager.default.removeItem(atPath: directoryPath)
                
            }
            it("should resolve if encryption worked"){
                print("Test starts")
                let options: [String : String] = [
                    "sharedSecret": "feffe9928665731c6d6a8f9467308308",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct"
                ]
                let pt = "feedfacedeadbeeffeedfacedeadbeef"
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                FileManager.default.createFile(atPath: "\(directoryPath)/pt", contents: Data(hex: pt))
                cryptoModule!.encryptFile(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                         return
                    }
                    resolved = true
                }
                
                expect(resolved!).to(beTrue())
            }
            it("should reject if encryption failed"){
                let options: [String : String] = [
                    "sharedSecret": "",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct"
                ]
                let pt = "feedfacedeadbeeffeedfacedeadbeef"
                FileManager.default.createFile(atPath: "\(directoryPath)/pt", contents: Data(hex: pt))
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                
                cryptoModule!.encryptFile(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                expect(resolved!).to(beFalse())
            }
        }
        describe("decryptFile"){
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let directoryPath = docDir.first!.path + "/aes_gcm_test"
            
            beforeEach {
                try! FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false)
            }
            afterEach {
                try! FileManager.default.removeItem(atPath: directoryPath)
            }
            it("should resolve if decryption worked"){
                let options: [String : String] = [
                    "sharedSecret": "feffe9928665731c6d6a8f9467308308",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct"
                ]
                let ct = "017d4aacf0a0f987d697d09c885aa9513aed2a25a1e87252038f0f7a3955b11dec43d9d7669e9910c527ee4eec719edb387ee63f8e0c2d7dcf7678fe58"
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                FileManager.default.createFile(atPath: "\(directoryPath)/ct", contents: Data(hex: ct))
                
                cryptoModule!.decryptFile(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                expect(resolved!).to(beTrue())
            }
            it("should reject if decryption failed"){
                let options: NSDictionary = [
                    "sharedSecret": "",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct"
                ]
                let ct = "017d4aacf0a0f987d697d09c885aa9513aed2a25a1e87252038f0f7a3955b11dec43d9d7669e9910c527ee4eec719edb387ee63f8e0c2d7dcf7678fe58"
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                FileManager.default.createFile(atPath: "\(directoryPath)/ct", contents: Data(hex: ct))
                
                cryptoModule!.decryptFile(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    resolved = true
                }
                expect(resolved!).to(beFalse())
            }
        }
        describe("random()"){
            it("should return n random byte"){
                let options: NSDictionary = ["numBytes" : 4]
                let call = FlutterMethodCall(methodName: "random", arguments: options)
                
                cryptoModule!.random(call) { data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    let dataMap = data as! [String:String?]
                    expect((dataMap["value"]!!).count).to(equal(8))
                    resolved = true
                }
                expect(resolved!).to(beTrue())
            }
        }
        describe("derive()"){
            it("should return a correctly derived key"){
                let options: NSDictionary = [
                    "key": "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b",
                    "salt": "000102030405060708090a0b0c",
                    "info": "f0f1f2f3f4f5f6f7f8f9",
                    "length": 42,
                ]
                let call = FlutterMethodCall(methodName: "derive", arguments: options)
                
                cryptoModule!.derive(call){ data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    let dataMap = data as! [String:String?]
                    let derivedKey = "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865"
                    expect((dataMap["value"]!!)).to(equal(derivedKey))
                    resolved = true
                }
                expect(resolved!).to(beTrue())
                
            }
            it("should reject on failed derivation"){
                let options: NSDictionary = [
                    "key": "invalidKey",
                    "salt": "000102030405060708090a0b0c",
                    "info": "f0f1f2f3f4f5f6f7f8f9",
                    "length": 42,
                ]
                let call = FlutterMethodCall(methodName: "derive", arguments: options)
                
                cryptoModule!.derive(call){ data in
                    if ((data as? FlutterError) != nil){
                        resolved = false
                        return
                    }
                    let dataMap = data as! [String:String?]
                    let derivedKey = "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865"
                    expect((dataMap["value"]!!)).to(equal(derivedKey))
                }
                expect(resolved!).to(beFalse())
            }
        }
    }
}

