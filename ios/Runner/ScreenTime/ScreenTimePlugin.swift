import Flutter
import Foundation

class ScreenTimePlugin: NSObject, FlutterPlugin {
    private let screenTimeManager = ScreenTimeManager()

    static func register(with messenger: FlutterBinaryMessenger) {
        let channel = FlutterMethodChannel(
            name: "com.prayerscreentime.screentime",
            binaryMessenger: messenger
        )
        let instance = ScreenTimePlugin()
        channel.setMethodCallHandler(instance.handle)
    }

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.prayerscreentime.screentime",
            binaryMessenger: registrar.messenger()
        )
        let instance = ScreenTimePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "requestAuthorization":
            requestAuthorization(result: result)
        case "startShielding":
            startShielding(result: result)
        case "stopShielding":
            stopShielding(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func requestAuthorization(result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            screenTimeManager.requestAuthorization { success in
                DispatchQueue.main.async {
                    result(success)
                }
            }
        } else {
            result(FlutterError(
                code: "UNSUPPORTED",
                message: "Screen Time API requires iOS 16+",
                details: nil
            ))
        }
    }

    private func startShielding(result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            screenTimeManager.startShielding()
            result(true)
        } else {
            result(false)
        }
    }

    private func stopShielding(result: @escaping FlutterResult) {
        if #available(iOS 16.0, *) {
            screenTimeManager.stopShielding()
            result(true)
        } else {
            result(false)
        }
    }
}
