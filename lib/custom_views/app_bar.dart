import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/painting.dart';
import 'dart:ui';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter/cupertino.dart';

import 'core/root.dart';

/// Replacement for the default AppBar in flutter.
///
/// Views will be placed in a scrollable view by default.
///
/// By default, it will show a large title that expands when dragged down,
/// and collapses to a small app bar when scrolled up.
class AppBar extends StatefulWidget {
  // constructor
  const AppBar({
    Key? key,
    required this.title,
    required this.children,
    this.leading = const Text(''),
    this.actions = const [],
    this.horizontalPadding = 15,
    this.isLarge = false,
    this.titlePadding = const EdgeInsets.fromLTRB(15, 0, 0, 15),
    this.refreshable,
    this.onRefresh,
    this.color,
    this.areaHeight = 40,
  });

  /// title of the view
  final String title;

  /// body, will be scrollable
  final List<Widget> children;

  /// leading widget, typically a back arrow
  final Widget leading;

  /// actions, show on right side of header
  final List<Widget> actions;

  /// padding of items in list
  final double horizontalPadding;

  /// if want a large title
  final bool isLarge;

  /// for spacing between the title and the view
  final EdgeInsets titlePadding;

  final bool? refreshable;

  final AsyncCallback? onRefresh;

  final Color? color;

  final double areaHeight;

  @override
  _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  ScrollController? _scrollController;

  // whether to show the shadow or not
  bool _showElevation = false;

  // controls title scale for interactive changing
  double _titleScale = 1;

  // whether to show the small title when large title is active
  bool _showSmallTitle = false;

  // progress for loading
  double _loadAmount = 0;

  // for showing the loading indicator
  bool _showLoad = false;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await widget.onRefresh!();
    if (mounted) setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    super.initState();
    if (!widget.isLarge) {
      _showSmallTitle = true;
      _scrollController = ScrollController()
        ..addListener(() {
          if (_scrollController!.offset > 5) {
            setState(() {
              _showElevation = true;
            });
          } else {
            setState(() {
              _showElevation = false;
            });
          }
          if (widget.refreshable ?? false) {
            setState(() {
              _loadAmount = -(_scrollController!.offset * 0.012);
            });
          }
        });
      _showElevation = false;
    } else {
      // get the scroll offset
      _scrollController = ScrollController()
        ..addListener(() {
          if (_scrollController!.offset > 20) {
            setState(() {
              _showSmallTitle = true;
            });
          } else {
            setState(() {
              _showSmallTitle = false;
            });
          }
          if (_scrollController!.offset > 5) {
            setState(() {
              _showElevation = true;
            });
          } else {
            setState(() {
              _showElevation = false;
            });
          }
          if (widget.refreshable ?? false) {
            setState(() {
              _loadAmount = -(_scrollController!.offset * 0.012);
            });
          } else {
            // increase title size when scrolling down
            setState(() {
              _titleScale = 1 + (-_scrollController!.offset * 0.001);
            });
          }
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    // no safe area
    return SafeArea(
      key: widget.key,
      bottom: false,
      top: false,
      right: false,
      left: false,
      child: Stack(
        alignment: AlignmentDirectional.topCenter,
        children: [
          // the body the user passes
          if (widget.refreshable ?? false)
            SmartRefresher(
              enablePullDown: true,
              enablePullUp: false,
              header: CustomHeader(
                builder: (context, mode) {
                  Widget body;
                  if (mode == RefreshStatus.idle ||
                      mode == RefreshStatus.canRefresh) {
                    body = Container();
                    _showLoad = true;
                  } else if (mode == RefreshStatus.failed) {
                    body = const Icon(Icons.error_outline);
                    _showLoad = false;
                  } else {
                    body = CircularProgressIndicator(
                        color: widget.color ??
                            Theme.of(context).colorScheme.primary);
                    _showLoad = false;
                  }
                  return SizedBox(
                    height: 75.0,
                    child: Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: body,
                    ),
                  );
                },
                height: 80,
              ),
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _body(context),
            )
          else
            _body(context),
          // header view
          _header(context),
          if (widget.refreshable ?? false)
            SafeArea(
              top: true,
              child: AnimatedOpacity(
                opacity: _loadAmount > 0 ? 1 : 0,
                duration: const Duration(milliseconds: 250),
                child: _showLoad
                    ? Padding(
                        padding: EdgeInsets.only(
                          top: _indicatorPadding(
                              MediaQuery.of(context).padding.top),
                        ),
                        child: CircularProgressIndicator(
                          value: _loadAmount,
                          color: widget.color ??
                              Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : Container(height: 0),
              ),
            ),
        ],
      ),
    );
  }

  double _indicatorPadding(double safeAreaHeight) {
    if (safeAreaHeight < 40) {
      return 20;
    } else {
      return 0;
    }
  }

  Widget _body(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + widget.areaHeight + 10),
      physics: const AlwaysScrollableScrollPhysics(),
      controller: _scrollController,
      children: [
        if (widget.isLarge)
          Padding(
              padding: widget.titlePadding,
              child: Transform.scale(
                alignment: Alignment.centerLeft,
                scale: _titleScale > 1 ? _titleScale : 1,
                child: Text(
                  widget.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 40,
                  ),
                ),
              )),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding),
          child: Column(
            children: [
              for (Widget i in widget.children) i,
            ],
          ),
        )
      ],
    );
  }

  // header view
  Widget _header(BuildContext context) {
    // material for shadow
    return Column(
      children: [
        GlassContainer(
          alignment: AlignmentDirectional.bottomCenter,
          height: MediaQuery.of(context).padding.top +
              (Platform.isIOS ? 0 : 10) +
              widget.areaHeight,
          width: MediaQuery.of(context).size.width,
          borderRadius: BorderRadius.circular(0),
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? ViewColors.lightList
                  : Colors.black,
          opacity: _showElevation ? 0.7 : 0,
          blur: _showElevation ? 10 : 0,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                widget.titlePadding.left, 0, widget.titlePadding.left, 8),
            child: Stack(
              children: [
                Align(alignment: Alignment.bottomLeft, child: widget.leading),
                // title
                Align(
                  alignment: Alignment.bottomCenter,
                  child: AnimatedOpacity(
                    opacity: _showSmallTitle ? 1 : 0,
                    duration: const Duration(milliseconds: 150),
                    child: _smallTitle(context),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Row(
                    children: [const Spacer(), for (var i in widget.actions) i],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showElevation)
          const Divider(
            indent: 0,
            height: 0.5,
          ),
      ],
    );
  }

  Widget _smallTitle(BuildContext context) {
    return Text(
      widget.title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
