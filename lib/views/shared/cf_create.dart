import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import '../../data/root.dart';
import 'root.dart';
import '../../custom_views/root.dart' as cv;

class CustomFieldCreate extends StatefulWidget {
  const CustomFieldCreate({
    Key? key,
    required this.customFields,
    required this.onAdd,
    this.color = Colors.blue,
    this.isCreate = true,
    this.cellColor,
    this.enabled = true,
  }) : super(key: key);
  final List<DynamicField> customFields;
  final DynamicField Function() onAdd;
  final Color color;
  final bool isCreate;
  final Color? cellColor;
  final bool enabled;

  @override
  _CustomFieldCreateState createState() => _CustomFieldCreateState();
}

class _CustomFieldCreateState extends State<CustomFieldCreate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cv.AnimatedList<DynamicField>(
          enabled: widget.enabled,
          cellColor: widget.cellColor,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
          buttonPadding: 20,
          children: widget.customFields,
          cellBuilder: (BuildContext context, DynamicField item) {
            return CustomFieldField(
              item: item,
              color: widget.color,
              isCreate: widget.isCreate,
            );
          },
        ),
        if (widget.isCreate)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
