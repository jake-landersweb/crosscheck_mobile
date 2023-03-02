import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:sprung/sprung.dart';

import 'core/root.dart';

class RefreshWrapper extends StatefulWidget {
  const RefreshWrapper({
    super.key,
    required this.child,
    required this.onRefresh,
    this.controller,
    this.topPadding = 10,
    this.color = Colors.blue,
  });
  final Widget child;
  final AsyncCallback onRefresh;
  final ScrollController? controller;
  final double topPadding;
  final Color color;

  @override
  State<RefreshWrapper> createState() => _RefreshWrapperState();
}

class _RefreshWrapperState extends State<RefreshWrapper> {
  // allow custom scroll controller
  late ScrollController _scrollController;

  // progress for loading
  double _loadAmount = 0;

  // for determining if user scrolled enough to load
  bool _shouldLoad = false;

  // for getting amount to auto scroll by
  double _scrollAmount = 0;

  @override
  void initState() {
    // set up scroll controller
    if (widget.controller == null) {
      _scrollController = ScrollController();
    } else {
      _scrollController = widget.controller!;
    }

    // add logic to scroll controller
    _scrollController.addListener(() {
      // ONLY FOR REFRESHABLE
      setState(() {
        _loadAmount = -0.2 + -(_scrollController.offset * 0.012);
      });
      // control if the view should reload when the user releases the screen
      if (_loadAmount >= 1) {
        _shouldLoad = true;
      } else {
        _shouldLoad = false;
      }
    });
    super.initState();
  }

  void _refreshAction() async {
    await widget.onRefresh();
    setState(() {
      _shouldLoad = false;
      _scrollAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        NotificationListener(
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
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              AnimatedPadding(
                duration: const Duration(milliseconds: 800),
                curve: Sprung.overDamped,
                padding: EdgeInsets.only(top: -_scrollAmount / 2),
                child: widget.child,
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: widget.topPadding,
          ),
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
    );
  }
}
