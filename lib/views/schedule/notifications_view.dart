import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/user/notif_alert.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({
    super.key,
    required this.user,
  });
  final User user;

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late List<NotificationAlert> _notifs;
  bool _isLoading = false;

  @override
  void initState() {
    _notifs = [for (var i in widget.user.notifications) i.clone()];
    _notifs = _notifs.reversed.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        IgnorePointer(
          ignoring: _isLoading,
          child: cv.AppBar.sheet(
            title: "Notifications",
            color: dmodel.color,
            leading: [
              cv.BackButton(
                color: dmodel.color,
                showIcon: false,
                showText: true,
                title: "Done",
                useRoot: true,
              ),
            ],
            trailing: [
              cv.BasicButton(
                onTap: () async {
                  // clear all
                  if (_notifs.isNotEmpty) {
                    await _removeAll(dmodel);
                  }
                },
                child: _isLoading
                    ? const cv.LoadingIndicator()
                    : Text(
                        "Clear All",
                        style: TextStyle(
                          fontSize: 18,
                          color: _notifs.isEmpty
                              ? CustomColors.textColor(context).withOpacity(0.5)
                              : dmodel.color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
              ),
            ],
            childPadding: const EdgeInsets.fromLTRB(0, 16, 0, 48),
            children: [
              if (_notifs.isEmpty)
                Center(
                  child: cv.NoneFound(
                    "You have no new notifications",
                    color: dmodel.color,
                  ),
                )
              else
                cv.ListView<NotificationAlert>(
                  children: _notifs,
                  allowsDelete: true,
                  onChildTap: (context, item) =>
                      _composeLink(context, dmodel, item),
                  preDelete: (item) async =>
                      await _removeNotification(dmodel, item),
                  onDelete: (item) {
                    setState(() {
                      _notifs.removeWhere((element) => element.id == item.id);
                      dmodel.user!.notifications = [
                        for (var i in _notifs) i.clone()
                      ];
                    });
                  },
                  childBuilder: ((context, item) {
                    return _cell(context, item);
                  }),
                ),
            ],
          ),
        ),
        if (_isLoading)
          Container(
            decoration: BoxDecoration(
              color: CustomColors.textColor(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            height: 50,
            width: 50,
            child: Center(
              child: cv.LoadingIndicator(color: dmodel.color),
            ),
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, NotificationAlert notif) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notif.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  notif.body,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context).withOpacity(0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<bool> _removeNotification(
      DataModel dmodel, NotificationAlert notif) async {
    setState(() {
      _isLoading = true;
    });
    var ret = false;
    var temp = _notifs.where((element) => element.id != notif.id).toList();
    await dmodel.updateUser(
      widget.user.email,
      {
        "notifications": [for (var i in temp) i.toJson()]
      },
      () {
        ret = true;
      },
    );
    setState(() {
      _isLoading = false;
    });
    return ret;
  }

  Future<void> _removeAll(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.updateUser(widget.user.email, {"notifications": []}, () {
      Navigator.of(context, rootNavigator: true).pop();
      setState(() {
        dmodel.user!.notifications = [];
      });
    });
    setState(() {
      _isLoading = false;
    });
  }

  void _composeLink(
      BuildContext context, DataModel dmodel, NotificationAlert notif) async {
    if (notif.params.isNotEmpty) {
      List<String> args = notif.params.split(",");
      print("[ARGS]: $args");
      dmodel.deepLink = DeepLink(type: notif.type, args: args);
      await _removeNotification(dmodel, notif);
      dmodel.setIsScaled(false);
      Navigator.of(context, rootNavigator: true).pop();
      dmodel.init();
    }
  }
}
