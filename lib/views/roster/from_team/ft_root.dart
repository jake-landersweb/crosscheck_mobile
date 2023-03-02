import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../../components/root.dart' as comp;
import 'root.dart';

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
      return cv.AppBar.sheet(
        title: "Add Team Users",
        leading: [
          cv.BackButton(
            title: "Cancel",
            color: dmodel.color,
            showText: true,
            showIcon: false,
            useRoot: true,
          ),
        ],
        trailing: [
          cv.BasicButton(
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
                    child: cv.LoadingIndicator(color: dmodel.color),
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
        ],
        children: const [FTHome()],
      );
    } else {
      return const FTHome();
    }
  }
}
