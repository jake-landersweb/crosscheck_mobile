import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/header_bar.dart';

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

    return HeaderBar.sheet(
      title: "Edit Fields",
      horizontalPadding: 0.0,
      bottomPadding: 48.0,
      leading: cv.CloseButton(
        title: "Cancel",
        showIcon: false,
        showText: true,
        useRoot: true,
        color: dmodel.color,
      ),
      trailing: cv.BasicButton(
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
      ),
      child: CustomFieldCreate(
        key: const ValueKey("this will never be seen muahahah"),
        color: dmodel.color,
        animateOpen: false,
        valueLabelText: "Default Value",
        customFields: _fields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }
}
