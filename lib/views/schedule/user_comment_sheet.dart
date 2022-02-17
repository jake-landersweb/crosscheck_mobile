import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';
import '../../client/root.dart';
import '../../extras/root.dart';

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
    return cv.Sheet(
      color: dmodel.color,
      closeText: "Close",
      title: widget.user.name(widget.team.showNicknames),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 400),
        child: _body(context),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      children: [
        cv.Section(
          "Message",
          headerPadding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
          child: Text(
            widget.user.eventFields?.message ?? "",
            style: const TextStyle(fontSize: 18),
          ),
        ),
        cv.Section(
          "Comments",
          headerPadding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
          child: cv.NativeList(
            itemPadding: const EdgeInsets.all(8),
            color: CustomColors.textColor(context).withOpacity(0.1),
            children: [
              for (StatusReply i in _replies) _userCommentCell(i),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _replyCell(context)
      ],
    );
  }

  Widget _userCommentCell(StatusReply reply) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.subdirectory_arrow_right,
                      color: CustomColors.textColor(context).withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(reply.message,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
              Text(
                reply.name,
                style: TextStyle(
                  color: CustomColors.textColor(context).withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
        // const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              reply.date.getDate(),
              style: TextStyle(
                color: CustomColors.textColor(context).withOpacity(0.7),
              ),
            ),
            Text(
              reply.date.getTime(),
              style: TextStyle(
                color: CustomColors.textColor(context).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _replyCell(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Column(
      children: [
        cv.TextField(
          fieldPadding: EdgeInsets.zero,
          controller: controller,
          showBackground: false,
          labelText: "Type here ...",
          validator: (value) {},
          onChanged: (value) {},
        ),
        const SizedBox(height: 16),
        cv.BasicButton(
          onTap: () {
            _replyToStatus(context, dmodel);
          },
          child: cv.RoundedLabel(
            "Reply",
            color: dmodel.color,
            textColor: Colors.white,
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }

  void _replyToStatus(BuildContext context, DataModel dmodel) async {
    if (!_isLoading) {
      if (controller.text == "") {
        dmodel.setError("Reply cannot be empty", true);
      } else {
        setState(() {
          _isLoading = true;
        });
        await dmodel.replyToStatus(
            widget.team.teamId,
            widget.season.seasonId,
            widget.event.eventId,
            widget.user.email,
            dmodel.currentSeasonUser!.name(widget.team.showNicknames),
            controller.text,
            widget.event.getTitle(), () {
          setState(() {
            _replies.add(
              StatusReply(
                date: dateToString(DateTime.now()),
                message: controller.text,
                name: dmodel.currentSeasonUser!.name(widget.team.showNicknames),
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
