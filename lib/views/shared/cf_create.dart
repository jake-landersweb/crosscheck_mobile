import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import '../../data/root.dart';
import 'root.dart';
import '../../custom_views/root.dart' as cv;

class CustomFieldCreate extends StatefulWidget {
  const CustomFieldCreate(
      {Key? key,
      required this.customFields,
      required this.onAdd,
      this.color = Colors.blue,
      this.isCreate = true,
      this.cellColor,
      this.enabled = true,
      this.valueLabelText = "Value"})
      : super(key: key);
  final List<DynamicField> customFields;
  final DynamicField Function() onAdd;
  final Color color;
  final bool isCreate;
  final Color? cellColor;
  final bool enabled;
  final String valueLabelText;

  @override
  _CustomFieldCreateState createState() => _CustomFieldCreateState();
}

class _CustomFieldCreateState extends State<CustomFieldCreate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cv.ListView(
          allowsDelete: widget.enabled,
          isAnimated: true,
          backgroundColor: widget.cellColor,
          childPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          onDelete: (DynamicField item) {
            setState(() {
              widget.customFields.removeWhere(
                  (element) => element.getTitle() == item.getTitle());
            });
          },
          children: widget.customFields,
          childBuilder: (BuildContext context, DynamicField item) {
            return CustomFieldField(
              item: item,
              color: widget.color,
              isCreate: widget.isCreate,
              valueLabelText: widget.valueLabelText,
            );
          },
        ),
        if (widget.isCreate)
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 16, 32, 0),
            child: cv.RoundedLabel(
              "Add New",
              color: CustomColors.cellColor(context),
              textColor: CustomColors.textColor(context),
              onTap: () {
                setState(() {
                  widget.customFields.add(widget.onAdd());
                });
              },
            ),
          ),
      ],
    );
  }
}
