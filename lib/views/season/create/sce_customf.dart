import 'package:flutter/material.dart';
import 'package:pnflutter/client/api_helpers.dart';
import 'package:pnflutter/views/season/create/sce_model.dart';
import 'package:pnflutter/views/season/create/sce_positions.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../menu/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import '../../shared/root.dart';
import 'root.dart';

class SCECustomF extends StatefulWidget {
  const SCECustomF({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _SCECustomFState createState() => _SCECustomFState();
}

class _SCECustomFState extends State<SCECustomF> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    SCEModel scemodel = Provider.of<SCEModel>(context);
    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: [
        _customF(context, dmodel, scemodel),
        const SizedBox(height: 16),
        _customUserF(context, dmodel, scemodel),
        const SizedBox(height: 16),
        _eventCustomF(context, dmodel, scemodel),
        const SizedBox(height: 16),
        _eventCustomUserF(context, dmodel, scemodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _customF(BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Custom Fields",
        child: CustomFieldCreate(
          color: dmodel.color,
          customFields: scemodel.customFields,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ),
    );
  }

  Widget _customUserF(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Custom User Fields",
        child: CustomFieldCreate(
          color: dmodel.color,
          customFields: scemodel.customUserFields,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ),
    );
  }

  Widget _eventCustomF(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Custom Fields for Events Template",
        child: CustomFieldCreate(
          color: dmodel.color,
          customFields: scemodel.eventCustomFieldsTemplate,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ),
    );
  }

  Widget _eventCustomUserF(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: cv.Section(
        "Custom Fields for Event Users Template",
        child: CustomFieldCreate(
          color: dmodel.color,
          customFields: scemodel.eventCustomUserFieldsTemplate,
          onAdd: () {
            return CustomField(title: "", type: "S", value: "");
          },
        ),
      ),
    );
  }
}
