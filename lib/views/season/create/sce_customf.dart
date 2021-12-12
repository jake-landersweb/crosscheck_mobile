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
    required this.model,
    required this.team,
  }) : super(key: key);
  final SCEModel model;
  final Team team;

  @override
  _SCECustomFState createState() => _SCECustomFState();
}

class _SCECustomFState extends State<SCECustomF> {
  @override
  void initState() {
    widget.model.index += 1;
    super.initState();
  }

  @override
  void dispose() {
    widget.model.index -= 1;
    super.dispose();
  }

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        cv.AppBar(
          title: "Customization",
          isLarge: false,
          backgroundColor: CustomColors.backgroundColor(context),
          childPadding: const EdgeInsets.fromLTRB(0, 15, 0, 45),
          itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
          leading: [
            cv.BackButton(
              color: dmodel.color,
            )
          ],
          color: dmodel.color,
          children: [_body(context, dmodel)],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: widget.model.isCreate
              ? _next(context, dmodel)
              : _updateButton(context, dmodel),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        widget.model.status(context, dmodel),
        const SizedBox(height: 16),
        _customF(context, dmodel),
        const SizedBox(height: 16),
        _customUserF(context, dmodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _customF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      child: CustomFieldCreate(
        customFields: widget.model.customFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _customUserF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      child: CustomFieldCreate(
        customFields: widget.model.customUserFields,
        onAdd: () {
          return CustomUserField(title: "", type: "S", defaultValue: "");
        },
      ),
    );
  }

  Widget _next(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          cv.Navigate(
              context, SCEStats(model: widget.model, team: widget.team));
        },
        child: Material(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(35)),
          color: CustomColors.cellColor(context),
          child: const SizedBox(
            height: cellHeight,
            child: Center(
              child: Text(
                "Next",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _updateButton(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          _update(context, dmodel);
        },
        child: Material(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(35)),
          color: dmodel.color,
          child: SizedBox(
            height: cellHeight,
            child: Center(
              child: _isLoading
                  ? const cv.LoadingIndicator(color: Colors.white)
                  : const Text(
                      "Update Season",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _update(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });

    List<String> teamUserEmails = [];

    // create email list
    for (var i in widget.model.teamUsers) {
      teamUserEmails.add(i.email);
    }

    Map<String, dynamic> body = {
      "title": widget.model.title,
      "website": widget.model.website,
      "seasonNote": widget.model.seasonNote,
      "showNicknames": widget.model.showNicknames,
      "customFields": widget.model.customFields.map((e) => e.toJson()).toList(),
      "positions": widget.model.positions.toJson(),
      "teamUserEmails": teamUserEmails,
      "date": dateToString(DateTime.now()),
    };

    Map<String, dynamic> userFields = {
      "customUserFields":
          widget.model.customUserFields.map((e) => e.toJson()).toList(),
    };

    // await dmodel.createSeason(widget.team.teamId, body, userFields, () {
    //   // success, get out of widget
    //   Navigator.of(context).pop();
    //   Navigator.of(context).pop();
    //   Navigator.of(context).pop();
    //   Navigator.of(context).pop();
    //   // get tus
    //   dmodel.teamUserSeasonsGet(widget.team.teamId, dmodel.user!.email, (tus) {
    //     dmodel.setTUS(tus);
    //   });
    // });
    setState(() {
      _isLoading = false;
    });
  }
}
