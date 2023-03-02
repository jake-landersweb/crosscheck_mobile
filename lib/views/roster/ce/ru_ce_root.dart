import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import '../../components/root.dart' as comp;

class RUCERoot extends StatefulWidget {
  const RUCERoot({
    Key? key,
    required this.team,
    this.season,
    this.user,
    required this.isCreate,
    this.onFunction,
    this.onUserSave,
    this.teamToSeason = false,
    this.isSheet = false,
    this.useRoot = false,
  }) : super(key: key);
  final Team team;
  final Season? season;
  final SeasonUser? user;
  final bool isCreate;
  final Future<void> Function(Map<String, dynamic>)? onFunction;
  final Function(SeasonUser user)? onUserSave;
  final bool teamToSeason;
  final bool isSheet;
  final bool useRoot;

  @override
  _RUCERootState createState() => _RUCERootState();
}

class _RUCERootState extends State<RUCERoot> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<RUCEModel>(
      create: (_) => widget.teamToSeason
          ? RUCEModel.teamToSeason(widget.team, widget.season, widget.user!)
          : widget.isCreate
              ? widget.season == null
                  ? RUCEModel.createTeam(widget.team)
                  : RUCEModel.createSeason(widget.team, widget.season!)
              : widget.season == null
                  ? RUCEModel.editTeam(widget.team, widget.user!)
                  : RUCEModel.editSeason(
                      widget.team, widget.season, widget.user!),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return _body(context, dmodel);
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    RUCEModel rmodel = Provider.of<RUCEModel>(context);
    return cv.AppBar(
      hasSafeArea: !widget.isSheet,
      barHeight: widget.isSheet ? 60 : 40,
      leadingAlignment: widget.isSheet ? Alignment.centerLeft : null,
      titleAlignment: widget.isSheet ? Alignment.center : null,
      trailingAlignment: widget.isSheet ? Alignment.centerRight : null,
      title: widget.teamToSeason
          ? "Edit Season Fields"
          : widget.isCreate
              ? "Create User"
              : "Edit User",
      isLarge: !widget.isSheet,
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: [
        if (widget.teamToSeason)
          cv.BackButton(
            color: dmodel.color,
            title: "Cancel",
            showIcon: false,
            showText: true,
          )
        else
          cv.BackButton(
            color: dmodel.color,
            showText: widget.teamToSeason ? false : true,
            showIcon: widget.teamToSeason ? true : false,
            title: "Cancel",
            useRoot: widget.useRoot,
          ),
      ],
      trailing: [
        cv.BasicButton(
          onTap: () => _onFunc(context, dmodel, rmodel),
          child: _isLoading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: cv.LoadingIndicator(color: dmodel.color),
                )
              : Text(
                  widget.teamToSeason
                      ? "Save"
                      : rmodel.isCreate
                          ? "Create"
                          : "Confirm",
                  style: TextStyle(
                    color: _isValid(rmodel)
                        ? dmodel.color
                        : CustomColors.textColor(context).withOpacity(0.5),
                    fontSize: 18,
                    fontWeight:
                        _isValid(rmodel) ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
        ),
      ],
      children: [
        // user fields
        if (!rmodel.isTeamToSeason) const RUCEUser(),
        if (rmodel.season != null) const RUCESeason() else const RUCETeam(),
      ],
    );
  }

  Future<void> _onFunc(
      BuildContext context, DataModel dmodel, RUCEModel rmodel) async {
    if (rmodel.isValid()) {
      if (widget.teamToSeason) {
        SeasonUser user = SeasonUser.empty();
        user.email = rmodel.email;
        user.userFields = rmodel.userFields;
        user.teamFields = rmodel.teamFields;
        user.seasonFields = rmodel.seasonFields!;
        widget.onUserSave!(user);
        Navigator.of(context).pop();
      } else {
        if (!_isLoading) {
          setState(() {
            _isLoading = true;
          });
          await widget.onFunction!(rmodel.createBody());
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else {
      dmodel.addIndicator(IndicatorItem.error(rmodel.validationText()));
    }
  }

  bool _isValid(RUCEModel rmodel) {
    if (rmodel.email.isEmpty) {
      return false;
    } else if (rmodel.userFields.firstName.isEmpty()) {
      return false;
    } else {
      return true;
    }
  }
}
