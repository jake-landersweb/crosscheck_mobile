import 'dart:io';
import 'dart:ui';

import 'package:crosscheck_sports/components/layer/header_gradient.dart';
import 'package:crosscheck_sports/components/layer/large_title.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// A scrollable header bar with large/small title transitions.
///
/// Features:
/// - Large title that blurs and fades when scrolling up
/// - Small title that slides up and fades in
/// - Soft edge blur at the top for content fade effect
/// - Optional pull-to-refresh functionality
///
/// Leading/trailing items are managed separately by [HeaderBarItemsOverlay]
/// in the shell, configured via [HeaderBarItems] wrapper in route builders.
///
/// Use [HeaderBar.sheet] for modal sheet contexts (no safe area, centered title).
class HeaderBar extends StatefulWidget {
  /// Creates a header bar with a large title style by default.
  const HeaderBar({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.slivers,
    this.isLarge = true,
    this.scrollController,
    this.backgroundColor,
    this.titleColor,
    this.largeTitlePadding = EdgeInsets.zero,
    this.horizontalPadding = 16.0,
    this.bottomPadding = 100.0,
    this.refreshable = false,
    this.onRefresh,
    this.barHeight = XCThemeData.listItemHeight,
    this.hideKeyboardOnTap = true,
    this.leading,
    this.trailing,
  }) : _hasSafeArea = true,
       _titleAlignment = Alignment.center,
       _itemBarPadding = const EdgeInsets.symmetric(horizontal: 16);

  /// Creates a header bar optimized for modal sheets.
  ///
  /// This variant:
  /// - Does not account for safe area (sheets handle this)
  /// - Centers the title
  /// - Uses a taller bar height (60px)
  const HeaderBar.sheet({
    super.key,
    this.title,
    this.titleWidget,
    required this.child,
    this.slivers,
    this.scrollController,
    this.backgroundColor,
    this.titleColor,
    this.largeTitlePadding = EdgeInsets.zero,
    this.horizontalPadding = 16.0,
    this.bottomPadding = 100.0,
    this.refreshable = false,
    this.onRefresh,
    this.hideKeyboardOnTap = true,
    this.leading,
    this.trailing,
  }) : isLarge = false,
       barHeight = XCThemeData.listItemHeight + 8,
       _hasSafeArea = false,
       _titleAlignment = Alignment.center,
       _itemBarPadding = const EdgeInsets.fromLTRB(16, 8, 16, 0);

  /// The title text displayed in the header.
  final String? title;

  /// A custom widget to display as the title (used when [isLarge] is false).
  ///
  /// Takes precedence over [title] in the small title bar.
  final Widget? titleWidget;

  /// The content to display below the header.
  final Widget child;

  /// Optional list of slivers to use instead of wrapping [child].
  ///
  /// When provided, these slivers are used directly in the scroll view,
  /// enabling lazy loading of list items. The [child] is still rendered
  /// before the slivers as a non-lazy header section.
  final List<Widget>? slivers;

  /// Whether to show a large title that transitions to small on scroll.
  ///
  /// When true, shows a large title below the bar that blurs and fades
  /// as the user scrolls, while the small title in the bar fades in.
  final bool isLarge;

  /// Optional scroll controller for the content.
  ///
  /// If not provided, an internal controller is created.
  final ScrollController? scrollController;

  /// Background color of the header bar and content area.
  final Color? backgroundColor;

  /// Color for the title text.
  final Color? titleColor;

  /// Padding around the large title.
  final EdgeInsets largeTitlePadding;

  /// Horizontal padding for the content area.
  final double horizontalPadding;

  /// Bottom padding added after the content.
  final double bottomPadding;

  /// Whether pull-to-refresh is enabled.
  final bool refreshable;

  /// Callback when refresh is triggered.
  final AsyncCallback? onRefresh;

  /// Height of the title bar area (excluding safe area).
  final double barHeight;

  /// Whether to dismiss keyboard when tapping outside.
  final bool hideKeyboardOnTap;

  /// Widget to display on the leading (left) side of the header bar.
  final Widget? leading;

