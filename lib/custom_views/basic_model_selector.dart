import 'package:flutter/material.dart';
import 'core/root.dart' as cv;

class ModelSelector<T> extends StatefulWidget {
  const ModelSelector(
      {Key? key,
      required this.title,
      required this.selections,
      required this.onSelection,
      required this.initialSelection,
      this.color = Colors.blue})
      : super(key: key);
  final String title;
  final List<T> selections;
  final Function(T) onSelection;
  final T initialSelection;
  final Color color;

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
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: double.infinity,
          height: 50,
          color: MediaQuery.of(context).platformBrightness == Brightness.light
              ? Colors.black.withOpacity(0.1)
              : Colors.white.withOpacity(0.1),
          child: Stack(
            alignment: AlignmentDirectional.center,
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(children: [
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: cv.BasicButton(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: widget.color,
                      ),
                    ),
                  ),
                ),
              ])
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (T val in widget.selections)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: [
                _cell(context, val),
                if (val != widget.selections.last) const SizedBox(height: 16),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _cell(BuildContext context, T val) {
    return cv.BasicButton(
      onTap: () {
        setState(() {
          _selection = val;
        });
        widget.onSelection(val);
      },
      child: cv.RoundedLabel(
        val.toString(),
        color: val == _selection ? widget.color : Colors.transparent,
      ),
    );
  }
}