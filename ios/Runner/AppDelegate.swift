import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    private var streamUrl: String? // Stream URL for live streaming
    private var progress: Int = 0 // Simulated download progress

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
        let torrentChannel = FlutterMethodChannel(name: "torrent_streamer", binaryMessenger: controller.binaryMessenger)

        torrentChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "startDownload":
                if let args = call.arguments as? [String: Any],
                   let magnetLink = args["magnetLink"] as? String {
                    self.startDownload(magnetLink: magnetLink)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENTS", message: "Magnet link not provided", details: nil))
                }

            case "getProgress":
                result(self.progress)

            case "startStreaming":
                if let streamUrl = self.streamUrl {
                    result(streamUrl)
                } else {
                    result(FlutterError(code: "STREAM_NOT_READY", message: "Stream not ready", details: nil))
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func startDownload(magnetLink: String) {
        print("Starting download for magnet link: \(magnetLink)")

        DispatchQueue.global().async {
            for i in 1...100 {
                sleep(1) // Simulate download time
                self.progress = i
                if i == 30 {
                    self.streamUrl = "http://localhost:8080/stream.m3u8" // Replace with actual stream URL
                }
            }
        }
    }
}