  /// Widget to display on the trailing (right) side of the header bar.
  final Widget? trailing;

  // Internal configuration (set by constructors)
  final bool _hasSafeArea;
  final Alignment _titleAlignment;
  final EdgeInsets _itemBarPadding;

  @override
  State<HeaderBar> createState() => _HeaderBarState();
}

class _HeaderBarState extends State<HeaderBar> {
  /// Whether to show the small title (when large title is active).
  bool _showSmallTitle = false;

  /// Scale factor for the large title (bounce effect on over-scroll).
  double _titleScale = 1.0;

  /// Progress for the refresh indicator (0.0 to 1.0+).
  double _loadAmount = 0.0;

  /// Whether user has scrolled enough to trigger refresh on release.
  bool _shouldLoad = false;

  /// Amount to offset content during refresh animation.
  double _scrollAmount = 0.0;

  /// Internal tracker to prevent duplicate refresh calls.
  bool _isLoading = false;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _showSmallTitle = !widget.isLarge;
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;

    if (offset > 0) {
      // Scrolling up - reset title scale
      if (widget.isLarge && _titleScale != 1.0) {
        setState(() => _titleScale = 1.0);
      }
    } else {
      // Pulling down (over-scroll)
      if (widget.isLarge && !widget.refreshable) {
        // Scale up large title on bounce
        setState(() {
          _titleScale = 1.0 + (-offset * 0.0005);
          _showSmallTitle = false;
        });
      }
    }

    // Show/hide small title based on scroll position (only for large title mode)
    if (widget.isLarge) {
      if (offset > 30 && !_showSmallTitle) {
        setState(() => _showSmallTitle = true);
      } else if (offset < 10 && _showSmallTitle) {
        setState(() => _showSmallTitle = false);
      }
    }

