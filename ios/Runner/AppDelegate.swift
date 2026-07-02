import Flutter
import UIKit
import WidgetKit

private let kAppGroup  = "group.com.example.salaryFlow"
private let kChannel   = "com.example.salaryFlow/widget"

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    setupWidgetChannel()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Widget Channel

  private func setupWidgetChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let channel = FlutterMethodChannel(name: kChannel, binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { [weak self] call, result in
      guard call.method == "updateWidget",
            let args = call.arguments as? [String: Any] else {
        result(FlutterMethodNotImplemented)
        return
      }
      self?.writeToAppGroup(args)
      result(nil)
    }
  }

  private func writeToAppGroup(_ data: [String: Any]) {
    guard let defaults = UserDefaults(suiteName: kAppGroup) else { return }
    for (key, value) in data {
      switch value {
      case let d as Double:  defaults.set(d, forKey: key)
      case let i as Int:     defaults.set(i, forKey: key)
      case let s as String:  defaults.set(s, forKey: key)
      default: break
      }
    }
    defaults.synchronize()

    // Reload all WidgetKit timelines (iOS 14+)
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }
  }
}
