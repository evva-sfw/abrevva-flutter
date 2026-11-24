@testable import abrevva
import AbrevvaSDK
import Flutter
import Nimble
import Quick
import XCTest

/// Provides synchronized mutable state for callbacks captured by the legacy Quick example DSL.
/// Uses a lock to contain the DSL's nonisolated closure boundary under Swift 6 concurrency checking.
private final class CryptoTestState: @unchecked Sendable {
    private let lock = NSLock()
    private var storedCryptoModule: AbrevvaCrypto?
    private var storedResolved: Bool?
    private var storedCallbackCount = 0
    private var storedErrorCode: String?

    /// Crypto module created for the current Quick example.
    /// Access is synchronized across the legacy DSL's captured closures.
    var cryptoModule: AbrevvaCrypto? {
        get {
            self.lock.lock()
            defer { lock.unlock() }
            return self.storedCryptoModule
        }
        set {
            self.lock.lock()
            defer { lock.unlock() }
            self.storedCryptoModule = newValue
        }
    }

    /// Whether the current crypto operation completed successfully.
    /// Access is synchronized across the legacy DSL's captured closures.
    var resolved: Bool? {
        get {
            self.lock.lock()
            defer { lock.unlock() }
            return self.storedResolved
        }
        set {
            self.lock.lock()
            defer { lock.unlock() }
            self.storedResolved = newValue
        }
    }

    /// Number of Flutter callback results recorded for the current example.
    /// Reads are synchronized with callback writes.
    var callbackCount: Int {
        self.lock.lock()
        defer { lock.unlock() }
        return self.storedCallbackCount
    }

    /// Flutter error code recorded for the current example, if the result was an error.
    /// Reads are synchronized with callback writes.
    var errorCode: String? {
        self.lock.lock()
        defer { lock.unlock() }
        return self.storedErrorCode
    }

    /// Records one Flutter callback result for completion assertions.
    ///
    /// Updates the synchronized callback count and error code together.
    ///
    /// - parameter result: Value returned by the Flutter result callback.
    ///
    func recordResult(_ result: Any?) {
        self.lock.lock()
        defer { lock.unlock() }
        self.storedCallbackCount += 1
        self.storedErrorCode = (result as? FlutterError)?.code
    }

    /// Clears the recorded callback count and error before the next example.
    /// Called by Quick's setup hook to isolate completion assertions between examples.
    func resetCallbackResult() {
        self.lock.lock()
        defer { lock.unlock() }
        self.storedCallbackCount = 0
        self.storedErrorCode = nil
    }
}

final class AbrevvaCryptoTests: QuickSpec {
    override class func spec() {
        let state = CryptoTestState()

        beforeEach {
            state.cryptoModule = AbrevvaCrypto()
            state.resolved = nil
            state.resetCallbackResult()
        }

        describe("encrypt()") {
            it("should resolve if encryption succeds") {
                let options: [String: Any] = [
                    "key": "404142434445464748494a4b4c4d4e4f",
                    "iv": "10111213141516",
                    "adata": "0001020304050607",
                    "pt": "20212223",
                    "tagLength": 4,
                ]
                let call = FlutterMethodCall(methodName: "encrypt", arguments: options)

                state.cryptoModule?.encrypt(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }
                expect(state.resolved!).to(beTrue())
            }

            it("should reject if encryption fails") {
                let call = FlutterMethodCall(methodName: "encrypt", arguments: [:])

                state.cryptoModule?.encrypt(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }
                expect(state.resolved!).to(beFalse())
            }
        }

        describe("decrypt()") {
            it("should resolve if decryption succeds") {
                let options: [String: Any] = [
                    "key": "404142434445464748494a4b4c4d4e4f",
                    "iv": "10111213141516",
                    "adata": "0001020304050607",
                    "ct": "7162015b4dac255d",
                    "tagLength": 4,
                ]
                let call = FlutterMethodCall(methodName: "decrypt", arguments: options)

                state.cryptoModule?.decrypt(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }

                expect(state.resolved!).to(beTrue())
            }

            it("should reject if decryption fails") {
                let call = FlutterMethodCall(methodName: "decrypt", arguments: [:])

                state.cryptoModule?.decrypt(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }

                expect(state.resolved!).to(beFalse())
            }
        }

        describe("generateKeyPair()") {
            it("should resolve with two keys") {
                let call = FlutterMethodCall(methodName: "generateKeyPair", arguments: [:])

                state.cryptoModule!.generateKeyPair(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let pair = data as! [String: String]
                    expect(pair["privateKey"]).toNot(beNil())
                    expect(pair["publicKey"]).toNot(beNil())
                    state.resolved = true
                }

                expect(state.resolved!).to(beTrue())
            }
        }

        describe("computeSharedSecret") {
            it("should resolve with a valid shared secret") {
                let options: [String: Any] = [
                    "privateKey": "8Bg60DKpRt9QP/h1/rmWeRDgV84DCjNM8dfaqOPtvVc=",
                    "peerPublicKey": "dlhsz8pEjSywIDSm04cmZFv9Yxq1HPr5F597qG1zKOo=",
                ]
                let secret = "75a2ec9ed1dec71217026a24f553c91178d648957a805e88552c481b74aad56b"
                let call = FlutterMethodCall(methodName: "computeSharedSecret", arguments: options)

                state.cryptoModule!.computeSharedSecret(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as? [String: String]
                    expect(dataMap?["sharedSecret"]).to(equal(secret))
                    state.resolved = true
                }

                expect(state.resolved!).to(beTrue())
            }
            it("should return nil if secret cannot be computed") {
                let options: [String: Any] = [
                    "key": "InvalidKey",
                    "peerPublicKey": "dlhsz8pEjSywIDSm04cmZFv9Yxq1HPr5F597qG1zKOo=",
                ]
                let call = FlutterMethodCall(methodName: "computeSharedSecret", arguments: options)

                state.cryptoModule!.computeSharedSecret(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: Any]
                    expect(dataMap["sharedSecret"]).to(beNil())
                    state.resolved = true
                }

                expect(state.resolved!).to(beFalse())
            }
        }

