import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

/// A titled section of content in the new UI style.
///
/// Replaces the legacy `cv.Section` from `custom_views/section.dart`.
/// Supports an optional collapsible body and an optional helper view that
/// opens in a snapping sheet.
///
/// Legacy parameters [headerPadding], [color], [textColor], and [animateOpen]
/// are accepted for call-site compatibility; the header always uses the
/// theme's standardized section typography.
class XCSection extends StatefulWidget {
  const XCSection(
    this.title, {
    super.key,
    required this.child,
    this.allowsCollapse = false,
    this.initOpen = false,
    this.headerPadding = const EdgeInsets.fromLTRB(16, 8, 0, 4),
    this.helperTitle,
    this.helperView,
    this.color = Colors.blue,
    this.animateOpen = true,
    this.textColor,
  });

  final String title;
  final Widget child;
  final bool? allowsCollapse;
  final bool? initOpen;
  final EdgeInsets headerPadding;
  final String? helperTitle;
  final Widget Function(BuildContext)? helperView;
  final Color color;
  final bool animateOpen;
  final Color? textColor;

  @override
  State<XCSection> createState() => _XCSectionState();
}

class _XCSectionState extends State<XCSection> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late bool _isOpen;

  @override
  void initState() {
    super.initState();
    if (widget.allowsCollapse ?? false) {
      _controller = AnimationController(
        duration: const Duration(milliseconds: 550),
        vsync: this,
        value: (widget.initOpen ?? false)
            ? 1
            : widget.animateOpen
                ? 0
                : 1,
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Sprung.overDamped,
      );
      if ((widget.initOpen ?? false) && widget.animateOpen) {
        _controller.forward();
      }
      _isOpen = widget.initOpen ?? false;
    }
  }

  @override
  void dispose() {
    if (widget.allowsCollapse ?? false) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _toggle() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      setState(() {
        _isOpen = true;
      });
    } else {
      _controller.animateBack(
        0,
        duration: const Duration(milliseconds: 550),
        curve: Sprung.overDamped,
      );
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allowsCollapse ?? false) {
      return _collapsibleSection(context);
    }
    return _defaultSection(context);
  }

  Widget _title(BuildContext context) {
    final theme = XCTheme.of(context);
    return Text(
      widget.title,
      style: theme.text.body.copyWith(
        color: widget.textColor ?? theme.foregroundMuted,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _defaultSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Expanded(child: _title(context)),
              if (widget.helperView != null) _helperView(context),
            ],
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _collapsibleSection(BuildContext context) {
    final theme = XCTheme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Row(
            children: [
              Expanded(child: _title(context)),
              if (widget.helperView != null) _helperView(context),
              Clickable(
                onTap: _toggle,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 550),
                    curve: Sprung.overDamped,
                    turns: _isOpen ? 0.25 : -0.25,
                    child: Icon(
                      Icons.chevron_left,
                      color: theme.foregroundMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizeTransition(
          sizeFactor: _animation,
          axis: Axis.vertical,
          child: AnimatedOpacity(
            opacity: _isOpen ? 1 : 0,
            duration: const Duration(milliseconds: 300),
            child: widget.child,
          ),
        ),
      ],
    );
  }

  Widget _helperView(BuildContext context) {
    final theme = XCTheme.of(context);
    return Clickable(
      onTap: () {
        showSnappingSheet(
          context: context,
          child: Builder(builder: (context) {
            return HeaderBar.sheet(
              title: widget.helperTitle ?? "Hints",
              trailing: XCActionButton.cancel(
                onTap: () => Navigator.of(context).pop(),
              ),
              child: widget.helperView!(context),
            );
          }),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          Icons.help_outline_outlined,
          color: theme.foregroundMuted,
        ),
      ),
    );
  }
}
