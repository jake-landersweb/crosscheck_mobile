import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TCECUstom extends StatefulWidget {
  const TCECUstom({Key? key}) : super(key: key);

  @override
  _TCECUstomState createState() => _TCECUstomState();
}

class _TCECUstomState extends State<TCECUstom> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    TCEModel tcemodel = Provider.of<TCEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _customF(context, tcemodel, dmodel),
        _customUserF(context, tcemodel, dmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _customF(BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      child: CustomFieldCreate(
        customFields: tcemodel.team.customFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _customUserF(
      BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return cv.Section(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      child: CustomFieldCreate(
        valueLabelText: "Default Value",
        customFields: tcemodel.team.customUserFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }
}