        describe("encryptFile") {
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let directoryPath = docDir.first!.path + "/aes_gcm_test"

            beforeEach {
                print("DOCDIR: \(directoryPath)")
                try? FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false)
            }
            afterEach {
                try? FileManager.default.removeItem(atPath: directoryPath)
            }
            it("should resolve if encryption worked") {
                print("Test starts")
                let options: [String: String] = [
                    "sharedSecret": "feffe9928665731c6d6a8f9467308308",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct",
                ]
                let pt = "feedfacedeadbeeffeedfacedeadbeef"
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                FileManager.default.createFile(atPath: "\(directoryPath)/pt", contents: Data(hex: pt))
                state.cryptoModule!.encryptFile(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }

                expect(state.resolved!).to(beTrue())
            }
            it("should reject if encryption failed") {
                let options: [String: String] = [
                    "sharedSecret": "",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct",
                ]
                let pt = "feedfacedeadbeeffeedfacedeadbeef"
                FileManager.default.createFile(atPath: "\(directoryPath)/pt", contents: Data(hex: pt))
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)

                state.cryptoModule!.encryptFile(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }
                expect(state.resolved!).to(beFalse())
            }
        }

        describe("decryptFileFromURL") {
            it("should report invalid arguments exactly once") {
                let call = FlutterMethodCall(methodName: "decryptFileFromURL", arguments: [:])

                state.cryptoModule!.decryptFileFromURL(call) { result in
                    state.recordResult(result)
                }

                expect(state.callbackCount).to(equal(1))
                expect(state.errorCode).to(equal("DecryptFileFromURLInvalidArgumentError"))
            }
        }

        describe("decryptFile") {
            let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let directoryPath = docDir.first!.path + "/aes_gcm_test"

            beforeEach {
                try! FileManager.default.createDirectory(atPath: directoryPath, withIntermediateDirectories: false)
            }
            afterEach {
                try! FileManager.default.removeItem(atPath: directoryPath)
            }
            it("should resolve if decryption worked") {
                let options: [String: String] = [
                    "sharedSecret": "feffe9928665731c6d6a8f9467308308",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct",
                ]
                let ct =
                    "017d4aacf0a0f987d697d09c885aa9513aed2a25a1e87252038f0f7a3955b11dec43d9d7669e9910c527ee4eec719edb387ee63f8e0c2d7dcf7678fe58"
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                FileManager.default.createFile(atPath: "\(directoryPath)/ct", contents: Data(hex: ct))

                state.cryptoModule!.decryptFile(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }
                expect(state.resolved!).to(beTrue())
            }
            it("should reject if decryption failed") {
                let options: NSDictionary = [
                    "sharedSecret": "",
                    "ptPath": "\(directoryPath)/pt",
                    "ctPath": "\(directoryPath)/ct",
                ]
                let ct =
                    "017d4aacf0a0f987d697d09c885aa9513aed2a25a1e87252038f0f7a3955b11dec43d9d7669e9910c527ee4eec719edb387ee63f8e0c2d7dcf7678fe58"
                let call = FlutterMethodCall(methodName: "encryptFile", arguments: options)
                FileManager.default.createFile(atPath: "\(directoryPath)/ct", contents: Data(hex: ct))

                state.cryptoModule!.decryptFile(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    state.resolved = true
                }
                expect(state.resolved!).to(beFalse())
            }
        }

        describe("random()") {
            it("should return n random byte") {
                let options: NSDictionary = ["numBytes": 4]
                let call = FlutterMethodCall(methodName: "random", arguments: options)

                state.cryptoModule!.random(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: String?]
                    expect((dataMap["value"]!!).count).to(equal(8))
                    state.resolved = true
                }
                expect(state.resolved!).to(beTrue())
            }
        }

        describe("derive()") {
            it("should return a correctly derived key") {
                let options: NSDictionary = [
                    "key": "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b",
                    "salt": "000102030405060708090a0b0c",
                    "info": "f0f1f2f3f4f5f6f7f8f9",
                    "length": 42,
                ]
                let call = FlutterMethodCall(methodName: "derive", arguments: options)

                state.cryptoModule!.derive(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: String?]
                    let derivedKey =
                        "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865"
                    expect((dataMap["value"]!!)).to(equal(derivedKey))
                    state.resolved = true
                }
                expect(state.resolved!).to(beTrue())
            }
            it("should reject on failed derivation") {
                let options: NSDictionary = [
                    "key": "invalidKey",
                    "salt": "000102030405060708090a0b0c",
                    "info": "f0f1f2f3f4f5f6f7f8f9",
                    "length": 42,
                ]
                let call = FlutterMethodCall(methodName: "derive", arguments: options)

                state.cryptoModule!.derive(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: String?]
                    let derivedKey =
                        "3cb25f25faacd57a90434f64d0362f2a2d2d0a90cf1a5a4c5db02d56ecc4c5bf34007208d5b887185865"
                    expect((dataMap["value"]!!)).to(equal(derivedKey))
                }
                expect(state.resolved!).to(beFalse())
            }
        }

        describe("sign()") {
            it("should create a signature") {
                let options: NSDictionary = [
                    "privateKey": "8Bg60DKpRt9QP/h1/rmWeRDgV84DCjNM8dfaqOPtvVc=",
                    "data": "data",
                ]
                let call = FlutterMethodCall(methodName: "sign", arguments: options)

                state.cryptoModule!.sign(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: String?]

                    expect(dataMap["signature"]).toNot(beNil())
                    state.resolved = true
                }
                expect(state.resolved!).to(beTrue())
            }
            it("should reject on failed signature") {
                let options: NSDictionary = [
                    "privateKey": "00000",
                    "data": "data",
                ]
                let call = FlutterMethodCall(methodName: "sign", arguments: options)

                state.cryptoModule!.sign(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: String?]

                    expect(dataMap["signature"]).toNot(beNil())
                    state.resolved = true
                }
                expect(state.resolved!).to(beFalse())
            }
        }

        describe("verify()") {
            it("should succeed if the signature is valid") {
                var options: NSDictionary = [
                    "privateKey": "8Bg60DKpRt9QP/h1/rmWeRDgV84DCjNM8dfaqOPtvVc=",
                    "data": "data",
                ]
                var signature = ""
                var call = FlutterMethodCall(methodName: "sign", arguments: options)
                state.cryptoModule!.sign(call) { data in
                    let dataMap = data as! [String: String?]
                    signature = dataMap["signature"]!!
                }

                options = [
                    "publicKey": "dlhsz8pEjSywIDSm04cmZFv9Yxq1HPr5F597qG1zKOo=",
                    "data": "data",
                    "signature": signature,
                ]
                call = FlutterMethodCall(methodName: "verify", arguments: options)

                state.cryptoModule!.verify(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                    let dataMap = data as! [String: Bool]

                    expect(dataMap["opOk"]).to(beTrue())
                    state.resolved = true
                }
                expect(state.resolved!).to(beTrue())
            }

            it("should fail if the signature is invalid") {
                var options: NSDictionary = [
                    "privateKey": "8Bg60DKpRt9QP/h1/rmWeRDgV84DCjNM8dfaqOPtvVc=",
                    "data": "data",
                ]
                var signature = ""
                var call = FlutterMethodCall(methodName: "sign", arguments: options)
                state.cryptoModule!.sign(call) { data in
                    let dataMap = data as! [String: String?]
                    signature = dataMap["signature"]!!
                }

                options = [
                    "publicKey": "dlhsz8pEjSywIDSm04cmZFv9Yxq1HPr5F597qG1zKOo=",
                    "data": "data123",
                    "signature": signature,
                ]
                call = FlutterMethodCall(methodName: "verify", arguments: options)

                state.cryptoModule!.verify(call) { data in
                    if (data as? FlutterError) != nil {
                        state.resolved = false
                        return
                    }
                }
                expect(state.resolved!).to(beFalse())
            }
        }

        describe("computeED25519PublicKey()") {
            it("should compute a valid public key") {
                let options: NSDictionary = [
                    "privateKey": "8Bg60DKpRt9QP/h1/rmWeRDgV84DCjNM8dfaqOPtvVc=",
                ]
                let call = FlutterMethodCall(methodName: "computeED25519PublicKey", arguments: options)
                var publicKey: String?

                state.cryptoModule!.computeED25519PublicKey(call) { data in
                    let dataMap = data as! [String: String?]
                    publicKey = dataMap["publicKey"] as? String
                }
                expect(publicKey).toNot(beNil())
            }
        }
    }
}
