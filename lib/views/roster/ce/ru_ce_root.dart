import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'root.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/loading_indicator.dart';

class RUCERoot extends StatefulWidget {
  const RUCERoot({
    super.key,
    required this.team,
    this.season,
    this.user,
    required this.isCreate,
    this.onFunction,
    this.onUserSave,
    this.teamToSeason = false,
    this.isSheet = false,
    this.useRoot = false,
  });
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
    return HeaderBar(
      title: widget.teamToSeason
          ? "Edit Season Fields"
          : widget.isCreate
              ? "Create User"
              : "Edit User",
      isLarge: !widget.isSheet,
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      leading: XCActionButton.cancel(),
      trailing: Clickable(
        onTap: () => _onFunc(context, dmodel, rmodel),
        child: _isLoading
            ? SizedBox(
                height: 25,
                width: 25,
                child: XCLoadingIndicator(color: dmodel.color),
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
      child: Column(
        children: [
          // user fields
          if (!rmodel.isTeamToSeason) const RUCEUser(),
          if (rmodel.season != null) const RUCESeason() else const RUCETeam(),
        ],
      ),
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
