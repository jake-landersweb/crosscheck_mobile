import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import '../../../custom_views/root.dart' as cv;

class PollButton extends StatefulWidget {
  const PollButton({
    Key? key,
    required this.poll,
    required this.team,
    required this.season,
    required this.teamUser,
    this.seasonUser,
    required this.didChange,
    this.hasBorder,
    this.height,
  }) : super(key: key);
  final Poll poll;
  final Team team;
  final Season season;
  final SeasonUserTeamFields teamUser;
  final SeasonUser? seasonUser;
  final VoidCallback didChange;
  final bool? hasBorder;
  final double? height;

  @override
  State<PollButton> createState() => _PollButtonState();
}

class _PollButtonState extends State<PollButton> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.BasicButton(
      onTap: () {
        if (widget.poll.isFuture()) {
          if (widget.seasonUser != null) {
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return PollSheet(
                  poll: widget.poll,
                  team: widget.team,
                  season: widget.season,
                  email: widget.seasonUser!.email,
                  onCompletion: () async {
                    // fetch polls
                    await dmodel.getAllPolls(widget.team.teamId,
                        widget.season.seasonId, dmodel.user!.email, (p0) {
                      dmodel.setPolls(p0);
                    });
                    widget.didChange();
                  },
                );
              },
            );
          }
        } else {
          dmodel.addIndicator(IndicatorItem.error("Cannot answer past polls"));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: widget.poll.userSelections.isEmpty
              ? CustomColors.sheetCell(context)
              : dmodel.color.withOpacity(0.3),
          border: Border.all(
              color: CustomColors.textColor(context).withOpacity(0.1),
              width: widget.hasBorder ?? false ? 1 : 0),
        ),
        height: widget.height ?? 50,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.poll.userSelections.isEmpty
                      ? "Answer Poll"
                      : "Response Recorded",
                  style: TextStyle(
                    color: widget.poll.userSelections.isEmpty
                        ? CustomColors.textColor(context)
                        : dmodel.color,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
              Icon(
                widget.poll.userSelections.isEmpty ? Icons.close : Icons.done,
                color: widget.poll.userSelections.isEmpty
                    ? Colors.red[300]
                    : dmodel.color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
