import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:sprung/sprung.dart';
import 'package:uuid/uuid.dart';

class RGCU extends StatefulWidget {
  const RGCU({
    super.key,
    this.rosterGroup,
  });
  final RosterGroup? rosterGroup;

  @override
  State<RGCU> createState() => _RGCUState();
}

class _RGCUState extends State<RGCU> {
  late String _title = "";
  late String _description = "";
  late List<String> _selected = [];
  late String _icon;
  late String _iconColor;
  bool _isLoading = false;

  @override
  void initState() {
    if (widget.rosterGroup != null) {
      _title = widget.rosterGroup!.title;
      _description = widget.rosterGroup!.description;
      _selected = List.of(widget.rosterGroup!.ids);
      _icon = widget.rosterGroup!.icon;
      _iconColor = widget.rosterGroup!.color;
    } else {
      _title = "";
      _description = "";
      _selected =
          context.read<RGModel>().seasonRoster.map((e) => e.email).toList();
      _icon = "earth";
      _iconColor = CustomColors.random(const Uuid().v4())
          .value
          .toRadixString(16)
          .substring(2);
    }
    super.initState();
  }

  bool _isValid() {
    if (_title.isEmpty) {
      return false;
    } else if (_selected.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    RGModel rgmodel = Provider.of<RGModel>(context);
    return cv.AppBar.sheet(
      title: widget.rosterGroup == null ? "New Group" : "Edit Group",
      leading: [
        cv.BackButton(
          color: CustomColors.textColor(context).withOpacity(0.5),
          title: "Cancel",
          showIcon: false,
          showText: true,
          useRoot: true,
        )
      ],
      trailing: [
        cv.BasicButton(
          onTap: () async {
            if (_isValid()) {
              if (widget.rosterGroup == null) {
                // create the roster group
                setState(() {
                  _isLoading = true;
                });
                await rgmodel.createRosterGroup(context, dmodel, {
                  "title": _title,
                  "ids": _selected,
                  "icon": _icon,
                  "color": _iconColor,
                  "description": _description,
                });
                setState(() {
                  _isLoading = false;
                });
              } else {
                // edit the roster group
                setState(() {
                  _isLoading = true;
                });
                await rgmodel
                    .editRosterGroup(context, dmodel, widget.rosterGroup!, {
                  "title": _title,
                  "ids": _selected,
                  "icon": _icon,
                  "color": _iconColor,
                  "description": _description,
                });
                setState(() {
                  _isLoading = false;
                });
              }
            }
          },
          child: _isLoading
              ? SizedBox(
                  height: 25,
                  width: 25,
                  child: cv.LoadingIndicator(color: dmodel.color),
                )
              : Text(
                  widget.rosterGroup == null ? "Create" : "Save",
                  style: TextStyle(
                    color: _isValid()
                        ? dmodel.color
                        : CustomColors.textColor(context).withOpacity(0.5),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
      children: [_content(context, dmodel)],
    );
  }

  Widget _content(BuildContext context, DataModel dmodel) {
    RGModel rgmodel = Provider.of<RGModel>(context);
    return Column(
      children: [
        cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            cv.TextField2(
              showBackground: false,
              value: _title,
              labelText: "Title",
              onChanged: (value) {
                setState(() {
                  _title = value;
                });
              },
            ),
            cv.TextField2(
              showBackground: false,
              value: _description,
              labelText: "Description",
              maxLines: 2,
              onChanged: (value) {
                setState(() {
                  _description = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        cv.Section(
          "Icon",
          child: Column(
            children: [
              for (var i = 0; i < 2; i++)
                Padding(
                  padding: i == 0
                      ? const EdgeInsets.only(bottom: 16)
                      : EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      for (var j = 0; j < rosterGroupIconMap.length / 2; j++)
                        _iconCell(
                          context,
                          dmodel,
                          rosterGroupIconMap[rosterGroupIconMap.keys.toList()[
                              (rosterGroupIconMap.length / 2 * i).round() +
                                  j]]!,
                          rosterGroupIconMap.keys.toList()[
                              (rosterGroupIconMap.length / 2 * i).round() + j],
                        )
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              cv.BasicButton(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        titlePadding: const EdgeInsets.all(0),
                        contentPadding: const EdgeInsets.all(0),
                        shape: RoundedRectangleBorder(
                          borderRadius: MediaQuery.of(context).orientation ==
                                  Orientation.portrait
                              ? const BorderRadius.vertical(
                                  top: Radius.circular(500),
                                  bottom: Radius.circular(100),
                                )
                              : const BorderRadius.horizontal(
                                  right: Radius.circular(500)),
                        ),
                        content: SingleChildScrollView(
                          child: HueRingPicker(
                            pickerColor: CustomColors.fromHex(_iconColor),
                            onColorChanged: (color) {
                              setState(() {
                                _iconColor =
                                    color.value.toRadixString(16).substring(2);
                              });
                            },
                            displayThumbColor: false,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CustomColors.cellColor(context),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: CustomColors.fromHex(_iconColor),
                          ),
                          height: 40,
                          width: 40,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Select Color",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        cv.Section(
          "Select Users",
          child: cv.ListView<SeasonUser>(
            children: sortSeasonUsers(
              rgmodel.seasonRoster,
              showNicknames: dmodel.tus!.team.showNicknames,
            )..sort((a, b) {
                if (b.seasonFields!.isSub) {
                  return 1;
                } else {
                  return -1;
                }
              }),
            allowsSelect: true,
            horizontalPadding: 0,
            color: dmodel.color,
            selected: [],
            selectedLogic: ((item) {
              return _selected.contains(item.email);
            }),
            childPadding: const EdgeInsets.all(8),
            onSelect: (user) {
              if (_selected.any((element) => element == user.email)) {
                // remove the user from the add list
                setState(() {
                  _selected.removeWhere((element) => element == user.email);
                });
              } else {
                // add to add list
                setState(() {
                  _selected.add(user.email);
                });
              }
            },
            childBuilder: (context, user) {
              return Row(
                children: [
                  RosterAvatar(
                    name: user.name(rgmodel.team.showNicknames),
                    size: 50,
                    seed: user.email,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      user.name(rgmodel.team.showNicknames),
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  if (user.seasonFields!.isSub)
                    const Text(
                      "sub",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (user.seasonFields!.seasonUserStatus == -1)
                    const Text(
                      "inactive",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget _iconCell(
      BuildContext context, DataModel dmodel, IconData icon, String label) {
    return cv.BasicButton(
      onTap: () {
        setState(() {
          _icon = label;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: label == _icon ? dmodel.color : Colors.transparent,
            width: 2,
          ),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Icon(
            icon,
            color: CustomColors.fromHex(_iconColor),
            size: 32,
          ),
        ),
      ),
    );
  }
}
