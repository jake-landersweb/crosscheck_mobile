import 'dart:io';

import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'xc_native_tab_bar.dart';
import 'tab_bar_item.dart';

/// Platform-adaptive tab bar that uses native components where available.
///
/// On iOS, uses [CNTabBar] from cupertino_native_better for native
/// liquid glass effects on iOS 26+.
///
/// On Android and other platforms, uses a Flutter-based implementation.
class AdaptiveTabBar extends StatelessWidget {
  const AdaptiveTabBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onHeightChanged,
  });

  final List<AdaptiveTabBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<double>? onHeightChanged;

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return _IosNativeTabBar(
        items: items,
        selectedIndex: selectedIndex,
        onTabSelected: onTabSelected,
        onHeightChanged: onHeightChanged,
      );
    }

    return _FlutterFallbackTabBar(
      items: items,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
      onHeightChanged: onHeightChanged,
    );
  }
}

/// iOS tab bar using a custom native UITabBar platform view.
class _IosNativeTabBar extends StatelessWidget {
  const _IosNativeTabBar({
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onHeightChanged,
  });

  final List<AdaptiveTabBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<double>? onHeightChanged;

  @override
  Widget build(BuildContext context) {
    return XCNativeTabBar(
      items: items,
      selectedIndex: selectedIndex,
      onTabSelected: onTabSelected,
      onHeightChanged: onHeightChanged,
      tintColor: Theme.of(context).brightness == Brightness.light
          ? Colors.black
          : Colors.white,
    );
  }
}

/// Flutter-based fallback tab bar for non-iOS platforms.
class _FlutterFallbackTabBar extends StatefulWidget {
  const _FlutterFallbackTabBar({
    required this.items,
    required this.selectedIndex,
    required this.onTabSelected,
    this.onHeightChanged,
  });

  final List<AdaptiveTabBarItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final ValueChanged<double>? onHeightChanged;

  @override
  State<_FlutterFallbackTabBar> createState() => _FlutterFallbackTabBarState();
}

class _FlutterFallbackTabBarState extends State<_FlutterFallbackTabBar> {
  bool _reported = false;

  @override
  Widget build(BuildContext context) {
    if (!_reported) {
      _reported = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final height = 64.0 + MediaQuery.of(context).padding.bottom;
        widget.onHeightChanged?.call(height);
      });
    }
    return Container(
      color: Colors.white.withValues(alpha: 0.9),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < widget.items.length; i++)
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onTabSelected(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(
                              widget.items[i].icon.getIcon(
                                selected: widget.selectedIndex == i,
                              ),
                              color: widget.selectedIndex == i
                                  ? CupertinoColors.activeBlue
                                  : CupertinoColors.inactiveGray,
                            ),
                            if (widget.items[i].badge != null)
                              Positioned(
                                right: -8,
                                top: -4,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Text(
                                    widget.items[i].badge!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.items[i].label,
                          style: XCTheme.of(context).text.caption.copyWith(
                            fontSize: 10,
                            color: widget.selectedIndex == i
                                ? CupertinoColors.activeBlue
                                : CupertinoColors.inactiveGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
