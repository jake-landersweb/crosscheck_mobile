import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    required this.seasonId,
    required this.completion,
  }) : super(key: key);
  final SeasonUser user;
  final Event event;
  final String email;
  final String teamId;
  final String seasonId;
  final VoidCallback completion;

  @override
  _UserCommentSheetState createState() => _UserCommentSheetState();
}

class _UserCommentSheetState extends State<UserCommentSheet> {
  late List<StatusReply> _replies;

  String _reply = "";

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
      title: "Comments",
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 500),
        child: ListView(
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
        ),
      ),
    );
  }

  Widget _userCommentCell(StatusReply reply) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.subdirectory_arrow_right,
                    color: CustomColors.textColor(context).withOpacity(0.7)),
                const SizedBox(width: 8),
                Text(reply.message, style: const TextStyle(fontSize: 18)),
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
        const Spacer(),
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
          showBackground: false,
          validator: (value) {},
          onChanged: (value) {
            _reply = value;
          },
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 12, 8, 12),
          child: cv.BasicButton(
            onTap: () {
              _replyToStatus(context, dmodel);
            },
            child: Row(
              children: [
                Text(
                  "Reply",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: dmodel.color,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _replyToStatus(BuildContext context, DataModel dmodel) async {
    if (_reply == "") {
      dmodel.setError("Reply cannot be empty", true);
    } else {
      dmodel.replyToStatus(
          widget.teamId,
          widget.seasonId,
          widget.event.eventId,
          widget.user.email,
          dmodel.currentSeasonUser!.seasonName(),
          _reply, () {
        Navigator.of(context).pop();
        widget.completion();
      });
    }
  }
}
