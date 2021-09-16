import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import 'root.dart';
import '../root.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({
    Key? key,
    required this.event,
    required this.email,
    required this.teamId,
    required this.seasonId,
  }) : super(key: key);

  final Event event;
  final String email;
  final String teamId;
  final String seasonId;

  @override
  _EventDetailState createState() => _EventDetailState();
}

class _EventDetailState extends State<EventDetail> {
  List<SeasonUser>? _users;

  @override
  void initState() {
    super.initState();
    _getUsers(context.read<DataModel>());
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      leading: cv.BackButton(color: dmodel.color),
      titlePadding: const EdgeInsets.only(left: 8),
      refreshable: true,
      onRefresh: () => _getUsers(dmodel),
      color: dmodel.color,
      children: [
        // title
        Row(
          children: [
            Expanded(
              child: Text(
                widget.event.getTitle(),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        // event details
        _details(context),
        _userList(context, dmodel),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _details(BuildContext context) {
    return cv.Section(
      "Details",
      child: cv.NativeList(
        itemPadding: const EdgeInsets.all(10),
        children: [
          EventMetaDataCell(
              title: "${widget.event.getDate()}  ${widget.event.getTime()}",
              icon: Icons.calendar_today),
          if (widget.event.eType == 1)
            EventMetaDataCell(
                title: widget.event.getOpponentTitle(widget.teamId),
                icon: Icons.person),
          if (widget.event.eType == 1)
            EventMetaDataCell(
              title: "",
              icon: Icons.sports_score,
              child: Row(
                children: [
                  Text(
                    "${widget.event.homeTeam!.score}",
                    style: TextStyle(
                      color: CustomColors.textColor(context)
                          .withOpacity(widget.event.isHome() ? 1 : 0.5),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    " - ",
                    style: TextStyle(
                      color: CustomColors.textColor(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    "${widget.event.awayTeam!.score}",
                    style: TextStyle(
                      color: CustomColors.textColor(context)
                          .withOpacity(widget.event.isHome() ? 0.5 : 1),
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                  Text(widget.event.isHome() ? "  (Home)" : "  (Away)",
                      style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          if (!widget.event.eLocation.isEmpty())
            EventMetaDataCell(
                title: widget.event.eLocation!, icon: Icons.near_me),
          if (!widget.event.eLink.isEmpty())
            EventMetaDataCell(title: widget.event.eLink!, icon: Icons.link),
          if (!widget.event.eDescription.isEmpty())
            EventMetaDataCell(
                title: widget.event.eDescription!, icon: Icons.description),
        ],
      ),
    );
  }

  Widget _userList(BuildContext context, DataModel dmodel) {
    if (widget.event.hasAttendance) {
      return cv.Section(
        "Attendance",
        child: cv.NativeList(
          children: [
            if (_users != null)
              for (SeasonUser i in _users!)
                Row(
                  children: [
                    // user avatar cell
                    Expanded(
                      child: UserCell(user: i),
                    ),
                    // show a message icon if the user left a message
                    if (!i.eventFields!.message.isEmpty())
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: cv.BasicButton(
                          onTap: () {
                            cv.showFloatingSheet(
                              context: context,
                              builder: (context) {
                                return UserCommentSheet(
                                  user: i,
                                  event: widget.event,
                                  email: widget.email,
                                  teamId: widget.teamId,
                                  seasonId: widget.seasonId,
                                  completion: () {
                                    // refresh user data when added reply
                                    _getUsers(dmodel);
                                  },
                                );
                              },
                            );
                          },
                          child: const Icon(Icons.chat),
                        ),
                      ),
                    // show their status, and only let the model open if it is them
                    EventUserStatus(
                      email: i.email,
                      status: i.eventFields!.eStatus,
                      showTitle: false,
                      onTap: () {
                        if ((i.email == widget.email &&
                                stringToDate(widget.event.eDate)
                                    .isAfter(DateTime.now())) ||
                            dmodel.currentSeasonUser!.isSeasonAdmin()) {
                          cv.showFloatingSheet(
                            context: context,
                            builder: (context) {
                              return StatusSelectSheet(
                                email: i.email,
                                teamId: widget.teamId,
                                seasonId: widget.seasonId,
                                eventId: widget.event.eventId,
                                completion: () {
                                  _getUsers(dmodel);
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ],
                )
            else
              for (int i = 0; i < 10; i++) const UserCellLoading(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> _getUsers(DataModel dmodel) async {
    await dmodel.getEventUsers(
        widget.teamId, widget.seasonId, widget.event.eventId, (users) {
      setState(() {
        _users = users;
      });
    });
  }
}
