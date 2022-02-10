import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pnflutter/theme/root.dart';
import 'package:pnflutter/views/stats/team/root.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import 'root.dart';
import '../root.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter/services.dart';

class EventDetail extends StatefulWidget {
  const EventDetail({
    Key? key,
    required this.event,
    required this.email,
    required this.team,
    required this.season,
    required this.isUpcoming,
  }) : super(key: key);

  final Event event;
  final String email;
  final Team team;
  final Season season;
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
  void dispose() {
    _users = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      // isLarge: true,
      backgroundColor: widget.event.getColor()?.withOpacity(0.5) ??
          CustomColors.backgroundColor(context),
      color: _accentColor(),
      leading: [
        cv.BackButton(color: _accentColor()),
      ],
      trailing: [_editButton(context, dmodel)],
      itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      titlePadding: const EdgeInsets.only(left: 8),
      refreshable: true,
      childPadding: const EdgeInsets.fromLTRB(16, 16, 16, 48),
      onRefresh: () => _getUsers(dmodel),
      children: [
        _body(context, dmodel),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _title(context, dmodel),
        const SizedBox(height: 16),
        _detail(context, dmodel),
        const SizedBox(height: 16),
        if (widget.event.customFields.isNotEmpty)
          Column(
            children: [
              _customFields(context, dmodel),
              const SizedBox(height: 16),
            ],
          ),
        if (widget.event.eventType == 1)
          Column(
            children: [
              _stats(context, dmodel),
              const SizedBox(height: 16),
            ],
          ),
        if (widget.event.hasAttendance)
          Column(
            children: [
              _statusCounts(context),
              const SizedBox(height: 16),
            ],
          ),
        _participants(context, dmodel)
      ],
    );
  }

  Widget _title(BuildContext context, DataModel dmodel) {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.event.getTitle(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: widget.event.eventColor.isEmpty
                  ? CustomColors.textColor(context)
                  : Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _detail(BuildContext context, DataModel dmodel) {
    List<Widget> detailChildren = _detailChildren(context, dmodel);
    switch (detailChildren.length) {
      case 1:
        return Column(
          children: detailChildren,
        );
      default:
        if (detailChildren.length % 2 == 0) {
          return AlignedGridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            itemCount: detailChildren.length,
            itemBuilder: (context, index) {
              return detailChildren[index];
            },
          );
        } else {
          return Column(
            children: [
              AlignedGridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                itemCount: detailChildren.length - 1,
                itemBuilder: (context, index) {
                  return detailChildren[index];
                },
              ),
              const SizedBox(
                height: 16,
              ),
              detailChildren.last,
            ],
          );
        }
    }
  }

  List<Widget> _detailChildren(BuildContext context, DataModel dmodel) {
    return [
      _detailCell(
          Icons.calendar_today_rounded,
          "${widget.event.getDate()} ${widget.event.getTime()}",
          "Date & Time",
          dmodel),
      if (widget.event.eventType == 1)
        _detailCell(
            Icons.person,
            widget.event.getOpponentTitle(widget.team.teamId),
            "Opponent",
            dmodel),
      if (!widget.event.eventLocation.name.isEmpty())
        _detailCell(
            Icons.place, widget.event.eventLocation.name!, "Location", dmodel),
      if (!widget.event.eventLocation.address.isEmpty())
        _detailCell(Icons.near_me, widget.event.eventLocation.address!,
            "Address", dmodel),
      if (widget.event.eDescription.isNotEmpty)
        _detailCell(Icons.description, widget.event.eDescription, "Description",
            dmodel),
    ];
  }

  Widget _detailCell(
      IconData icon, String value, String label, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        Clipboard.setData(ClipboardData(text: value));
        print("set data");
        dmodel.setSuccess("Successfully copied!", true);
      },
      child: Container(
        width: double.infinity,
        // height: MediaQuery.of(context).size.width / 3,
        decoration: BoxDecoration(
          color: CustomColors.cellColor(context)
              .withOpacity(widget.event.eventColor.isEmpty ? 1 : 0.3),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            // mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _accentColor(),
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                icon,
                size: 40,
                color: widget.event.eventColor.isEmpty
                    ? CustomColors.textColor(context)
                    : Colors.white,
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: widget.event.eventColor.isEmpty
                              ? CustomColors.textColor(context)
                              : Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _customFields(BuildContext context, DataModel dmodel) {
    return cv.NativeList(
      color: CustomColors.cellColor(context)
          .withOpacity(widget.event.eventColor.isEmpty ? 1 : 0.3),
      children: [
        for (var i in widget.event.customFields)
          cv.LabeledCell(
            label: i.getTitle(),
            value: i.getValue(),
            textColor: widget.event.eventColor.isEmpty
                ? CustomColors.textColor(context)
                : Colors.white,
          ),
      ],
    );
  }

  Widget _stats(BuildContext context, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(
          context,
          StatsEvent(
            team: dmodel.tus!.team,
            teamUser: dmodel.tus!.user,
            season: dmodel.currentSeason!,
            seasonUser: dmodel.currentSeasonUser!,
            event: widget.event,
          ),
        );
      },
      child: cv.NativeList(
        itemPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        color: CustomColors.cellColor(context)
            .withOpacity(widget.event.eventColor.isEmpty ? 1 : 0.3),
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                color: widget.event.eventColor.isEmpty
                    ? CustomColors.textColor(context)
                    : Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Statistics",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: _accentColor(),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: widget.event.eventColor.isEmpty
                    ? CustomColors.textColor(context)
                    : Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusCounts(BuildContext context) {
    return cv.NativeList(
      itemPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      color: CustomColors.cellColor(context)
          .withOpacity(widget.event.eventColor.isEmpty ? 1 : 0.3),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _statusCountCell(context, 0, widget.event.noResponse),
            _statusCountCell(context, -1, widget.event.outCount),
            _statusCountCell(context, 2, widget.event.undecidedCount),
            _statusCountCell(context, 1, widget.event.inCount),
          ],
        ),
      ],
    );
  }

  Widget _statusCountCell(BuildContext context, int status, int count) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: CustomColors.cellColor(context)
            .withOpacity(widget.event.eventColor.isEmpty ? 1 : 0.3),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          Icon(widget.event.getStatusIcon(status),
              color: widget.event.getStatusColor(status)),
          const SizedBox(width: 4),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _participants(BuildContext context, DataModel dmodel) {
    if (widget.event.hasAttendance) {
      return cv.Section(
        _users == null
            ? ""
            : _users!.isNotEmpty
                ? "Users"
                : "",
        child: Column(
          children: [
            if (_users != null)
              for (SeasonUser i in _users!
                  .where((element) => element.eventFields!.isParticipant))
                Column(
                  children: [
                    _userRow(context, dmodel, i),
                    const SizedBox(height: 8),
                  ],
                )
            else
              for (int i = 0; i < 25; i++)
                Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: CustomColors.cellColor(context).withOpacity(
                            widget.event.eventColor.isEmpty ? 1 : 0.3),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: UserCellLoading(),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _userRow(BuildContext context, DataModel dmodel, SeasonUser user) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: CustomColors.cellColor(context)
            .withOpacity(widget.event.eventColor.isEmpty ? 1 : 0.3),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
        child: Row(
          children: [
            // user avatar cell
            Opacity(
              opacity: 0.7,
              child: UserAvatar(
                user: user,
                season: widget.season,
                diameter: 45,
                fontSize: 24,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              // child: UserCell(user: user, season: widget.season),
              child: Text(
                user.name(false),
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
            // show a message icon if the user left a message
            if (!user.eventFields!.message.isEmpty())
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: cv.BasicButton(
                  onTap: () {
                    cv.showFloatingSheet(
                      context: context,
                      builder: (context) {
                        return UserCommentSheet(
                          user: user,
                          event: widget.event,
                          email: widget.email,
                          teamId: widget.team.teamId,
                          season: widget.season,
                          completion: () {
                            // refresh user data when added reply
                            _getUsers(dmodel);
                          },
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.comment,
                    color: widget.event.eventColor.isEmpty
                        ? CustomColors.textColor(context).withOpacity(0.7)
                        : Colors.white,
                  ),
                ),
              ),
            // show their status, and only let the model open if it is them
            Opacity(
              opacity: dmodel.user!.email == user.email ? 1 : 0.5,
              child: EventUserStatus(
                email: user.email,
                status: user.eventFields!.eStatus,
                event: widget.event,
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
                          teamId: widget.team.teamId,
                          seasonId: widget.season.seasonId,
                          event: widget.event,
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
        ),
      ),
    );
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) {
      return cv.BasicButton(
        onTap: () {
          showMaterialModalBottomSheet(
            context: context,
            builder: (context) {
              return ECERoot(
                isCreate: false,
                team: widget.team,
                season: widget.season,
                teamUser: dmodel.tus!.user,
                user: dmodel.user!,
                seasonUser: dmodel.currentSeasonUser,
                event: widget.event,
              );
            },
          );
        },
        child: Text(
          "Edit",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _accentColor(),
          ),
        ),
      );
    } else {
      return Container(height: 0);
    }
  }

  Future<void> _getUsers(DataModel dmodel) async {
    await dmodel.getEventUsers(
        widget.team.teamId, widget.season.seasonId, widget.event.eventId,
        (eventUsers) {
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

  Color _accentColor() {
    return widget.event.eventColor.isEmpty
        ? CustomColors.textColor(context).withOpacity(0.5)
        : MediaQuery.of(context).platformBrightness == Brightness.light
            ? widget.event.getColor()!.darken(0.3).withOpacity(0.7)
            : widget.event.getColor()!.lighten(0.1);
  }
}
