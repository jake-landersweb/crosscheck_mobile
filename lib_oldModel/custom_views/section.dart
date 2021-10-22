import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

import 'core/root.dart' as cv;

class Section extends StatefulWidget {
  const Section(
    this.title, {
    Key? key,
    required this.child,
    this.allowsCollapse = false,
    this.initOpen = false,
  }) : super(key: key);

  final String title;
  final Widget child;
  final bool? allowsCollapse;
  final bool? initOpen;

  @override
  _SectionState createState() => _SectionState();
}

class _SectionState extends State<Section> with TickerProviderStateMixin {
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
      );
      _animation = CurvedAnimation(
        parent: _controller,
        curve: Sprung.overDamped,
      );
      // open container if is expanded
      if (widget.initOpen ?? false) {
        _controller.forward();
      }
      _isOpen = widget.initOpen ?? false;
    }
  }

  _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
      setState(() {
        _isOpen = true;
      });
    } else {
      _controller.animateBack(0,
          duration: const Duration(milliseconds: 550),
          curve: Sprung.overDamped);
      setState(() {
        _isOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.allowsCollapse ?? false) {
      return Theme(
        data: Theme.of(context).copyWith(
          dividerColor:
              MediaQuery.of(context).platformBrightness == Brightness.light
                  ? Colors.black.withOpacity(0.1)
                  : Colors.white.withOpacity(0.2),
          dividerTheme: const DividerThemeData(
            thickness: 0.5,
            indent: 16,
            endIndent: 0,
          ),
        ),
        child: _collapseableSection(context),
      );
    } else {
      return _defaultSection(context);
    }
  }

  Widget _defaultSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
          child: Row(
            children: [
              _title(context),
              // so this and collapsable section are the same height above view
              const Opacity(
                opacity: 0,
                child: Icon(Icons.chevron_left),
              )
            ],
          ),
        ),
        widget.child,
      ],
    );
  }

  Widget _collapseableSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: _title(context),
            ),
            const Expanded(
              child: Divider(height: 0.5),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 4, 15, 0),
              child: cv.BasicButton(
                onTap: () {
                  _toggleContainer();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 8),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 550),
                    curve: Sprung.overDamped,
                    turns: _isOpen ? 0.25 : -0.25,
                    child: const Icon(Icons.chevron_left),
                  ),
                ),
              ),
            ),
          ],
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

  Widget _title(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Text(
        widget.title.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }
}
