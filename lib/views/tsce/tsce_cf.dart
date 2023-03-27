import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/custom_views/timezone_select.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class TSCECustomFields extends StatefulWidget {
  const TSCECustomFields({
    super.key,
    required this.fields,
    required this.onCompletion,
    this.closeOnCompletion = true,
    required this.valueLabelText,
  });
  final List<CustomField> fields;
  final void Function(List<CustomField> fields) onCompletion;
  final bool closeOnCompletion;
  final String valueLabelText;

  @override
  State<TSCECustomFields> createState() => _TSCECustomFieldsState();
}

class _TSCECustomFieldsState extends State<TSCECustomFields> {
  late List<CustomField> _fields;

  @override
  void initState() {
    _fields = [for (var i in widget.fields) i.clone()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);

    return cv.AppBar.sheet(
      title: "Edit Fields",
      childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
      leading: [
        cv.CloseButton(
          title: "Cancel",
          showIcon: false,
          showText: true,
          useRoot: true,
          color: dmodel.color,
        ),
      ],
      trailing: [
        cv.BasicButton(
          onTap: () {
            widget.onCompletion(_fields);
            if (widget.closeOnCompletion) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
          child: Text(
            "Save",
            style: TextStyle(
              fontSize: 18,
              color: dmodel.color,
            ),
          ),
        )
      ],
      children: [
        CustomFieldCreate(
          key: const ValueKey("this will never be seen muahahah"),
          color: dmodel.color,
          animateOpen: false,
          valueLabelText: "Default Value",
          customFields: _fields,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ],
    );
  }
}
