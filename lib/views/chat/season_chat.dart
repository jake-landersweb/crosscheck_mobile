import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import 'package:graphql/client.dart';

class ChatHome extends StatelessWidget {
  const ChatHome({
    Key? key,
    required this.team,
    required this.season,
    required this.user,
    required this.seasonUser,
  }) : super(key: key);
  final Team team;
  final Season season;
  final User user;
  final SeasonUser seasonUser;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<ChatModel>(
      create: (_) =>
          ChatModel(team, season, dmodel, user.getName(), user.email),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        return SeasonChat(
          team: team,
          season: season,
          user: user,
          seasonUser: seasonUser,
        );
      },
    );
  }
}

class SeasonChat extends StatefulWidget {
  const SeasonChat({
    Key? key,
    required this.team,
    required this.season,
    required this.user,
    required this.seasonUser,
  }) : super(key: key);
  final Team team;
  final Season season;
  final User user;
  final SeasonUser seasonUser;

  @override
  _SeasonChatState createState() => _SeasonChatState();
}

class _SeasonChatState extends State<SeasonChat> {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    _controller.text = "";
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _isUpdatingUser = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ChatModel cmodel = Provider.of<ChatModel>(context);
    return _chatHolder(context, dmodel, cmodel);
  }

  Widget _chatHolder(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Column(
            children: [
              Expanded(
                child: _messageList(context, dmodel, cmodel),
              ),
              _messageInput(context, dmodel, cmodel),
              // for artificial safe area, prevents screen jitter
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Sprung.custom(damping: 36),
                width: double.infinity,
                height: MediaQuery.of(context).viewInsets.bottom == 0
                    ? MediaQuery.of(context).padding.bottom
                    : 0,
              ),
              // push view up to reveal keyboard
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Sprung.custom(damping: 36),
                width: double.infinity,
                height: MediaQuery.of(context).viewInsets.bottom == 0
                    ? 0
                    : (MediaQuery.of(context).viewInsets.bottom + 8),
              ),
            ],
          ),
          _topBar(context, dmodel, cmodel),
        ],
      ),
    );
  }

  Widget _messageList(
      BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return ListView(
      shrinkWrap: true,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: [
        for (var message in cmodel.messages)
          Column(children: [
            _messageCell(context, dmodel, cmodel, message),
            const SizedBox(height: 8),
          ]),
        // padding from button
        if (cmodel.moreMessages) const SizedBox(height: 16),
        // for fetching more messages
        if (cmodel.moreMessages)
          cv.BasicButton(
            onTap: () {
              if (cmodel.room != null) {
                cmodel.getMessages(cmodel.room!.roomId);
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context).withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              height: 50,
              width: MediaQuery.of(context).size.width / 3,
              child: Center(
                child: cmodel.isFetchingMessages
                    ? const cv.LoadingIndicator()
                    : const Text("Get More"),
              ),
            ),
          ),

        // padding from app bar
        SizedBox(height: MediaQuery.of(context).padding.top + 40),
      ],
    );
  }

  Widget _messageInput(
      BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Column(
      children: [
        const Divider(height: 0.5, indent: 0, endIndent: 0),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
          child: cv.RoundedLabel(
            "",
            color: CustomColors.cellColor(context),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // text field
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: cv.TextField(
                      controller: _controller,
                      labelText: "Type your message ...",
                      showBackground: false,
                      validator: (value) {},
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                Opacity(
                  opacity: _controller.text.isEmpty ? 0.5 : 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3.0),
                    child: cv.BasicButton(
                      onTap: () {
                        if (_controller.text.isEmpty) {
                          print("text input was empty");
                        } else {
                          _sendMessage(context, dmodel, cmodel);
                        }
                      },
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle, color: dmodel.color),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return cv.GlassContainer(
      width: double.infinity,
      borderRadius: BorderRadius.circular(0),
      backgroundColor: CustomColors.backgroundColor(context),
      opacity: 0.7,
      blur: 10,
      height: MediaQuery.of(context).padding.top + 40,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            const Align(
              alignment: Alignment.bottomLeft,
              child: MenuButton(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                cmodel.room?.title ?? "Chat",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: cv.BasicButton(
                onTap: () {
                  // update the user to the clicked value
                  _updateUserNotifs(dmodel);
                },
                child: _isUpdatingUser
                    ? const SizedBox(
                        height: 25,
                        width: 25,
                        child: cv.LoadingIndicator(),
                      )
                    : Icon(
                        widget.seasonUser.seasonFields!.allowChatNotifications
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: widget
                                .seasonUser.seasonFields!.allowChatNotifications
                            ? dmodel.color
                            : null,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCell(BuildContext context, DataModel dmodel, ChatModel cmodel,
      Message message) {
    return IntrinsicHeight(
      child: Row(
        children: [
          if (message.email == cmodel.email)
            const Spacer()
          else
            Container(
              height: double.infinity,
              width: 7,
              decoration: BoxDecoration(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(5)),
                color: CustomColors.random(message.email),
              ),
            ),
          Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width / 1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.horizontal(
                left: message.email == cmodel.email
                    ? const Radius.circular(25)
                    : const Radius.circular(0),
                right: message.email == cmodel.email
                    ? const Radius.circular(0)
                    : const Radius.circular(25),
              ),
              color: CustomColors.cellColor(context),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  message.email == cmodel.email ? 16 : 8,
                  10,
                  message.email == cmodel.email ? 8 : 16,
                  10),
              child: Column(
                crossAxisAlignment: message.email == cmodel.email
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    message.sender,
                    style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 16,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message.message,
                    style: const TextStyle(
                        fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          if (message.email == cmodel.email)
            Container(
              height: double.infinity,
              width: 7,
              decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.horizontal(right: Radius.circular(5)),
                  color: CustomColors.random(message.email)),
            )
          else
            const Spacer(),
        ],
      ),
    );
  }

  Future<void> _sendMessage(
      BuildContext context, DataModel dmodel, ChatModel cmodel) async {
    bool success =
        await cmodel.sendMessage(cmodel.room!.roomId, _controller.text);
    if (success) {
      // send notification
      Map<String, dynamic> body = {
        "title": "New Chat From ${cmodel.name}",
        "body": _controller.text,
      };
      dmodel.sendChatNotification(
          widget.team.teamId, widget.season.seasonId, body, () {});
    }
    setState(() {
      _controller.clear();
    });
  }

  Future<void> _updateUserNotifs(DataModel dmodel) async {
    setState(() {
      _isUpdatingUser = true;
    });
    // send the update
    Map<String, dynamic> body = {
      "seasonFields": {
        "allowChatNotifications":
            !widget.seasonUser.seasonFields!.allowChatNotifications,
      }
    };
    await dmodel.seasonUserUpdate(
        widget.team.teamId, widget.season.seasonId, widget.user.email, body,
        (seasonUser) {
      widget.seasonUser.seasonFields!.allowChatNotifications =
          seasonUser.seasonFields!.allowChatNotifications;
    });
    setState(() {
      _isUpdatingUser = false;
    });
  }
}
