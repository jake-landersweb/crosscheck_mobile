import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;

class PollCell extends StatefulWidget {
  const PollCell({
    Key? key,
    required this.poll,
    required this.team,
    required this.season,
    required this.teamUser,
    this.seasonUser,
  }) : super(key: key);
  final Poll poll;
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;

  @override
  State<PollCell> createState() => _PollCellState();
}

class _PollCellState extends State<PollCell> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Container(
      decoration: BoxDecoration(
        color: widget.poll.getColor() ?? CustomColors.cellColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // title
            cv.BasicButton(
              onTap: () {
                cv.Navigate(
                  context,
                  PollDetail(
                    poll: widget.poll,
                    team: widget.team,
                    season: widget.season,
                    teamUser: widget.teamUser,
                    seasonUser: widget.seasonUser,
                  ),
                );
              },
              child: Text(
                widget.poll.title,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  color: widget.poll.color.isEmpty()
                      ? CustomColors.textColor(context)
                      : Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // date and time
            _detailCell(
                Icons.calendar_today_outlined, widget.poll.getDate(), dmodel),
            _detailCell(Icons.schedule_outlined, widget.poll.getTime(), dmodel),
            // description
            if (widget.poll.description.isNotEmpty)
              _detailCell(
                  Icons.description_outlined, widget.poll.description, dmodel),
            if (widget.poll.userIsOn)
              // poll button
              Column(
                children: [
                  const SizedBox(height: 16),
                  PollButton(
                    poll: widget.poll,
                    team: widget.team,
                    season: widget.season,
                    teamUser: widget.teamUser,
                    seasonUser: widget.seasonUser,
                    didChange: () {},
                    hasBorder: true,
                    height: 40,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // Color _accentColor() {
  //   return widget.poll.color == null
  //       ? CustomColors.textColor(context).withOpacity(0.5)
  //       : Theme.of(context).brightness == Brightness.light
  //           ? widget.poll.getColor()!.darken(0.3).withOpacity(0.7)
  //           : widget.poll.getColor()!.lighten(0.1);
  // }

  Widget _detailCell(IconData icon, String value, DataModel dmodel) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 35,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Icon(
                icon,
                color: dmodel.color,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: (widget.poll.color.isEmpty()
                            ? CustomColors.textColor(context)
                            : Colors.white)
                        .withOpacity(0.5),
                  ),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
