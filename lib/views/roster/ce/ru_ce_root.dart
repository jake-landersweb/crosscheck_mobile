import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import 'package:pnflutter/extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';

class RUCERoot extends StatefulWidget {
  const RUCERoot({
    Key? key,
    required this.team,
    this.season,
    this.user,
    required this.isCreate,
    required this.onFunction,
    this.hasBackButton = false,
  }) : super(key: key);
  final Team team;
  final Season? season;
  final SeasonUser? user;
  final bool isCreate;
  final Future<void> Function(Map<String, dynamic>) onFunction;
  final bool hasBackButton;

  @override
  _RUCERootState createState() => _RUCERootState();
}

class _RUCERootState extends State<RUCERoot> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<RUCEModel>(
      create: (_) => widget.isCreate
          ? widget.season == null
              ? RUCEModel.createTeam(widget.team)
              : RUCEModel.createSeason(widget.team, widget.season!)
          : widget.season == null
              ? RUCEModel.editTeam(widget.team, widget.user!)
              : RUCEModel.editSeason(widget.team, widget.season, widget.user!),
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
      title: widget.isCreate ? "Create User" : "Edit User",
      isLarge: true,
      itemBarPadding:
          EdgeInsets.fromLTRB(widget.hasBackButton ? 8 : 15, 0, 15, 8),
      refreshable: false,
      backgroundColor: CustomColors.backgroundColor(context),
      color: dmodel.color,
      leading: [
        cv.BackButton(
          color: dmodel.color,
          showText: widget.hasBackButton ? false : true,
          showIcon: widget.hasBackButton ? true : false,
          title: "Cancel",
        ),
      ],
      children: [
        // user fields
        const RUCEUser(),
        const RUCETeam(),
        if (rmodel.season != null) const RUCESeason(),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _create(context, dmodel, rmodel),
        ),
      ],
    );
  }

  Widget _create(BuildContext context, DataModel dmodel, RUCEModel rmodel) {
    return cv.RoundedLabel(
      rmodel.isCreate ? "Create" : "Edit",
      color: dmodel.color,
      textColor: Colors.white,
      onTap: () => _onFunc(context, dmodel, rmodel),
      isLoading: _isLoading,
    );
  }

  Future<void> _onFunc(
      BuildContext context, DataModel dmodel, RUCEModel rmodel) async {
    if (rmodel.isValid()) {
      if (!_isLoading) {
        setState(() {
          _isLoading = true;
        });
        await widget.onFunction(rmodel.createBody());
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      dmodel.addIndicator(IndicatorItem.error(rmodel.validationText()));
    }
  }
}
