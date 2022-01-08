import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';

class ECECustom extends StatefulWidget {
  const ECECustom({Key? key}) : super(key: key);

  @override
  _ECECustomState createState() => _ECECustomState();
}

class _ECECustomState extends State<ECECustom> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _customFields(context, dmodel, ecemodel),
        _customUserFields(context, dmodel, ecemodel),
      ],
    );
  }

  Widget _customFields(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Custom Fields",
        child: CustomFieldCreate(
          color: dmodel.color,
          customFields: ecemodel.event.customFields,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ),
    );
  }

  Widget _customUserFields(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Custom User Fields",
        child: CustomFieldCreate(
          color: dmodel.color,
          customFields: ecemodel.event.customUserFields,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ),
    );
  }
}
