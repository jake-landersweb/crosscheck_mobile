import 'dart:io';

import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';
import '../components/root.dart' as comp;

class UserCommentSheet extends StatefulWidget {
  const UserCommentSheet({
    Key? key,
    required this.user,
    required this.event,
    required this.email,
    required this.team,
    required this.season,
    required this.completion,
  }) : super(key: key);
  final SeasonUser user;
  final Event event;
  final String email;
  final Team team;
  final Season season;
  final VoidCallback completion;

  @override
  _UserCommentSheetState createState() => _UserCommentSheetState();
}

class _UserCommentSheetState extends State<UserCommentSheet> {
  late List<StatusReply> _replies;

  late TextEditingController controller;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _replies = widget.user.eventFields!.statusReplies;
    controller = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Comment",
      color: dmodel.color,
      leading: [
        cv.BackButton(
          title: "Done",
          showText: true,
          useRoot: true,
          color: dmodel.color,
          showIcon: false,
        )
      ],
      children: [
        cv.Section(
          "Message",
          child: cv.ListView<Widget>(
            horizontalPadding: 0,
            children: [
              Text(
                widget.user.eventFields?.message ?? "",
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
        ),
        cv.Section(
          "Comments",
          child: cv.ListView<StatusReply>(
            childPadding: const EdgeInsets.all(8),
            horizontalPadding: 0,
            childBuilder: (context, value) {
              return _userCommentCell(context, value);
            },
            children: _replies,
          ),
        ),
        const SizedBox(height: 16),
        _replyCell(context)
      ],
    );
  }

  Widget _userCommentCell(BuildContext context, StatusReply reply) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // avatar
        RosterAvatar(name: reply.name, seed: reply.email, size: 50),
        const SizedBox(width: 8),
        // reply body
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // name and date
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // name
                  Expanded(
                    child: Text(
                      reply.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // formatted date
                  Text(
                    reply.getFormattedDate(),
                    style: TextStyle(
                      color: CustomColors.textColor(context).withOpacity(0.5),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(reply.message),
            ],
          ),
        ),
      ],
    );
  }

  Widget _replyCell(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            cv.TextField2(
              fieldPadding: EdgeInsets.zero,
              controller: controller,
              maxLines: 5,
              showBackground: false,
              labelText: "New Comment",
              onChanged: (value) {},
            ),
          ],
        ),
        Padding(
            padding: const EdgeInsets.all(16.0),
            child: comp.ActionButton(
              title: "Post Reply",
              color: dmodel.color,
              isLoading: _isLoading,
              onTap: () {
                _replyToStatus(context, dmodel);
              },
            )),
      ],
    );
  }

  Future<void> _replyToStatus(BuildContext context, DataModel dmodel) async {
    if (!_isLoading) {
      if (controller.text == "") {
        dmodel.addIndicator(IndicatorItem.error("Reply cannot be empty"));
      } else {
        setState(() {
          _isLoading = true;
        });
        Map<String, dynamic> body = {
          "email": widget.user.email,
          "senderEmail": dmodel.user!.email,
          "date": dateToString(DateTime.now()),
          "name": dmodel.currentSeasonUser!.name(widget.team.showNicknames),
          "message": controller.text,
          "title": widget.event.getTitle(dmodel.tus!.team.title),
        };
        await dmodel.replyToStatus(widget.team.teamId, widget.season.seasonId,
            widget.event.eventId, body, () {
          setState(() {
            _replies.add(
              StatusReply(
                date: dateToString(DateTime.now()),
                message: controller.text,
                name: dmodel.currentSeasonUser!.name(widget.team.showNicknames),
                email: dmodel.user!.email,
              ),
            );
            controller.text = "";
          });
          widget.completion();
        }).then((value) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
  }
}
