import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'root.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/core/loading_indicator.dart';

class FTRoot extends StatefulWidget {
  const FTRoot({
    super.key,
    required this.team,
    required this.season,
    this.wrapInBar = true,
    required this.onCompletion,
  });
  final Team team;
  final Season season;
  final bool wrapInBar;
  final Future<void> Function(
      String teamId, String seasonId, Map<String, dynamic> body) onCompletion;

  @override
  State<FTRoot> createState() => _FTRootState();
}

class _FTRootState extends State<FTRoot> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<FTModel>(
      create: (_) => FTModel(widget.team, widget.season, dmodel),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return _wrapper(context, dmodel);
      },
    );
  }

  Widget _wrapper(BuildContext context, DataModel dmodel) {
    FTModel ftmodel = Provider.of<FTModel>(context);

    if (widget.wrapInBar) {
      return HeaderBar.sheet(
      title: "Add Team Users",
      leading: XCActionButton.cancel(
      onTap: () => Navigator.of(context, rootNavigator: true).pop(),
    ),
      trailing: Clickable(
          onTap: () async {
            if (ftmodel.selectedUsers.isNotEmpty) {
              setState(() {
                _isLoading = true;
              });
              await widget.onCompletion(
                ftmodel.team.teamId,
                ftmodel.season.seasonId,
                ftmodel.createBody(),
              );
              setState(() {
                _isLoading = false;
              });
            }
          },
          child: _isLoading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: XCLoadingIndicator(color: dmodel.color),
                )
              : Text(
                  "Add",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: ftmodel.selectedUsers.isEmpty
                        ? FontWeight.w400
                        : FontWeight.w600,
                    color: ftmodel.selectedUsers.isEmpty
                        ? CustomColors.textColor(context).withOpacity(0.5)
                        : dmodel.color,
                  ),
                ),
        ),
      child: const FTHome(),
    );
    } else {
      return const FTHome();
    }
  }
}
