import Flutter
import UIKit

// MARK: - Factory

class NativeTabBarViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }

    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return NativeTabBarView(
            frame: frame,
            viewId: viewId,
            args: args as? [String: Any],
            messenger: messenger
        )
    }
}

// MARK: - Container View

/// Custom container that re-lays out the tab bar whenever Flutter resizes the view.
/// On creation the platform view has a zero/tiny frame, so the tab bar truncates
/// all labels. This ensures items are re-laid out once the real width arrives.
private class TabBarContainerView: UIView {
    var onLayoutUpdate: (() -> Void)?
    private var lastWidth: CGFloat = 0

    override func layoutSubviews() {
        super.layoutSubviews()
        if bounds.width != lastWidth {
            lastWidth = bounds.width
            // Re-layout the tab bar now that we have the real width
            for subview in subviews {
                subview.setNeedsLayout()
                subview.layoutIfNeeded()
            }
            onLayoutUpdate?()
        }
    }

}

// MARK: - Platform View

class NativeTabBarView: NSObject, FlutterPlatformView, UITabBarDelegate {
    private let containerView: TabBarContainerView
    private let tabBar: UITabBar
    private let channel: FlutterMethodChannel

    init(
        frame: CGRect,
        viewId: Int64,
        args: [String: Any]?,
        messenger: FlutterBinaryMessenger
    ) {
        containerView = TabBarContainerView(frame: frame)
        tabBar = UITabBar()
        channel = FlutterMethodChannel(
            name: "com.crosscheck/native_tab_bar_\(viewId)",
            binaryMessenger: messenger
        )

        super.init()

        tabBar.delegate = self
        containerView.addSubview(tabBar)
        containerView.clipsToBounds = false

        containerView.onLayoutUpdate = { [weak self] in
            self?.reportHeight()
        }

        configureAppearance(args: args)
        configureItems(args: args)
        configureSelection(args: args)
        configureTintColor(args: args)

        tabBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tabBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tabBar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tabBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            tabBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        channel.setMethodCallHandler { [weak self] call, result in
            self?.handleMethodCall(call: call, result: result)
        }
    }

    func view() -> UIView {
        return containerView
    }

    // MARK: - Configuration

    private func configureAppearance(args: [String: Any]?) {
        let appearance = UITabBarAppearance()

        if #available(iOS 26.0, *) {
            appearance.configureWithTransparentBackground()
            tabBar.clipsToBounds = false
        } else {
            appearance.configureWithDefaultBackground()
        }

        appearance.shadowColor = .clear
        appearance.shadowImage = UIImage()

        tabBar.standardAppearance = appearance
        if #available(iOS 15.0, *) {
            tabBar.scrollEdgeAppearance = appearance
        }
    }

    private func configureItems(args: [String: Any]?) {
        guard let items = args?["items"] as? [[String: Any]] else { return }

        var tabBarItems: [UITabBarItem] = []
        for (index, item) in items.enumerated() {
            let label = item["label"] as? String ?? ""
            let sfSymbol = item["sfSymbol"] as? String ?? "circle"
            let selectedSfSymbol = item["selectedSfSymbol"] as? String

            let image = UIImage(systemName: sfSymbol)
            let selectedImage = selectedSfSymbol != nil
                ? UIImage(systemName: selectedSfSymbol!)
                : nil

            let tabBarItem = UITabBarItem(
                title: label,
                image: image,
                selectedImage: selectedImage
            )
            tabBarItem.tag = index

            let badge = item["badge"] as? String
            tabBarItem.badgeValue = badge

            tabBarItems.append(tabBarItem)
        }

        tabBar.setItems(tabBarItems, animated: false)
    }

    private func configureSelection(args: [String: Any]?) {
        guard let selectedIndex = args?["selectedIndex"] as? Int,
              let items = tabBar.items,
              selectedIndex < items.count
        else { return }

        tabBar.selectedItem = items[selectedIndex]
    }

    private func configureTintColor(args: [String: Any]?) {
        guard let argbInt = args?["tintColor"] as? Int else { return }
        tabBar.tintColor = colorFromARGB(argbInt)
    }

    // MARK: - Method Channel

    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setSelectedIndex":
            if let index = call.arguments as? Int,
               let items = tabBar.items,
               index < items.count {
                tabBar.selectedItem = items[index]
                result(nil)
            } else {
                result(FlutterError(
                    code: "INVALID_INDEX",
                    message: "Invalid tab index",
                    details: nil
                ))
            }

        case "setTintColor":
            if let argbInt = call.arguments as? Int {
                tabBar.tintColor = colorFromARGB(argbInt)
                result(nil)
            } else {
                result(FlutterError(
                    code: "INVALID_COLOR",
                    message: "Invalid ARGB color value",
                    details: nil
                ))
            }

        case "setBadge":
            if let args = call.arguments as? [String: Any],
               let index = args["index"] as? Int,
               let items = tabBar.items,
               index < items.count {
                let badge = args["badge"] as? String
                items[index].badgeValue = badge
                result(nil)
            } else {
                result(FlutterError(
                    code: "INVALID_ARGS",
                    message: "Expected {index: Int, badge: String?}",
                    details: nil
                ))
            }

        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - UITabBarDelegate

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        channel.invokeMethod("onTabSelected", arguments: item.tag)
    }

    // MARK: - Height Reporting

    private func reportHeight() {
        let height = tabBar.frame.height
        if height > 0 {
            channel.invokeMethod("onHeightChanged", arguments: height)
        }
    }

    // MARK: - Helpers

    private func colorFromARGB(_ argb: Int) -> UIColor {
        let a = CGFloat((argb >> 24) & 0xFF) / 255.0
        let r = CGFloat((argb >> 16) & 0xFF) / 255.0
        let g = CGFloat((argb >> 8) & 0xFF) / 255.0
        let b = CGFloat(argb & 0xFF) / 255.0
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}
