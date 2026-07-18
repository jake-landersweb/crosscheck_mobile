import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/section.dart';

class TCECUstom extends StatefulWidget {
  const TCECUstom({super.key});

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
    return XCSection(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      color: dmodel.color,
      helperView: (context) {
        return Column(
          children: const [
            XCSection(
              "Custom Fields",
              child: Text(
                  "Custom fields will show up on your team page to all users as static fields. Put any information you feel is lacking in app about your team."),
            )
          ],
        );
      },
      child: CustomFieldCreate(
        customFields: tcemodel.team.customFields,
        animateOpen: false,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _customUserF(
      BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return XCSection(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: true,
      color: dmodel.color,
      helperView: (context) {
        return Column(
          children: const [
            XCSection(
              "Custom User Fields",
              child: Text(
                  "These fields will show up on every user you add to your team, and give you the ability to add either a word, number, or true/false fields to users. These are completly customizable, and let you keep track of information on each user that may be lacking."),
            )
          ],
        );
      },
      child: CustomFieldCreate(
        valueLabelText: "Default Value",
        animateOpen: false,
        customFields: tcemodel.team.customUserFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }
}