    // Handle refresh indicator
    if (widget.refreshable) {
      setState(() {
        _loadAmount = -0.2 + (-offset * 0.012);
      });
      _shouldLoad = _loadAmount >= 1.0;
    }
  }

  Future<void> _refreshAction() async {
    if (_isLoading || widget.onRefresh == null) return;

    _isLoading = true;
    try {
      await widget.onRefresh!();
    } finally {
      if (mounted) {
        setState(() {
          _shouldLoad = false;
          _scrollAmount = 0;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeAreaTop = widget._hasSafeArea
        ? MediaQuery.of(context).viewPadding.top
        : 0.0;
    final hasHeaderContent =
        (widget.title != null && widget.title!.isNotEmpty) ||
        widget.titleWidget != null ||
        widget.leading != null ||
        widget.trailing != null;
    const minBarHeight = XCThemeData.listItemHeight;
    final barHeight = hasHeaderContent
        ? widget.barHeight.clamp(minBarHeight, double.infinity)
        : 0.0;
    final headerHeight = safeAreaTop + barHeight;

    final bgColor = widget.backgroundColor ?? XCTheme.of(context).background;
    final titleColor = widget.titleColor ?? XCTheme.of(context).foreground;

    Widget scaffold = GestureDetector(
      onTap: widget.hideKeyboardOnTap
          ? () => FocusManager.instance.primaryFocus?.unfocus()
          : null,
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          top: false,
          bottom: false,
          left: false,
          right: false,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Layer 1: Content
              Positioned.fill(
                child: _buildScrollView(
                  context,
                  safeAreaTop: safeAreaTop,
                  headerHeight: headerHeight,
                  titleColor: titleColor,
                ),
              ),

              // Layer 2: Header gradient fade
              Positioned(
                top: -1,
                left: 0,
                right: 0,
                height: headerHeight + 17,
                child: XCHeaderGradient(color: bgColor),
              ),

              // Layer 3: Title bar overlay (title and/or leading/trailing items)
              if (hasHeaderContent)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: headerHeight,
                  child: _buildTitleBar(
                    context,
                    safeAreaTop: safeAreaTop,
                    titleColor: titleColor,
                  ),
                ),

              // Layer 4: Refresh indicator
              if (widget.refreshable)
                Positioned(
                  top:
                      safeAreaTop +
                      (widget.isLarge ? 0 : widget.barHeight) +
                      10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _scrollAmount != 0
                        ? CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : CircularProgressIndicator(
                            value: _loadAmount.clamp(0.0, 1.0),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Remove safe area padding when in sheet mode
    if (!widget._hasSafeArea) {
      return MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: scaffold,
      );
    }

    return scaffold;
  }

  Widget _buildScrollView(
    BuildContext context, {
    required double safeAreaTop,
    required double headerHeight,
    required Color titleColor,
  }) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Check for scroll end to trigger refresh
        if (notification is ScrollEndNotification) {
          if (_scrollAmount == 0 && _shouldLoad) {
            setState(() => _scrollAmount = _scrollController.offset);
            _refreshAction();
          }
        }
        // Return false to allow notifications to bubble up
        return false;
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: Platform.isIOS
            ? const AlwaysScrollableScrollPhysics()
            : const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
        slivers: [
          // Spacer for header area
          SliverToBoxAdapter(child: SizedBox(height: headerHeight)),

          // Gap between header bar and large title
          if (widget.isLarge)
            const SliverToBoxAdapter(child: SizedBox(height: 10)),

          // Large title (if enabled)
          if (widget.isLarge)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.horizontalPadding,
                ).add(widget.largeTitlePadding),
                child: Transform.scale(
                  alignment: Alignment.centerLeft,
                  scale: _titleScale > 1 ? _titleScale : 1,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: _showSmallTitle ? 10.0 : 0.0),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    builder: (context, blurValue, child) {
                      return ImageFiltered(
                        imageFilter: ImageFilter.blur(
                          sigmaX: blurValue,
                          sigmaY: blurValue,
                        ),
                        child: child,
                      );
                    },
                    child: AnimatedOpacity(
                      opacity: _showSmallTitle ? 0 : 1,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: XCLargeTitle(
                        title: widget.title ?? '',
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Spacing before content
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // Main content (non-lazy header section)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
            sliver: SliverToBoxAdapter(child: widget.child),
          ),

          // Additional slivers for lazy loading (if provided)
          if (widget.slivers != null) ...widget.slivers!,

          // Bottom padding
          SliverToBoxAdapter(child: SizedBox(height: widget.bottomPadding)),
        ],
      ),
    );
  }

  /// Builds only the small title (items are rendered in shell overlay).
  ///
  /// Uses [GestureDetector] with [HitTestBehavior.translucent] to block
  /// interactions from passing through the header while allowing button taps.
  Widget _buildTitleBar(
    BuildContext context, {
    required double safeAreaTop,
    required Color titleColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Padding(
        padding: EdgeInsets.only(top: safeAreaTop),
        child: Padding(
          padding: widget._itemBarPadding,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Centered title (renders first, below buttons)
              // Must be first to avoid disappearing when trailing changes
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal:
                        (widget.leading != null || widget.trailing != null)
                        ? XCThemeData.listItemHeight + 8
                        : 0,
                  ),
                  child: Align(
                    alignment: widget._titleAlignment,
                    child: AnimatedSlide(
                      offset: _showSmallTitle
                          ? Offset.zero
                          : const Offset(0, 0.3),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                      child: AnimatedOpacity(
                        opacity: _showSmallTitle ? 1 : 0,
                        duration: const Duration(milliseconds: 200),
                        child:
                            widget.titleWidget ??
                            Text(
                              (widget.title?.length ?? 0) > 25
                                  ? '${widget.title!.substring(0, 25)}...'
                                  : widget.title ?? '',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: titleColor,
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              // Leading and trailing widgets in a row
              if (widget.leading != null || widget.trailing != null)
                Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.leading != null)
                        UnconstrainedBox(
                          constrainedAxis: Axis.horizontal,
                          child: widget.leading,
                        )
                      else
                        const SizedBox.shrink(),
                      if (widget.trailing != null)
                        UnconstrainedBox(
                          constrainedAxis: Axis.horizontal,
                          child: widget.trailing,
                        )
                      else
                        const SizedBox.shrink(),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
