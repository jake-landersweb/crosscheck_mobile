import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'core/root.dart' as cv;
import 'sheet.dart' as cv;

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
      child: Column(
        children: [
          const SizedBox(height: 16),
          for (int index = 0; index < widget.selections.length; index++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  _cell(
                      context,
                      widget.selections[index],
                      widget.titles != null
                          ? widget.titles![index]
                          : widget.selections[index].toString()),
                  if (widget.selections[index] != widget.selections.last)
                    const SizedBox(height: 16),
                ],
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _cell(BuildContext context, T val, String title) {
    return cv.BasicButton(
      onTap: () {
        setState(() {
          _selection = val;
        });
        widget.onSelection(val);
      },
      child: cv.RoundedLabel(
        title,
        color: val == _selection ? widget.color : Colors.transparent,
        textColor: val == _selection
            ? widget.textColor
            : CustomColors.textColor(context),
      ),
    );
  }
}
