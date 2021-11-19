import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/painting.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:sprung/sprung.dart';

import 'core/root.dart';

class AppBar extends StatefulWidget {
  const AppBar({
    Key? key,
    required this.title,
    required this.children,
    this.leading = const [],
    this.trailing = const [],
    this.isLarge = false,
    this.scrollController,
    this.itemBarPadding = const EdgeInsets.fromLTRB(15, 0, 15, 8),
    this.refreshable = false,
    this.onRefresh,
    this.childPadding = const EdgeInsets.fromLTRB(15, 15, 15, 48),
    this.titlePadding = const EdgeInsets.fromLTRB(15, 0, 0, 0),
    this.color = Colors.blue,
  }) : super(key: key);

  final String title;
  final List<Widget> children;
  final List<Widget> leading;
  final List<Widget> trailing;
  final bool isLarge;
  final ScrollController? scrollController;
  final EdgeInsets itemBarPadding;
  final bool refreshable;
  final AsyncCallback? onRefresh;
  final EdgeInsets childPadding;
  final EdgeInsets titlePadding;
  final Color color;

  @override
  _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  final double _barHeight = 80;

  // whether to show the shadow or not
  bool _showElevation = false;

  // controls title scale for interactive changing
  double _titleScale = 1;

  // whether to show the small title when large title is active
  late bool _showSmallTitle;

  // progress for loading
  double _loadAmount = 0;

  // for determining if user scrolled enough to load
  bool _shouldLoad = false;

  // for getting amount to auto scroll by
  double _scrollAmount = 0;

  // for controlling scroll
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // set up scroll controller
    if (widget.scrollController == null) {
      _scrollController = ScrollController();
    } else {
      _scrollController = widget.scrollController!;
    }

    // set up whether to show large title or not
    if (widget.isLarge) {
      _showSmallTitle = false;
    } else {
      _showSmallTitle = true;
    }

    // add logic to scroll controller
    _scrollController.addListener(() {
      if (_scrollController.offset > 0) {
        // for when title large
        if (widget.isLarge) {
          // set title scale to 1
          if (_titleScale != 1) {
            setState(() {
              _titleScale = 1;
            });
          }
        } else {
          // for only when title is small
        }
        // show elevation indicators soon after scroll
        if (_scrollController.offset > 5) {
          setState(() {
            _showElevation = true;
          });
        }
      } else {
        // for when scroll is pulling down

        // for when title lage only
        if (widget.isLarge) {
          // increase title size when scrolling down
          // only when not refreshable
          if (!widget.refreshable) {
            setState(() {
              _titleScale = 1 + (-_scrollController.offset * 0.001);
              _showSmallTitle =
                  false; // make sure title is hidden on faster scroll
            });
          }
        } else {
          // for  only when title is small
        }
        // do not show elevation indicators
        if (_showElevation) {
          setState(() {
            _showElevation = false;
          });
        }
      }
      // global for scrolling up and down
      if (widget.isLarge) {
        if (_scrollController.offset > 30) {
          setState(() {
            _showSmallTitle = true;
          });
        } else if (_scrollController.offset < 10) {
          setState(() {
            _showSmallTitle = false;
          });
        }
      }
      if (widget.refreshable) {
        setState(() {
          _loadAmount = -0.2 + -(_scrollController.offset * 0.012);
        });
        if (_loadAmount >= 1) {
          setState(() {
            _shouldLoad = true;
          });
        }
      }
    });
  }

  void _refreshAction() async {
    await widget.onRefresh!();
    setState(() {
      _shouldLoad = false;
      _scrollAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      left: false,
      right: false,
      child: Stack(
        children: [
          AnimatedPadding(
            duration: const Duration(milliseconds: 800),
            curve: Sprung.overDamped,
            padding: EdgeInsets.only(top: -_scrollAmount / 2),
            child: _body(context),
          ),
          _titleBar(context),
          if (widget.refreshable)
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top +
                      (widget.isLarge ? 0 : 40) +
                      (Platform.isIOS ? 0 : 10)),
              child: Align(
                alignment: Alignment.topCenter,
                child: _shouldLoad && _scrollAmount != 0
                    ? CircularProgressIndicator(color: widget.color)
                    : CircularProgressIndicator(
                        value: _loadAmount,
                        color: widget.color,
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (!notification.toString().contains("DragUpdateDetails")) {
          // user released the screen, animate the position change
          if (_scrollAmount == 0 && _shouldLoad) {
            setState(() {
              _scrollAmount = _scrollController.offset;
            });
            _refreshAction();
          }
        }
        return true;
      },
      child: ListView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: EdgeInsets.only(
                top: _barHeight - MediaQuery.of(context).padding.top),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isLarge)
                  // scalable large title
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
                    ),
                  ),
                // all children passed
                Padding(
                  padding: widget.childPadding,
                  child: Column(
                    children: widget.children,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _titleBar(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          height: _barHeight,
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? ViewColors.lightList
                  : Colors.black,
          opacity: _showElevation ? 0.7 : 0,
          blur: _showElevation ? 10 : 0,
          child: Padding(
            padding: widget.itemBarPadding,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(children: widget.leading),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(children: [
                      const Spacer(),
                      Row(children: widget.trailing),
                    ]),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedOpacity(
                      opacity: _showSmallTitle ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
                fit: StackFit.expand,
              ),
            ),
          ),
        ),
        if (_showElevation)
          const Divider(
            height: 0.5,
            indent: 0,
            endIndent: 0,
          ),
      ],
    );
  }
}
