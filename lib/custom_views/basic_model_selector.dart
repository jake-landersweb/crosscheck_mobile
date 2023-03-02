import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'core/root.dart' as cv;
import 'sheet.dart' as cv;
import 'dynamic_selector.dart' as cv;

class ModelSelector<T> extends StatefulWidget {
  const ModelSelector({
    Key? key,
    required this.title,
    required this.selections,
    required this.onSelection,
    required this.initialSelection,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.titles,
  }) : super(key: key);
  final String title;
  final List<T> selections;
  final Function(T) onSelection;
  final T initialSelection;
  final Color color;
  final Color textColor;
  final List<String>? titles;

  @override
  _ModelSelectorState<T> createState() => _ModelSelectorState<T>();
}

class _ModelSelectorState<T> extends State<ModelSelector<T>> {
  late T _selection;

  @override
  void initState() {
    _selection = widget.initialSelection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return cv.Sheet(
      title: widget.title,
      color: widget.color,
      icon: Icons.remove,
      child: cv.DynamicSelector<T>(
        selectorStyle: cv.DynamicSelectorStyle.list,
        selections: widget.selections,
        dismissOnTap: true,
        selectedLogic: (context, item) {
          return item == _selection;
        },
        titleBuilder: (context, item) {
          if (widget.titles != null) {
            int index = widget.selections.indexOf(item);
            return widget.titles![index];
          } else {
            return item.toString();
          }
        },
        onSelect: ((context, item) {
          setState(() {
            _selection = item;
          });
          widget.onSelection(item);
        }),
        color: widget.color,
      ),
    );
  }
}
