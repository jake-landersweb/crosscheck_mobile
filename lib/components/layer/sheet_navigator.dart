import 'dart:io';

import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Provides sheet navigation context to descendant widgets.
///
/// Use [SheetNavigation.of] to access the navigator from anywhere within the
/// sheet, or [SheetNavigation.maybeOf] when navigation context is optional.
class SheetNavigation extends InheritedWidget {
  final SheetNavigatorState navigator;
  final bool canPop;

  const SheetNavigation({
    super.key,
    required this.navigator,
    required this.canPop,
    required super.child,
  });

  /// Returns the [SheetNavigatorState] from the closest [SheetNavigation] ancestor.
  ///
  /// Throws if no [SheetNavigation] is found in the widget tree.
  static SheetNavigatorState of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No SheetNavigation found in context');
    return result!;
  }

  /// Returns the [SheetNavigatorState] from the closest [SheetNavigation] ancestor,
  /// or null if none exists.
  static SheetNavigatorState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SheetNavigation>()
        ?.navigator;
  }

  @override
  bool updateShouldNotify(SheetNavigation oldWidget) {
    return canPop != oldWidget.canPop;
  }
}

/// A navigator that manages page navigation within a sheet/modal.
///
/// Wraps content in a local [Navigator] with platform-native transitions.
/// Intercepts system back button to navigate within the sheet before closing,
/// while allowing barrier taps to always dismiss the entire sheet.
///
/// Example:
/// ```dart
/// SheetNavigator(
///   child: ListOptionsPage(listId: listId),
/// )
/// ```
class SheetNavigator extends StatefulWidget {
  /// The initial page to display in the navigator.
  final Widget child;

  const SheetNavigator({super.key, required this.child});

  @override
  State<SheetNavigator> createState() => SheetNavigatorState();
}

class SheetNavigatorState extends State<SheetNavigator> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _stackDepth = 1;

  /// Push a new page with platform-native animation.
  ///
  /// Returns a Future that completes when the pushed page is popped.
  Future<T?> push<T>(WidgetBuilder builder, {String? name}) {
    setState(() {
      _stackDepth++;
    });

    // Wrap the page in an Overlay so widgets using Overlay.of() work correctly
    Widget overlayBuilder(BuildContext context) {
      return Overlay(
        initialEntries: [OverlayEntry(builder: (_) => builder(context))],
      );
    }

    // Use non-modal routes that don't interfere with parent barrier
    final Route<T> route;
    if (Platform.isIOS) {
      route = CupertinoPageRoute<T>(
        builder: overlayBuilder,
        settings: RouteSettings(name: name),
      );
    } else {
      route = MaterialPageRoute<T>(
        builder: overlayBuilder,
        settings: RouteSettings(name: name),
      );
    }

    return _navigatorKey.currentState!.push<T>(route).then((result) {
      // Update stack depth when route is popped (by any means)
      if (mounted && _stackDepth > 1) {
        setState(() {
          _stackDepth--;
        });
      }
      return result;
    });
  }

  /// Pop the current page.
  ///
  /// If there's only the root page, this does nothing.
  void pop<T>([T? result]) {
    if (canPop) {
      _navigatorKey.currentState!.pop<T>(result);
    }
  }

  /// Whether there are pages to pop within the sheet.
  bool get canPop => _stackDepth > 1;

  @override
  Widget build(BuildContext context) {
    return SheetNavigation(
      navigator: this,
      canPop: canPop,
      child: Navigator(
        key: _navigatorKey,
        // Prevent this navigator from handling system back button
        requestFocus: false,
        onGenerateRoute: (settings) {
          // Wrap root page in Overlay so widgets using Overlay.of() work correctly
          Widget overlayBuilder(BuildContext context) {
            return Overlay(
              initialEntries: [OverlayEntry(builder: (_) => widget.child)],
            );
          }

          if (Platform.isIOS) {
            return CupertinoPageRoute(
              builder: overlayBuilder,
              settings: const RouteSettings(name: '_root'),
            );
          }
          return MaterialPageRoute(
            builder: overlayBuilder,
            settings: const RouteSettings(name: '_root'),
          );
        },
        onDidRemovePage: (page) {
          if (mounted && _stackDepth > 1) {
            setState(() {
              _stackDepth--;
            });
          }
        },
      ),
    );
  }
}

/// A page within a SheetNavigator with automatic back button handling.
///
/// Wraps content with [HeaderBar.sheet] and automatically configures the
/// leading button based on navigation state:
/// - Shows back button (chevron) if there are pages to pop
/// - Shows cancel button (X) if this is the root page
///
/// Example:
/// ```dart
/// SheetPage(
///   title: 'Members',
///   trailing: XCActionButton.add(onTap: () => ...),
///   child: _buildContent(),
/// )
/// ```
class SheetPage extends StatelessWidget {
  /// The title text for the header.
  final String? title;

  /// A custom widget to display as the title.
  final Widget? titleWidget;

  /// The page content.
  final Widget child;

  /// Widget to display on the trailing (right) side of the header.
  final Widget? trailing;

  /// Optional scroll controller for the content.
  final ScrollController? scrollController;

  /// Optional list of slivers for lazy loading content.
  final List<Widget>? slivers;

  /// Whether the page content is refreshable.
  final bool refreshable;

  /// Callback when refresh is triggered.
  final Future<void> Function()? onRefresh;

  /// Horizontal padding for the content area.
  final double horizontalPadding;

  /// Bottom padding added after the content.
  final double bottomPadding;

  const SheetPage({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.trailing,
    this.scrollController,
    this.slivers,
    this.refreshable = false,
    this.onRefresh,
    this.horizontalPadding = 16.0,
    this.bottomPadding = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    final sheetNav = SheetNavigation.maybeOf(context);
    final canGoBack = sheetNav?.canPop ?? false;

    return HeaderBar.sheet(
      title: title,
      titleWidget: titleWidget,
      leading: canGoBack
          ? XCActionButton.back(onTap: () => sheetNav!.pop())
          : XCActionButton.cancel(),
      trailing: trailing,
      scrollController: scrollController,
      slivers: slivers,
      refreshable: refreshable,
      onRefresh: onRefresh,
      horizontalPadding: horizontalPadding,
      bottomPadding: bottomPadding,
      child: child,
    );
  }
}
