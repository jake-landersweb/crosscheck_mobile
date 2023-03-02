import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;

class CustomFieldSelector extends StatefulWidget {
  const CustomFieldSelector({
    super.key,
    required this.customFields,
    required this.onSelect,
    this.initialSelection,
    this.closeOnSelect = true,
  }) : assert(customFields.length > 0);
  final List<CustomField> customFields;
  final void Function(CustomField) onSelect;
  final CustomField? initialSelection;
  final bool closeOnSelect;

  @override
  State<CustomFieldSelector> createState() => _CustomFieldSelectorState();
}

class _CustomFieldSelectorState extends State<CustomFieldSelector> {
  CustomField? _selection;

  @override
  void initState() {
    if (widget.initialSelection != null) {
      _selection = widget.initialSelection!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Select Field",
      color: dmodel.color,
      child: cv.DynamicSelector<CustomField>(
        color: dmodel.color,
        selections: widget.customFields,
        selectorStyle: cv.DynamicSelectorStyle.list,
        selectedLogic: (context, item) {
          return item == _selection;
        },
        onSelect: (context, item) {
          setState(() {
            if (item == _selection) {
              _selection = null;
            } else {
              _selection = item;
            }
            widget.onSelect(item);
          });
          if (widget.closeOnSelect) {
            Navigator.of(context).pop();
          }
        },
        titleBuilder: (context, item) {
          return item.getTitle();
        },
      ),
    );
  }
}
