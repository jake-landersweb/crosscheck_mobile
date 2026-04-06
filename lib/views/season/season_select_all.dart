import 'package:crosscheck_sports/components/core/list_group.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../client/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../components/root.dart' as comp;

class SeasonSelectAll extends StatefulWidget {
  const SeasonSelectAll({
    super.key,
    required this.team,
    required this.onSelect,
  });
  final Team team;
  final Function(Season season, bool isPrevious) onSelect;

  @override
  State<SeasonSelectAll> createState() => _SeasonSelectAllState();
}

class _SeasonSelectAllState extends State<SeasonSelectAll> {
  List<Season>? _seasons;
  bool _isLoading = false;

  @override
  void initState() {
    _fetchSeasons(context.read<DataModel>());
    super.initState();
  }

  Future<void> _fetchSeasons(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.getAuthenticatedSeasons(widget.team.teamId, dmodel.user!.email,
        (p0) {
      setState(() {
        _seasons = p0;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar.sheet(
      title: "All Seasons",
      trailing: XCActionButton.cancel(
        onTap: () => Navigator.of(context).pop(),
      ),
      child: _isLoading
          ? Center(child: cv.LoadingIndicator(color: dmodel.color))
          : _seasons == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Issue finding Seasons",
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: comp.SubActionButton(
                          title: "Retry",
                          onTap: () => _fetchSeasons(dmodel),
                        ),
                      )
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_seasons!
                            .any((element) => element.seasonStatus == 2) &&
                        ((dmodel.currentSeasonUser?.isSeasonAdmin() ??
                                false) ||
                            dmodel.tus!.user.isTeamAdmin()))
                      _buildGroup(
                        context, dmodel, "Future",
                        _seasons!
                            .where((element) => element.seasonStatus == 2)
                            .toList(),
                        false,
                      ),
                    if (_seasons!
                        .any((element) => element.seasonStatus == 1))
                      _buildGroup(
                        context, dmodel, "Active",
                        _seasons!
                            .where((element) => element.seasonStatus == 1)
                            .toList(),
                        false,
                      ),
                    if (_seasons!
                        .any((element) => element.seasonStatus == -1))
                      _buildGroup(
                        context, dmodel, "Past",
                        _seasons!
                            .where((element) => element.seasonStatus == -1)
                            .toList(),
                        true,
                      ),
                  ],
                ),
    );
  }

  Widget _buildGroup(BuildContext context, DataModel dmodel, String title,
      List<Season> seasons, bool isPrevious) {
    bool isSelected(Season s) =>
        s.seasonId == (dmodel.currentSeason?.seasonId ?? "");
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: XCListGroup(
        title: title,
        items: seasons
            .map((season) => XCListGroupItem(
                  title: season.title,
                  trailing: isSelected(season)
                      ? Icon(Icons.check_rounded,
                          color: dmodel.color, size: 20)
                      : null,
                  onTap: () => widget.onSelect(season, isPrevious),
                ))
            .toList(),
      ),
    );
  }
}
