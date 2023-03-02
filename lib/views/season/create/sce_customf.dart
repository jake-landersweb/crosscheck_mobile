import 'package:flutter/material.dart';
import 'package:crosscheck_sports/views/season/create/sce_model.dart';
import 'package:crosscheck_sports/views/season/create/sce_positions.dart';
import 'package:crosscheck_sports/views/shared/positions_create.dart';
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
    return cv.Section(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      color: dmodel.color,
      child: CustomFieldCreate(
        key: const ValueKey("scemodel.customFields"),
        color: dmodel.color,
        animateOpen: false,
        customFields: scemodel.customFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _customUserF(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return cv.Section(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      color: dmodel.color,
      helperView: (context) {
        return Column(
          children: const [
            cv.Section(
              "Custom User Fields",
              child: Text(
                  "These fields will show up on every user you add to your season, and give you the ability to add either a word, number, or true/false fields to users. These are completly customizable, and let you keep track of information on each user that may be lacking."),
            )
          ],
        );
      },
      child: CustomFieldCreate(
        key: const ValueKey("scemodel.customUserFields"),
        color: dmodel.color,
        animateOpen: false,
        valueLabelText: "Default Value",
        customFields: scemodel.customUserFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _eventCustomF(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return cv.Section(
      "Custom Fields for Events Template",
      headerPadding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      color: dmodel.color,
      helperView: (context) {
        return Column(
          children: const [
            cv.Section(
              "Event Fields Template",
              child: Text(
                  "These are a tricky concept at first, but these control custom fields that will be auto added to every event you create, incase there is a field you always want present. But don't worry, you can add or remove these fields on each specific event."),
            )
          ],
        );
      },
      child: CustomFieldCreate(
        key: const ValueKey("scemodel.eventCustomFieldsTemplate"),
        color: dmodel.color,
        animateOpen: false,
        customFields: scemodel.eventCustomFieldsTemplate,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _eventCustomUserF(
      BuildContext context, DataModel dmodel, SCEModel scemodel) {
    return cv.Section(
      "Custom Fields for Event Users Template",
      headerPadding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
      color: dmodel.color,
      animateOpen: false,
      helperView: (context) {
        return Column(
          children: const [
            cv.Section(
              "Event Fields Template",
              child: Text(
                  "These are a tricky concept at first, but these fields will be auto added to every event user that is created. This gives you a convenient way to store fields you want on every event without having to add them each time. But don't worry, these fields can be added or removed on an event by event basis."),
            )
          ],
        );
      },
      child: CustomFieldCreate(
        key: const ValueKey("scemodel.eventCustomUserFieldsTemplate"),
        color: dmodel.color,
        animateOpen: false,
        valueLabelText: "Default Value",
        customFields: scemodel.eventCustomUserFieldsTemplate,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }
}
