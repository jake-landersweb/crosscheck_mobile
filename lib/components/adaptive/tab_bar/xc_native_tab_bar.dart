import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tab_bar_item.dart';

/// A native iOS tab bar using a custom UiKitView platform view.
///
/// Wraps a native UITabBar for full control over label rendering
/// and avoids the CNTabBar bug where labels don't appear on first load.
class XCNativeTabBar extends StatefulWidget {
  const XCNativeTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.tintColor,
    this.onHeightChanged,
  });

  final List<AdaptiveTabBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final Color? tintColor;
  final ValueChanged<double>? onHeightChanged;

  @override
  State<XCNativeTabBar> createState() => _XCNativeTabBarState();
}

class _XCNativeTabBarState extends State<XCNativeTabBar> {
  MethodChannel? _channel;
  double? _nativeHeight;

  Color _effectiveTintColor(BuildContext context) {
    return widget.tintColor ?? XCTheme.of(context).primary;
  }

  Map<String, dynamic> _buildCreationParams(BuildContext context) {
    return {
      'items': widget.items.map((item) {
        return {
          'label': item.label,
          'sfSymbol': item.icon.sfSymbol,
          'selectedSfSymbol': item.icon.selectedSfSymbol,
          'badge': item.badge,
        };
      }).toList(),
      'selectedIndex': widget.selectedIndex,
      'tintColor': _effectiveTintColor(context).toARGB32(),
    };
  }

  void _onPlatformViewCreated(int viewId) {
    debugPrint('[XCNativeTabBar] platform view created with viewId=$viewId');
    _channel = MethodChannel('com.crosscheck/native_tab_bar_$viewId');
    _channel!.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    debugPrint('[XCNativeTabBar] method call: ${call.method} args: ${call.arguments}');
    switch (call.method) {
      case 'onTabSelected':
        final index = call.arguments as int;
        debugPrint('[XCNativeTabBar] onTabSelected index=$index');
        widget.onTabSelected(index);
        break;
      case 'onHeightChanged':
        final height = (call.arguments as num).toDouble();
        if (mounted && height != _nativeHeight) {
          setState(() {
            _nativeHeight = height;
          });
          widget.onHeightChanged?.call(height);
        }
        break;
    }
  }

  @override
  void didUpdateWidget(covariant XCNativeTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_channel == null) return;

    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _channel!.invokeMethod('setSelectedIndex', widget.selectedIndex);
    }

    // Tint color comparison requires context, handled in build via
    // checking the effective color. We compare widget-level tintColor here.
    if (oldWidget.tintColor != widget.tintColor) {
      final color = widget.tintColor ?? XCTheme.of(context).primary;
      _channel!.invokeMethod('setTintColor', color.toARGB32());
    }

    // Update badges when they change
    for (int i = 0; i < widget.items.length; i++) {
      final oldBadge = i < oldWidget.items.length
          ? oldWidget.items[i].badge
          : null;
      if (widget.items[i].badge != oldBadge) {
        _channel!.invokeMethod('setBadge', {
          'index': i,
          'badge': widget.items[i].badge,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final defaultHeight = MediaQuery.of(context).padding.bottom + 49;
    final height = _nativeHeight ?? defaultHeight;

    return SizedBox(
      height: height,
      child: UiKitView(
        viewType: 'com.crosscheck/native_tab_bar',
        creationParams: _buildCreationParams(context),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: _onPlatformViewCreated,
      ),
    );
  }
}
