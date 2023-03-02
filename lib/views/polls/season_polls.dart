import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/views/polls/polls_ce/root.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;

class SeasonPolls extends StatefulWidget {
  const SeasonPolls({
    Key? key,
    required this.team,
    required this.season,
    required this.teamUser,
    this.seasonUser,
  }) : super(key: key);
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
    return cv.AppBar(
      title: "Polls",
      isLarge: true,
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
      refreshable: true,
      onRefresh: () => _fetchPolls(dmodel),
      trailing: [
        cv.BasicButton(
          onTap: () {
            cv.cupertinoSheet(
                context: context,
                wrapInNavigator: true,
                builder: (context) {
                  return PollsRoot(
                    team: dmodel.tus!.team,
                    season: dmodel.currentSeason!,
                    users: dmodel.seasonUsers!,
                    onAction: () async => await _fetchPolls(dmodel),
                  );
                });
          },
          child: Icon(
            Icons.add,
            color: dmodel.color,
            size: 28,
          ),
        )
      ],
      color: dmodel.color,
      children: [
        _body(context, dmodel),
      ],
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
