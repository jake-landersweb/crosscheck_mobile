import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../data/root.dart';
import 'root.dart';
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class CustomFieldCreate extends StatefulWidget {
  const CustomFieldCreate({
    Key? key,
    required this.customFields,
    required this.onAdd,
    this.color = Colors.blue,
    this.isCreate = true,
    this.cellColor,
    this.enabled = true,
    this.valueLabelText = "Value",
    this.childPadding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
    this.horizontalPadding = 16,
    this.animateOpen = true,
  }) : super(key: key);
  final List<CustomField> customFields;
  final CustomField Function() onAdd;
  final Color color;
  final bool isCreate;
  final Color? cellColor;
  final bool enabled;
  final String valueLabelText;
  final EdgeInsets childPadding;
  final double horizontalPadding;
  final bool animateOpen;

  @override
  _CustomFieldCreateState createState() => _CustomFieldCreateState();
}

class _CustomFieldCreateState extends State<CustomFieldCreate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cv.ListView<CustomField>(
          allowsDelete: widget.enabled,
          isAnimated: true,
          backgroundColor: widget.cellColor,
          horizontalPadding: widget.horizontalPadding,
          childPadding: widget.childPadding,
          animateOpen: widget.animateOpen,
          equality: (item1, item2) {
            return item1.id == item2.id;
          },
          onDelete: (item) async {
            setState(() {
              widget.customFields.removeWhere(
                (element) => element.id == item.id,
              );
            });
          },
          children: widget.customFields,
          childBuilder: (context, item) {
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
            child: comp.SubActionButton(
              title: "Add New",
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
