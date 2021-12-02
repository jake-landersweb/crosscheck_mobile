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
    required this.teamId,
    required this.season,
    required this.completion,
  }) : super(key: key);
  final SeasonUser user;
  final Event event;
  final String email;
  final String teamId;
  final Season season;
  final VoidCallback completion;

  @override
  _UserCommentSheetState createState() => _UserCommentSheetState();
}

class _UserCommentSheetState extends State<UserCommentSheet> {
  late List<StatusReply> _replies;

  String _reply = "";

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _replies = widget.user.eventFields!.statusReplies;
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      color: dmodel.color,
      closeText: "Close",
      title: "Comments",
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
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
          child: cv.NativeList(
            color: CustomColors.textColor(context).withOpacity(0.1),
            itemPadding: const EdgeInsets.all(16),
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
          child: cv.NativeList(
            itemPadding: const EdgeInsets.all(8),
            color: CustomColors.textColor(context).withOpacity(0.1),
            children: [
              for (StatusReply i in _replies) _userCommentCell(i),
            ],
          ),
        ),
        cv.Section("", child: _replyCell(context)),
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
    return cv.NativeList(
      color: CustomColors.textColor(context).withOpacity(0.1),
      children: [
        cv.TextField(
          labelText: "Reply Message ...",
          charLimit: 50,
          showCharacters: true,
          showBackground: false,
          validator: (value) {},
          onChanged: (value) {
            _reply = value;
          },
        ),
        SizedBox(
          height: 50,
          child: cv.BasicButton(
            onTap: () {
              _replyToStatus(context, dmodel);
            },
            child: Center(
              child: (_isLoading)
                  ? cv.LoadingIndicator()
                  : Text(
                      "Reply",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: dmodel.color,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  void _replyToStatus(BuildContext context, DataModel dmodel) async {
    if (!_isLoading) {
      if (_reply == "") {
        dmodel.setError("Reply cannot be empty", true);
      } else {
        setState(() {
          _isLoading = true;
        });
        await dmodel.replyToStatus(
            widget.teamId,
            widget.season.seasonId,
            widget.event.eventId,
            widget.user.email,
            dmodel.currentSeasonUser!.name(widget.season.showNicknames),
            _reply,
            widget.event.getTitle(), () {
          setState(() {
            _replies.add(
              StatusReply(
                date: dateToString(DateTime.now()),
                message: _reply,
                name:
                    dmodel.currentSeasonUser!.name(widget.season.showNicknames),
              ),
            );
            _reply = "";
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
