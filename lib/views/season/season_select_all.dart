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
    return cv.Sheet(
      title: "All Seasons",
      color: dmodel.color,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (_isLoading)
                Center(child: cv.LoadingIndicator(color: dmodel.color))
              else if (_seasons == null)
                Center(
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
              else
                cv.ListView<Widget>(
                  childPadding: EdgeInsets.zero,
                  horizontalPadding: 0,
                  showStyling: false,
                  isAnimated: true,
                  animateOpen: true,
                  children: [
                    if (_seasons!.any((element) => element.seasonStatus == 2) &&
                        ((dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) ||
                            dmodel.tus!.user.isTeamAdmin()))
                      cv.Section(
                        "Future",
                        child: _selectorWrapper(
                          context,
                          dmodel,
                          _seasons!
                              .where((element) => element.seasonStatus == 2)
                              .toList(),
                          false,
                        ),
                      ),
                    if (_seasons!.any((element) => element.seasonStatus == 1))
                      cv.Section(
                        "Active",
                        child: _selectorWrapper(
                          context,
                          dmodel,
                          _seasons!
                              .where((element) => element.seasonStatus == 1)
                              .toList(),
                          false,
                        ),
                      ),
                    if (_seasons!.any((element) => element.seasonStatus == -1))
                      cv.Section(
                        "Past",
                        child: _selectorWrapper(
                          context,
                          dmodel,
                          _seasons!
                              .where((element) => element.seasonStatus == -1)
                              .toList(),
                          true,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _selectorWrapper(BuildContext context, DataModel dmodel,
      List<Season> seasons, bool isPrevious) {
    return cv.DynamicSelector<Season>(
      selections: seasons,
      titleBuilder: (context, season) {
        return season.title;
      },
      selectedLogic: (context, season) {
        if (season.title == (dmodel.currentSeason?.title ?? "")) {
          return true;
        } else {
          return false;
        }
      },
      color: dmodel.color,
      selectorStyle: cv.DynamicSelectorStyle.list,
      selectorInline: true,
      onSelect: (context, season) => widget.onSelect(season, isPrevious),
    );
  }
}
