import 'package:flutter/material.dart';
import 'package:pnflutter/views/season/create/sce_model.dart';
import 'package:pnflutter/views/season/create/sce_positions.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';

class SCERoot extends StatefulWidget {
  const SCERoot({
    Key? key,
    required this.team,
    required this.isCreate,
    this.season,
  }) : super(key: key);
  final Team team;
  final bool isCreate;
  final Season? season;

  @override
  _SCERootState createState() => _SCERootState();
}

class _SCERootState extends State<SCERoot> {
  late SCEModel _model;

  @override
  void initState() {
    _model = SCEModel(widget.isCreate);
    if (!widget.isCreate) {
      if (widget.season == null) {
        throw Exception("isCreate cannot be false when Season is null");
      } else {
        _model.title = widget.season!.title;
        _model.website = widget.season!.website;
        _model.seasonNote = widget.season!.seasonNote;
        _model.showNicknames = widget.season!.showNicknames;
        _model.positions = TeamPositions.of(widget.season!.positions);
        _model.customFields = List.of(widget.season!.customFields);
        _model.customUserFields = List.of(widget.season!.customUserFields);
      }
    }
    _model.positions = TeamPositions.of(widget.team.positions);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        cv.AppBar(
          title: _model.isCreate ? "Create Season" : "Edit Season",
          isLarge: false,
          backgroundColor: CustomColors.backgroundColor(context),
          childPadding: const EdgeInsets.fromLTRB(0, 15, 0, 45),
          leading: [
            cv.BackButton(
              color: dmodel.color,
              title: "Cancel",
              showIcon: false,
              showText: true,
            )
          ],
          color: dmodel.color,
          children: [_body(context, dmodel)],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 48.0),
          child: _next(context, dmodel),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _model.status(context, dmodel),
        const SizedBox(height: 16),
        _required(context, dmodel),
        const SizedBox(height: 16),
        _basicInfo(context, dmodel),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _required(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Required",
        child: cv.NativeList(
          children: [
            SizedBox(
              height: cellHeight,
              child: cv.TextField(
                labelText: "Title",
                initialvalue: _model.title,
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    _model.title = value;
                  });
                },
                validator: (value) {},
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _basicInfo(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Basic Info",
        child: cv.NativeList(
          children: [
            SizedBox(
              height: cellHeight,
              child: cv.TextField(
                initialvalue: _model.website,
                labelText: "Website (url)",
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    _model.website = value;
                  });
                },
                validator: (value) {},
              ),
            ),
            SizedBox(
              height: cellHeight,
              child: cv.TextField(
                initialvalue: _model.seasonNote,
                labelText: "Season Note",
                showBackground: false,
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                onChanged: (value) {
                  setState(() {
                    _model.seasonNote = value;
                  });
                },
                validator: (value) {},
              ),
            ),
            cv.LabeledWidget(
              "Show Nicknames",
              height: cellHeight,
              child: FlutterSwitch(
                value: _model.showNicknames,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: dmodel.color,
                onToggle: (value) {
                  setState(() {
                    _model.showNicknames = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _next(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.BasicButton(
        onTap: () {
          if (_model.title.isEmpty) {
            dmodel.setError("Title cannot be blank", true);
          } else {
            cv.Navigate(
                context, SCEPositions(model: _model, team: widget.team));
          }
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
}
