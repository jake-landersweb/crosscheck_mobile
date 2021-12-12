import 'package:flutter/material.dart';
import '../../data/root.dart';
import 'root.dart';
import '../../custom_views/root.dart' as cv;

class CustomFieldCreate extends StatefulWidget {
  const CustomFieldCreate({
    Key? key,
    required this.customFields,
    required this.onAdd,
  }) : super(key: key);
  final List<DynamicField> customFields;
  final DynamicField Function() onAdd;

  @override
  _CustomFieldCreateState createState() => _CustomFieldCreateState();
}

class _CustomFieldCreateState extends State<CustomFieldCreate> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cv.AnimatedList<DynamicField>(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          buttonPadding: 20,
          children: widget.customFields,
          cellBuilder: (BuildContext context, DynamicField item) {
            return CustomFieldField(item: item);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: cv.BasicButton(
            onTap: () {
              setState(() {
                widget.customFields.add(widget.onAdd());
              });
            },
            child: const cv.NativeList(
              children: [
                SizedBox(
                  height: 40,
                  child: Center(
                    child: Text(
                      "Add new",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
