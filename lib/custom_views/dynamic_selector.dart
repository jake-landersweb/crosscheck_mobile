import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'segmented_picker.dart' as cv;
import 'core/basic_button.dart' as cv;
import 'floating_sheet.dart' as cv;
import 'listview.dart' as cv;
import 'sheet.dart' as cv;
import 'section.dart' as cv;

enum DynamicSelectorStyle { segmented, list, dynamic }

/// ```
/// Key? key,
/// this.title,
/// required this.selections,
/// this.titleBuilder,
/// required this.selected,
/// this.color = Colors.blue,
/// this.selectorStyle = DynamicSelectorStyle.dynamic,
/// required this.onSelect,
/// this.allowsMultiSelect = false,
/// this.selectorInline = false,
/// this.isLabeled = false,
/// ```
class DynamicSelector<T> extends StatefulWidget {
  const DynamicSelector({
    Key? key,
    this.title,
    required this.selections,
    required this.selectedLogic,
    this.titleBuilder,
    this.color = Colors.blue,
    this.selectorStyle = DynamicSelectorStyle.dynamic,
    required this.onSelect,
    this.allowsMultiSelect = false,
    this.selectorInline = true,
    this.isLabeled = false,
    this.dismissOnTap = false,
  }) : super(key: key);
  final String? title;
  final List<T> selections;
  final String Function(BuildContext context, T item)? titleBuilder;
  final bool Function(BuildContext context, T item) selectedLogic;
  final Color color;
  final DynamicSelectorStyle selectorStyle;
  final Function(BuildContext context, T item) onSelect;
  final bool allowsMultiSelect;
  final bool selectorInline;
  final bool isLabeled;
  final bool dismissOnTap;

  @override
  State<DynamicSelector<T>> createState() => _DynamicSelectorState<T>();
}

class _DynamicSelectorState<T> extends State<DynamicSelector<T>> {
  @override
  void initState() {
    // assert(widget.selections.isNotEmpty, "Selections cannot be empty");
    if (widget.selectorStyle == DynamicSelectorStyle.segmented) {
      assert(widget.selections.length < 4,
          "Segmented style only available for list lengths 2 and 3");
    }
    if (widget.isLabeled) {
      assert(
          widget.title != null, "When labeled, a title needs to be provided");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLabeled) {
      return cv.Section(
        widget.title!,
        child: _body(context),
      );
    } else {
      return _body(context);
    }
  }

  Widget _body(BuildContext context) {
    switch (widget.selectorStyle) {
      case DynamicSelectorStyle.segmented:
        return _selectorView(context, _segmentedSelector(context));
      case DynamicSelectorStyle.list:
        return _selectorView(context, _listSelector(context));
      case DynamicSelectorStyle.dynamic:
        if (widget.selections.length > 3) {
          return _selectorView(context, _segmentedSelector(context));
        } else {
          return _selectorView(context, _listSelector(context));
        }
    }
  }

  Widget _selectorView(BuildContext context, Widget child) {
    if (widget.selectorInline) {
      return child;
    } else {
      return cv.BasicButton(
        onTap: () {
          cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return cv.Sheet(
                  title: widget.title ?? "Select",
                  color: widget.color,
                  child: child,
                );
              });
        },
        child: Text(
          widget.title ?? "Select",
          style: TextStyle(
            color: CustomColors.textColor(context),
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }

  Widget _segmentedSelector(BuildContext context) {
    return Text("implement");
  }

  Widget _listSelector(BuildContext context) {
    return cv.ListView<T>(
      children: widget.selections,
      horizontalPadding: 0,
      showStyling: false,
      isAnimated: true,
      animateOpen: false,
      hasDividers: true,
      onChildTap: (context, val) {
        setState(() {
          widget.onSelect(context, val);
          if (widget.dismissOnTap) {
            Navigator.of(context).pop();
          }
        });
      },
      dividerBuilder: () {
        return const SizedBox(height: 8);
      },
      childPadding: EdgeInsets.zero,
      childBuilder: (context, val) {
        late String title;
        if (widget.titleBuilder == null) {
          title = val.toString();
        } else {
          // get index
          title = widget.titleBuilder!(context, val);
        }
        bool isSelected = widget.selectedLogic(context, val);
        TextStyle textStyle = TextStyle(
          color: isSelected
              ? widget.color
              : CustomColors.textColor(context).withOpacity(0.7),
          fontSize: 18,
          fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
        );
        BoxDecoration boxDecoration = BoxDecoration(
          color:
              isSelected ? widget.color.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : CustomColors.textColor(context).withOpacity(0.05),
          ),
        );
        return Container(
          decoration: boxDecoration,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(child: Text(title, style: textStyle)),
                if (isSelected)
                  Icon(
                    Icons.check,
                    color: widget.color,
                  )
                else
                  const Icon(Icons.check, color: Colors.transparent)
              ],
            ),
          ),
        );
      },
    );
  }
}
