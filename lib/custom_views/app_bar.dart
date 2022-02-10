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
    this.title = "",
    this.children = const [],
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
    this.backgroundColor,
    this.canScroll = true,
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
  final Color? backgroundColor;
  final bool canScroll;

  @override
  _AppBarState createState() => _AppBarState();
}

class _AppBarState extends State<AppBar> {
  final double _barHeight = 40;

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

  late String _title;

  @override
  void initState() {
    super.initState();
    if (widget.title.length > 25) {
      _title = widget.title.substring(0, 25) + "...";
    } else {
      _title = widget.title;
    }
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
        /** When scroll is pushing up */

        // for when title large
        if (widget.isLarge) {
          // set title scale to 1
          if (_titleScale != 1) {
            setState(() {
              _titleScale = 1;
            });
          }
        }
      } else {
        /** for when scroll is pulling down */

        // increse the title scale when pulling down and
        // FOR ONLY LARGE
        // FOR NOT REFRESHABLE
        if (widget.isLarge && !widget.refreshable) {
          setState(() {
            _titleScale = 1 + (-_scrollController.offset * 0.0005);
            _showSmallTitle =
                false; // make sure title is hidden on faster scroll
          });
        }
      }
      /** EVERYTHING BELOW IS GLOBAL FOR SCROLLING UP AND DOWN */

      // show elevation indicators soon after scroll
      // FOR BOTH SMALL AND LARGE
      if (_scrollController.offset > 10) {
        setState(() {
          _showElevation = true;
        });
      } else {
        setState(() {
          _showElevation = false;
        });
      }

      // FOR CONTROLLING SHOWING AND HIDING SMALL TITLE
      // ONLY WHEN LARGE
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

      // ONLY FOR REFRESHABLE
      if (widget.refreshable) {
        setState(() {
          _loadAmount = -0.2 + -(_scrollController.offset * 0.012);
        });
        // control if the view should reload when the user releases the screen
        if (_loadAmount >= 1) {
          _shouldLoad = true;
        } else {
          _shouldLoad = false;
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
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
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
                        10),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: _scrollAmount != 0
                      ? CircularProgressIndicator(color: widget.color)
                      : CircularProgressIndicator(
                          value: _loadAmount,
                          color: widget.color,
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return NotificationListener(
      onNotification: (ScrollNotification notification) {
        if (!notification.toString().contains("DragUpdateDetails") &&
            !notification.toString().contains("direction")) {
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
      child: widget.canScroll
          ? ListView(
              controller: _scrollController,
              physics: Platform.isIOS
                  ? const AlwaysScrollableScrollPhysics()
                  : const BouncingScrollPhysics(),
              children: _children(context),
            )
          : Column(
              children: widget.children,
            ),
    );
  }

  List<Widget> _children(BuildContext context) {
    return [
      Padding(
        padding: EdgeInsets.only(top: _barHeight),
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
                    _title,
                    // style: const TextStyle(
                    //   fontWeight: FontWeight.w700,
                    //   fontSize: 40,
                    // ),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
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
    ];
  }

  Widget _titleBar(BuildContext context) {
    return Column(
      children: [
        GlassContainer(
          // height: _barHeight,
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor: widget.backgroundColor ??
              (MediaQuery.of(context).platformBrightness == Brightness.light
                  ? ViewColors.lightList
                  : Colors.black),
          opacity: _showElevation ? 0.7 : 0,
          blur: _showElevation ? 10 : 0,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              SizedBox(
                height: _barHeight,
                child: Padding(
                  padding: widget.itemBarPadding,
                  child: Align(
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
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
                              _title,
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
            ],
          ),
        ),
        // for showing divider between bar and view
        AnimatedOpacity(
          opacity: _showElevation ? 1 : 0,
          duration: const Duration(milliseconds: 300),
          child: const Divider(
            height: 0.5,
            indent: 0,
            endIndent: 0,
          ),
        ),
      ],
    );
  }
}
