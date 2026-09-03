import Foundation
import AbrevvaSDK
import CryptoSwift
import Flutter

@MainActor
public class AbrevvaCodingStation: NSObject, @preconcurrency FlutterPlugin {

    private let codingStation = CodingStation()
    private var mqttConnectionOptions: MqttConnectionOptions?

    public static func register(with registrar: FlutterPluginRegistrar) {}

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "register":
            register(call, result: result)
        case "connect":
            connect(call, result: result)
        case "write":
            write(call, result: result)
        case "disconnect":
            disconnect(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    @objc
    private func register(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any] else {
            return result(FlutterError(
                            code: "register(): Failed to convert NSDictionary to Swift dictionary",
                            message: nil, details: nil)
            )
        }
        guard let url = URL(string: args["url"] as? String ?? "") else {
            return result(FlutterError(
                            code: "register(): failed to create URL",
                            message: nil, details: nil)
            )
        }
        let clientId = args["clientId"] as? String ?? ""
        let username = args["username"] as? String ?? ""
        let password = args["password"] as? String ?? ""

        Task {
            do {
                mqttConnectionOptions = try await AuthManager.getMqttConfigForXS(
                    url: url, clientId: clientId, username: username, password: password
                )
                result(true)
            } catch {
                result(FlutterError(code: "getMqttConfigForXS(): \(error)", message: nil, details: nil))
            }
        }
    }

    @objc
    private func connect(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if self.mqttConnectionOptions == nil {
            return result(FlutterError(code: "connect(): No MqttConfig set. Call register() first.", message: nil, details: nil))
        }
        Task {
            do {
                try await codingStation.connect(mqttConnectionOptions!)
                result(true)
            } catch {
                result(FlutterError(code: "connect(): \(error)", message: nil, details: nil))
            }
        }
    }

    @objc
    private func write(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        Task {
            do {
                try await codingStation.write()
                result(true)
            } catch {
                result(FlutterError(code: "write(): \(error)", message: nil, details: nil))
            }
        }
    }

    @objc
    private func disconnect(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        codingStation.disconnect()
        result(true)
    }
}
