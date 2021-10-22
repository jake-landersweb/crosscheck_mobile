import 'package:flutter/material.dart';
import 'package:sprung/sprung.dart';

import 'core/root.dart' as cv;

class SegmentedPicker extends StatefulWidget {
  const SegmentedPicker({
    Key? key,
    required this.titles,
    this.selections,
    required this.onSelection,
    this.initialSelection,
  })  : assert(titles.length < 4),
        super(key: key);
  final List<String> titles;
  final List<dynamic>? selections;
  final Function(dynamic) onSelection;
  final dynamic initialSelection;

  @override
  _SegmentedPickerState createState() => _SegmentedPickerState();
}

class _SegmentedPickerState extends State<SegmentedPicker> {
  late AlignmentDirectional _currentAlignment;

  bool _showSelector = true;

  dynamic _currentSelection;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection == null) {
      _currentSelection = widget.titles[0];

      if (widget.titles.length.isEven) {
        _currentAlignment = AlignmentDirectional.centerStart;
      } else {
        _currentAlignment = AlignmentDirectional.center;
      }

      // dont show selector if nothing to show
      if (widget.titles.isEmpty) {
        _showSelector = false;
      }
    } else {
      // hadle init for selector
      _currentSelection = widget.initialSelection!;

      // set for either selection or from title depending on what user is doing
      if (widget.selections != null) {
        if (widget.selections!.contains(_currentSelection)) {
          if (widget.selections!.first == _currentSelection) {
            _currentAlignment = AlignmentDirectional.centerStart;
          } else if (widget.selections!.last == _currentSelection) {
            _currentAlignment = AlignmentDirectional.centerEnd;
          } else {
            _currentAlignment = AlignmentDirectional.center;
          }
        } else {
          _showSelector = false;
          _currentAlignment = AlignmentDirectional.center;
        }
      } else {
        if (widget.titles.contains(_currentSelection)) {
          if (widget.titles.first == _currentSelection) {
            _currentAlignment = AlignmentDirectional.centerStart;
          } else if (widget.titles.last == _currentSelection) {
            _currentAlignment = AlignmentDirectional.centerEnd;
          } else {
            _currentAlignment = AlignmentDirectional.center;
          }
        } else {
          _showSelector = false;
          _currentAlignment = AlignmentDirectional.center;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: ContinuousRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: cv.ViewColors.textColor(context).withOpacity(0.1),
      child: SizedBox(
        height: 35,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(2, 2, 2, 2),
          child: Stack(
            alignment: _currentAlignment,
            children: [
              AnimatedAlign(
                alignment: _currentAlignment,
                curve: Sprung.overDamped,
                duration: const Duration(milliseconds: 650),
                child: Material(
                  shape: ContinuousRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: cv.ViewColors.textColor(context)
                      .withOpacity(_showSelector ? 0.1 : 0),
                  child: FractionallySizedBox(
                    widthFactor: 1 / widget.titles.length,
                    child: const SizedBox(height: 33),
                  ),
                ),
              ),
              Row(
                children: [
                  for (int i = 0; i < widget.titles.length; i++)
                    Expanded(
                      child: cv.BasicButton(
                        onTap: () => _handleTap(i),
                        child: Align(
                          alignment: AlignmentDirectional.center,
                          child: Text(
                            widget.titles[i],
                            style: TextStyle(
                              fontSize: 17,
                              color: cv.ViewColors.textColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleTap(int index) {
    setState(() {
      _showSelector = true;
    });
    if (index == 0) {
      // set alignment to start
      setState(() {
        _currentAlignment = AlignmentDirectional.centerStart;
      });
    } else if (index == widget.titles.length - 1) {
      // set alignment to last
      setState(() {
        _currentAlignment = AlignmentDirectional.centerEnd;
      });
    } else {
      // set alignment to middle
      setState(() {
        _currentAlignment = AlignmentDirectional.center;
      });
    }
    // send correct feedback to parent
    widget.onSelection(widget.selections != null
        ? widget.selections![index]
        : widget.titles[index]);
  }
}
