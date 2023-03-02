import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import '../../extras/root.dart';
import '../../data/root.dart';

class PollList extends StatefulWidget {
  const PollList({
    Key? key,
    required this.polls,
    required this.team,
    required this.season,
    required this.teamUser,
    this.seasonUser,
    this.showFutureLine = false,
  }) : super(key: key);
  final List<Poll> polls;
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;
  final bool showFutureLine;

  @override
  State<PollList> createState() => _PollListState();
}

class _PollListState extends State<PollList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.polls.length; i++)
          Column(
            children: [
              PollCell(
                poll: widget.polls[i],
                team: widget.team,
                season: widget.season,
                teamUser: widget.teamUser,
                seasonUser: widget.seasonUser,
              ),
              if (widget.polls[i].pollId != widget.polls.last.pollId)
                const SizedBox(height: 16),
              if (widget.polls[i].pollId != widget.polls.last.pollId &&
                  widget.polls[i].getDateTime().isAfter(DateTime.now()) &&
                  widget.polls[i + 1].getDateTime().isBefore(DateTime.now()))
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 0.5,
                            width: double.infinity,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            "Past",
                            style: TextStyle(
                                color: CustomColors.textColor(context)
                                    .withOpacity(0.5),
                                fontWeight: FontWeight.w400,
                                fontSize: 14),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 0.5,
                            width: double.infinity,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16)
                  ],
                )
            ],
          ),
      ],
    );
  }
}
