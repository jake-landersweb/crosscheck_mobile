import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/views/polls/polls_ce/root.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:crosscheck_sports/components/layer/header_bar.dart';

class SeasonPolls extends StatefulWidget {
  const SeasonPolls({
    super.key,
    required this.team,
    required this.season,
    required this.teamUser,
    this.seasonUser,
  });
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;

  @override
  State<SeasonPolls> createState() => _SeasonPollsState();
}

class _SeasonPollsState extends State<SeasonPolls> {
  late bool _isLoading;

  @override
  void initState() {
    if (context.read<DataModel>().polls == null) {
      _isLoading = true;
      _fetchPolls(context.read<DataModel>());
    } else {
      _isLoading = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return HeaderBar(
      title: "Polls",
      isLarge: true,
      refreshable: true,
      leading: cv.BackButton(color: dmodel.color),
      onRefresh: () => _fetchPolls(dmodel),
      trailing: cv.BasicButton(
        onTap: () {
          showSnappingSheet(
              context: context,
              child: PollsRoot(
                team: dmodel.tus!.team,
                season: dmodel.currentSeason!,
                users: dmodel.seasonUsers!,
                onAction: () async => await _fetchPolls(dmodel),
              ),
            );
        },
        child: Icon(
          Icons.add,
          color: dmodel.color,
          size: 28,
        ),
      ),
      child: _body(context, dmodel),
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    if (_isLoading) {
      return const PollsLoading();
    } else if (dmodel.polls == null) {
      return cv.NoneFound(
        "There was an issue getting the polls",
        asset: "assets/svg/not_found.svg",
        color: dmodel.color,
      );
    } else if (dmodel.polls!.isEmpty) {
      return cv.NoneFound(
        "There are no polls on this season",
        color: dmodel.color,
      );
    } else {
      return PollList(
        polls: dmodel.polls!.reversed.toList(),
        team: widget.team,
        season: widget.season,
        teamUser: widget.teamUser,
        seasonUser: widget.seasonUser,
        showFutureLine: true,
      );
    }
  }

  Future<void> _fetchPolls(DataModel dmodel) async {
    await dmodel.getAllPolls(
        widget.team.teamId, widget.season.seasonId, dmodel.user!.email, (p0) {
      dmodel.setPolls(p0);
    });
    setState(() {
      _isLoading = false;
    });
  }
}
