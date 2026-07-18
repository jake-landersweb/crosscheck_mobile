import 'package:flutter/material.dart';
import 'dynamic_selector.dart' as cv;
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';

class ModelSelector<T> extends StatefulWidget {
  const ModelSelector({
    super.key,
    required this.title,
    required this.selections,
    required this.onSelection,
    required this.initialSelection,
    this.color = Colors.blue,
    this.textColor = Colors.white,
    this.titles,
  });
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
    return HeaderBar.sheet(
      title: widget.title,
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
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
