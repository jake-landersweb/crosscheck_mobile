import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pnflutter/views/schedule/event_edit/event_create_edit.dart';
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
    required this.isUpcoming,
  }) : super(key: key);

  final Event event;
  final String email;
  final String teamId;
  final String seasonId;
  final bool isUpcoming;

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
      actions: [_editButton(context, dmodel)],
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
        if (_users != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: cv.NativeList(
              children: [
                _userStatusCounts(context, dmodel),
              ],
            ),
          ),
        if (widget.event.hasAttendance) _participants(context, dmodel),
        if (widget.event.hasAttendance) _nonParticipants(context, dmodel),
        const SizedBox(height: 48),
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
          if (widget.event.eventType == 1)
            EventMetaDataCell(
                title: widget.event.getOpponentTitle(widget.teamId),
                icon: Icons.person),
          if (widget.event.eventType == 1)
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
          if (!((widget.event.eventLocation?.name).isEmpty()))
            EventMetaDataCell(
                title: widget.event.eventLocation!.name!, icon: Icons.near_me),
          if (!widget.event.eLink.isEmpty())
            EventMetaDataCell(title: widget.event.eLink!, icon: Icons.link),
          if (!widget.event.eDescription.isEmpty())
            EventMetaDataCell(
                title: widget.event.eDescription!, icon: Icons.description),
        ],
      ),
    );
  }

  Widget _userStatusCounts(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _userStatusCountCell(context, -1, widget.event.outCount),
          _userStatusCountCell(context, 1, widget.event.inCount),
          _userStatusCountCell(context, 2, widget.event.undecidedCount),
          _userStatusCountCell(context, 0, widget.event.noResponse),
        ],
      ),
    );
  }

  Widget _userStatusCountCell(BuildContext context, int status, int value) {
    return Row(
      children: [
        Icon(_getIcon(status), color: _getColor(status)),
        const SizedBox(width: 8),
        Text(
          "$value",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ],
    );
  }

  Widget _participants(BuildContext context, DataModel dmodel) {
    if (widget.event.hasAttendance) {
      return cv.Section(
        "Participants - ${_users?.where((element) => element.eventFields?.isParticipant == true).length ?? ""}",
        child: cv.NativeList(
          children: [
            if (_users != null)
              for (SeasonUser i in _users!
                  .where((element) => element.eventFields!.isParticipant))
                _userRow(context, dmodel, i)
            else
              for (int i = 0; i < 25; i++) const UserCellLoading(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _nonParticipants(BuildContext context, DataModel dmodel) {
    if (widget.event.hasAttendance) {
      return cv.Section(
        "Non-Participants - ${_users?.where((element) => element.eventFields?.isParticipant == false).length ?? ""}",
        child: cv.NativeList(
          children: [
            if (_users != null)
              for (SeasonUser i in _users!
                  .where((element) => !element.eventFields!.isParticipant))
                _userRow(context, dmodel, i)
            else
              for (int i = 0; i < 25; i++) const UserCellLoading(),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _userRow(BuildContext context, DataModel dmodel, SeasonUser user) {
    return Row(
      children: [
        // user avatar cell
        Expanded(
          child: UserCell(user: user),
        ),
        // show a message icon if the user left a message
        if (!user.eventFields!.message.isEmpty())
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: cv.BasicButton(
              onTap: () {
                cv.showFloatingSheet(
                  context: context,
                  builder: (context) {
                    return UserCommentSheet(
                      user: user,
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
        Opacity(
          opacity: dmodel.user!.email == user.email ? 1 : 0.5,
          child: EventUserStatus(
            email: user.email,
            status: user.eventFields!.eStatus,
            showTitle: false,
            onTap: () {
              if ((user.email == widget.email &&
                      stringToDate(widget.event.eDate)
                          .isAfter(DateTime.now())) ||
                  dmodel.currentSeasonUser!.isSeasonAdmin()) {
                cv.showFloatingSheet(
                  context: context,
                  builder: (context) {
                    return StatusSelectSheet(
                      email: user.email,
                      teamId: widget.teamId,
                      seasonId: widget.seasonId,
                      eventId: widget.event.eventId,
                      isUpcoming: widget.isUpcoming,
                      completion: () {
                        _getUsers(dmodel);
                      },
                    );
                  },
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) {
      return cv.BasicButton(
        onTap: () {
          cv.Navigate(
            context,
            EventCreateEdit(
              isCreate: false,
              teamId: widget.teamId,
              seasonId: widget.seasonId,
              initialEvent: widget.event,
              users: (_users != null) ? _users : null,
              completion: () {
                // reload the schedule
                dmodel.reloadHomePage(
                    widget.teamId, widget.seasonId, widget.email, true);
                // go back a screen
                Navigator.of(context).pop();
              },
            ),
          );
        },
        child: Text("Edit",
            style: TextStyle(
              fontSize: 18,
              color: dmodel.color,
            )),
      );
    } else {
      return Container(height: 0);
    }
  }

  Future<void> _getUsers(DataModel dmodel) async {
    await dmodel.getEventUsers(
        widget.teamId, widget.seasonId, widget.event.eventId, (eventUsers) {
      List<SeasonUser> seasonUsers = List.from(dmodel.seasonUsers!);

      List<SeasonUser> users = [];

      // loop through season users and compose list
      for (var i in eventUsers) {
        SeasonUser seasonUser = seasonUsers
            .firstWhere((element) => element.email == i.email, orElse: () {
          return SeasonUser.empty();
        });
        seasonUser.updateEventFields(i);
        users.add(seasonUser);
      }
      setState(() {
        _users = users;
      });
    });
  }

  IconData _getIcon(int status) {
    switch (status) {
      case 0:
        return Icons.remove_circle_outline;
      case -1:
        return Icons.cancel;
      case 1:
        return Icons.check_circle;
      case 2:
        return Icons.help_outline;
      default:
        return Icons.remove_circle_outline;
    }
  }

  Color _getColor(int status) {
    switch (status) {
      case 0:
        return Colors.grey;
      case -1:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return const Color.fromRGBO(235, 197, 9, 1);
      default:
        return Colors.grey;
    }
  }
}
