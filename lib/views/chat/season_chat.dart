import 'dart:io';

import 'package:crosscheck_sports/views/chat/chat_loading.dart';
import 'package:crosscheck_sports/views/chat/message_input.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:image_picker/image_picker.dart';
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
    required this.user,
  }) : super(key: key);
  final Team team;
  final User user;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.currentSeasonUser == null) {
      if (dmodel.noSeason || dmodel.noTeam) {
        // show a dummy mockup of the view
        return Container();
      } else {
        // show a dummy mockup of the view
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              "Only users on this season can view this chat room.",
              style: TextStyle(
                fontSize: 18,
                color: CustomColors.textColor(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
    } else {
      return ChangeNotifierProvider<ChatModel>(
        create: (_) => ChatModel(
          team,
          dmodel.currentSeason!,
          dmodel,
          dmodel.currentSeasonUser!.name(team.showNicknames),
          user.email,
        ),
        // we use `builder` to obtain a new `BuildContext` that has access to the provider
        builder: (context, child) {
          return SeasonChat(
            team: team,
            season: dmodel.currentSeason!,
            user: user,
            seasonUser: dmodel.currentSeasonUser!,
          );
        },
      );
    }
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
  bool _showNotifBell = false;

  late ScrollController _scrollController;

  bool _showToBottom = false;

  final double _messageSpacing = 8;

  @override
  void initState() {
    _scrollController = ScrollController();

    // implement automatic fetching of messages on scroll
    ChatModel cmodel = context.read<ChatModel>();
    _scrollController.addListener(() {
      // for showing scroll to bottom
      if (_scrollController.position.pixels > 100) {
        setState(() {
          _showToBottom = true;
        });
      } else {
        setState(() {
          _showToBottom = false;
        });
      }
      if (_scrollController.position.pixels >
              _scrollController.position.maxScrollExtent - 50 &&
          !cmodel.isFetchingMessages &&
          cmodel.moreMessages) {
        cmodel.getMessages(cmodel.room!.roomId);
        print("LOAD");
      }
    });
    _checkToken(context.read<DataModel>());
    // clear the notifications
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
    double offsetHeight;
    if (Platform.isAndroid) {
      offsetHeight = MediaQuery.of(context).viewInsets.bottom == 0 ? 18 : 0;
    } else {
      offsetHeight = 14;
    }
    var keyboardPadding = MediaQuery.of(context).viewInsets.bottom -
        (MediaQuery.of(context).viewPadding.bottom + 40 + offsetHeight);

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
              MessageInput(team: widget.team, season: widget.season),
              // for artificial safe area, prevents screen jitter
              SizedBox(height: offsetHeight.toDouble()),
              // push view up to reveal keyboard
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                curve: Sprung.custom(damping: 36),
                width: double.infinity,
                height: keyboardPadding < 0 ? 0 : keyboardPadding,
              ),
            ],
          ),
          _topBar(context, dmodel, cmodel),
        ],
      ),
    );
  }

  // from https://stackoverflow.com/questions/55306855/hide-keyboard-on-scroll-in-flutter Justin Uzzanti
  // https://stackoverflow.com/users/12697241/justin-uzzanti
  void disKeyboard(PointerMoveEvent pointer, BuildContext context) {
    double insets = MediaQuery.of(context).viewInsets.bottom;
    double screenHeight = MediaQuery.of(context).size.height;
    double position = pointer.position.dy;
    double keyboardHeight = screenHeight - insets;
    if (position > keyboardHeight && insets > 0) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
  }

  Widget _messageList(
      BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Listener(
          onPointerMove: (PointerMoveEvent pointer) {
            disKeyboard(pointer, context);
          },
          child: ListView(
            controller: _scrollController,
            shrinkWrap: true,
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            addAutomaticKeepAlives: true,
            children: [
              for (var message in cmodel.messages)
                Column(children: [
                  MessageCell(
                    key: ValueKey(message.messageId),
                    message: message,
                  ),
                  AnimatedSize(
                    curve: Sprung.overDamped,
                    duration: const Duration(milliseconds: 1000),
                    child: SizedBox(height: _messageSpacing),
                  ),
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
          ),
        ),
        // scroll to bottom
        IgnorePointer(
          ignoring: !_showToBottom,
          child: AnimatedOpacity(
            curve: Sprung.overDamped,
            duration: const Duration(milliseconds: 500),
            opacity: _showToBottom ? 1 : 0,
            child: Padding(
              key: const ValueKey("Button"),
              padding: const EdgeInsets.all(8.0),
              child: cv.BasicButton(
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 700),
                    curve: Sprung.overDamped,
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: dmodel.color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Icon(
                      Icons.arrow_downward_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _topBar(BuildContext context, DataModel dmodel, ChatModel cmodel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        cv.GlassContainer(
          width: double.infinity,
          borderRadius: BorderRadius.circular(0),
          backgroundColor: CustomColors.backgroundColor(context),
          opacity: 0.7,
          blur: 10,
          alignment: Alignment.bottomLeft,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: cv.BasicButton(
                          onTap: () {
                            cv.showFloatingSheet(
                              context: context,
                              builder: (context) {
                                return SeasonSelectAll(
                                  team: dmodel.tus!.team,
                                  onSelect: ((season, isPrevious) async {
                                    await FirebaseAnalytics.instance.logEvent(
                                      name: "change_season",
                                      parameters: {"platform": "mobile"},
                                    );
                                    dmodel.setCurrentSeason(season,
                                        isPrevious: isPrevious);
                                    dmodel.seasonUsers = null;

                                    Navigator.of(context).pop();
                                    cmodel.init(widget.team.teamId,
                                        season.seasonId, dmodel);
                                  }),
                                );
                              },
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: CustomColors.cellColor(context),
                                borderRadius: BorderRadius.circular(5)),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                              child: Text(
                                "${widget.season.title} ↓",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: CustomColors.textColor(context),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
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
                            : _showNotifBell
                                ? Icon(
                                    widget.seasonUser.seasonFields!
                                            .allowChatNotifications
                                        ? Icons.notifications_active
                                        : Icons.notifications_off,
                                    color: widget.seasonUser.seasonFields!
                                            .allowChatNotifications
                                        ? dmodel.color
                                        : null,
                                  )
                                : Container(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(indent: 0, endIndent: 0, height: 0.5)
      ],
    );
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
        () {
      widget.seasonUser.seasonFields!.allowChatNotifications =
          !widget.seasonUser.seasonFields!.allowChatNotifications;
    });
    setState(() {
      _isUpdatingUser = false;
    });
  }

  void _checkToken(DataModel dmodel) async {
    String token = await dmodel.getNotificationToken();
    setState(() {
      _showNotifBell = dmodel.user!.mobileNotifications
          .any((element) => element.token == token && element.allow);
    });
  }
}
