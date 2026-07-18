import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/section.dart';

class ECECustom extends StatefulWidget {
  const ECECustom({super.key});

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
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _customFields(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return XCSection(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
      child: CustomFieldCreate(
        color: dmodel.color,
        animateOpen: false,
        customFields: ecemodel.event.customFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _customUserFields(
      BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return XCSection(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
      color: dmodel.color,
      helperView: (context) {
        return Column(
          children: const [
            XCSection(
              "Custom User Fields",
              child: Text(
                  "These fields will show up on every user you add to your event, and give you the ability to add either a word, number, or true/false fields to users. These are completly customizable, and let you keep track of information on each user that may be lacking."),
            )
          ],
        );
      },
      child: CustomFieldCreate(
        color: dmodel.color,
        animateOpen: false,
        valueLabelText: "Default Value",
        customFields: ecemodel.event.customUserFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }
}
