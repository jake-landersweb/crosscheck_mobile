import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Register native tab bar platform view
    setupNativeTabBar()

    // Register iOS 26 alert dialog platform view
    setupAlertDialog()

    // Register iOS 26 popup menu button platform view
    setupPopupMenuButton()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func setupNativeTabBar() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let factory = NativeTabBarViewFactory(messenger: controller.binaryMessenger)
    registrar(forPlugin: "XCNativeTabBar")?.register(factory, withId: "com.crosscheck/native_tab_bar")
  }

  private func setupAlertDialog() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let factory = iOS26AlertDialogViewFactory(messenger: controller.binaryMessenger)
    registrar(forPlugin: "XCAlertDialog")?.register(factory, withId: "com.crosscheck/ios26_alert_dialog")
  }

  private func setupPopupMenuButton() {
    guard let controller = window?.rootViewController as? FlutterViewController else { return }
    let factory = iOS26PopupMenuButtonViewFactory(messenger: controller.binaryMessenger)
    registrar(forPlugin: "XCPopupMenuButton")?.register(factory, withId: "com.crosscheck/ios26_popup_menu_button")
  }
}
