// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:pnflutter/theme/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter_switch/flutter_switch.dart';

// import '../root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import 'root.dart';

class SeasonUserEdit extends StatefulWidget {
  const SeasonUserEdit({
    Key? key,
    required this.team,
    required this.user,
    required this.teamId,
    this.season,
    required this.completion,
    this.isAdd = false,
  }) : super(key: key);
  final Team team;
  final SeasonUser user;
  final String teamId;
  final Season? season;
  final VoidCallback completion;
  final bool isAdd;

  @override
  _SeasonUserEditState createState() => _SeasonUserEditState();
}

class _SeasonUserEditState extends State<SeasonUserEdit> {
  bool _isLoading = false;

  late String _email;

  // user fields
  late String _firstName;
  late String _lastName;
  late String _phone;

  // team fields
  late String _teamPos;
  late String _teamUserNote;
  late int _teamUserType;
  late List<CustomField> _teamCustomFields;

  // season fields
  late String _seasonPos;
  late bool _isManager;
  // late bool _isPlaying;
  late int _seasonUserStatus;
  late bool _isSub;
  late String _nickname;
  late List<CustomField> _seasonCustomFields;

  // stats
  late List<SUStats> _stats;

  @override
  void initState() {
    super.initState();
    _email = widget.user.email;
    _firstName = widget.user.userFields?.firstName ?? "";
    _lastName = widget.user.userFields?.lastName ?? "";
    _phone = widget.user.userFields?.phone ?? "";
    _teamUserNote = widget.user.teamFields?.teamUserNote ?? "";
    _teamUserType = widget.user.teamFields?.teamUserType ?? 0;
    _isManager = widget.user.seasonFields?.isManager ?? false;
    _seasonUserStatus = widget.user.seasonFields?.seasonUserStatus ?? 0;
    _isSub = widget.user.seasonFields?.isSub ?? false;
    _nickname = widget.user.seasonFields?.nickname ?? "";
    if (widget.isAdd) {
      _teamPos = widget.team.positions.defaultPosition;
      _seasonPos = widget.season?.positions.defaultPosition ?? "None";
      if (widget.season != null) {
        _teamCustomFields = widget.team.customUserFields
            .map((e) => CustomField(
                title: e.getTitle(), type: e.getType(), value: e.getValue()))
            .toList();
        _seasonCustomFields = widget.season!.customUserFields
            .map((e) => CustomField(
                title: e.getTitle(), type: e.getType(), value: e.getValue()))
            .toList();
        _stats = widget.season!.stats.stats
            .map((e) => SUStats(title: e.title, value: e.defaultValue))
            .toList();
      } else {
        _teamCustomFields = [];
        _seasonCustomFields = [];
        _stats = [];
      }
    } else {
      _teamPos = widget.user.teamFields?.pos ?? "None";
      _teamCustomFields = widget.user.teamFields?.customFields ?? [];
      _seasonPos = widget.user.seasonFields?.pos ?? "None";
      _seasonCustomFields = widget.user.seasonFields?.customFields ?? [];
      _stats = widget.user.seasonFields?.stats ?? [];
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: widget.isAdd ? "Add User" : "Edit User",
      backgroundColor: CustomColors.backgroundColor(context),
      // itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      leading: [
        cv.BackButton(
          color: dmodel.color,
          showText: true,
          title: "Cancel",
          showIcon: false,
        ),
      ],
      children: [
        const SizedBox(height: 16),
        cv.NativeList(
          children: [
            if (widget.isAdd)
              cv.TextField(
                labelText: "Email",
                fieldPadding: EdgeInsets.zero,
                initialvalue: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
                validator: (value) {},
              )
            else
              Opacity(
                opacity: 0.5,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: UserInfoCell(label: "Email", value: _email),
                ),
              ),
          ],
        ),
        _userFields(context),
        if ((dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) ||
            (dmodel.tus?.user.isTeamAdmin() ?? false))
          _teamFields(context, dmodel),
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)
          _seasonFields(context, dmodel),
        if (dmodel.currentSeasonUser?.isSeasonAdmin() ?? false)
          _statsView(context, dmodel),
        const SizedBox(height: 32),
        cv.RoundedLabel(widget.isAdd ? "Create User" : "Update User",
            color: dmodel.color, textColor: Colors.white, onTap: () {
          _function(context, dmodel);
        }),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _userFields(BuildContext context) {
    return cv.Section(
      "User Fields",
      child: cv.NativeList(
        children: [
          cv.TextField(
            labelText: "First Name",
            fieldPadding: EdgeInsets.zero,
            isLabeled: true,
            initialvalue: _firstName,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              setState(() {
                _firstName = value;
              });
            },
            validator: (value) {},
          ),
          cv.TextField(
            labelText: "Last Name",
            fieldPadding: EdgeInsets.zero,
            isLabeled: true,
            initialvalue: _lastName,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              setState(() {
                _lastName = value;
              });
            },
            validator: (value) {},
          ),
          cv.TextField(
            labelText: "Phone",
            fieldPadding: EdgeInsets.zero,
            isLabeled: true,
            initialvalue: _phone,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                _phone = value;
              });
            },
            validator: (value) {},
          ),
        ],
      ),
    );
  }

  Widget _teamFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Team Fields",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              // team position
              cv.BasicButton(
                onTap: () {
                  cv.showFloatingSheet(
                    context: context,
                    builder: (context) {
                      return cv.ModelSelector<String>(
                        title: "Position Select",
                        color: dmodel.color,
                        selections: widget.team.positions.available,
                        initialSelection: _teamPos,
                        onSelection: (value) {
                          setState(() {
                            _teamPos = value;
                          });
                        },
                      );
                    },
                  );
                },
                child: cv.LabeledWidget(
                  "Position",
                  child: Text(
                    _teamPos == "" ? "None" : _teamPos,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  height: 50,
                ),
              ),
              // team note
              cv.TextField(
                labelText: "Team Note",
                fieldPadding: EdgeInsets.zero,
                isLabeled: true,
                initialvalue: _teamUserNote,
                keyboardType: TextInputType.name,
                onChanged: (value) {
                  setState(() {
                    _teamUserNote = value;
                  });
                },
                validator: (value) {},
              ),
              // team user type
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        Text(
                          "Team User Type",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: CustomColors.textColor(context)
                                .withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  cv.SegmentedPicker<int>(
                    initialSelection: _teamUserType,
                    titles: ["Inactive", "Active", "Owner"],
                    selections: [-1, 1, 3],
                    onSelection: (value) {
                      setState(() {
                        _teamUserType = value;
                      });
                    },
                  )
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // team custom fields
          cv.NativeList(
            children: [
              for (var customField in _teamCustomFields)
                CustomFieldCell(field: customField, color: dmodel.color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seasonFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Season Fields",
      child: Column(
        children: [
          cv.NativeList(
            children: [
              // nickname
              if (widget.season?.showNicknames ?? false)
                cv.TextField(
                  labelText: "Nickname",
                  fieldPadding: EdgeInsets.zero,
                  isLabeled: true,
                  initialvalue: _nickname,
                  keyboardType: TextInputType.name,
                  onChanged: (value) {
                    setState(() {
                      _nickname = value;
                    });
                  },
                  validator: (value) {},
                ),
              // season position
              cv.BasicButton(
                onTap: () {
                  cv.showFloatingSheet(
                    context: context,
                    builder: (context) {
                      return cv.ModelSelector<String>(
                        title: "Position Select",
                        color: dmodel.color,
                        selections: widget.season!.positions.available,
                        initialSelection: _seasonPos,
                        onSelection: (value) {
                          setState(() {
                            _seasonPos = value;
                          });
                        },
                      );
                    },
                  );
                },
                child: cv.LabeledWidget(
                  "Position",
                  child: Text(
                    _seasonPos == "" ? "None" : _seasonPos,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  height: 50,
                ),
              ),
              // isManager
              cv.LabeledWidget(
                "Is A Manager",
                child: FlutterSwitch(
                  value: _isManager,
                  height: 25,
                  width: 50,
                  toggleSize: 18,
                  activeColor: dmodel.color,
                  onToggle: (value) {
                    setState(() {
                      _isManager = value;
                    });
                  },
                ),
              ),
              // user status
              if (!widget.isAdd)
                cv.BasicButton(
                  onTap: () {
                    cv.showFloatingSheet(
                      context: context,
                      builder: (context) {
                        return UserStatusSelect(
                            isAdd: widget.isAdd,
                            onSelect: (value) {
                              setState(() {
                                _seasonUserStatus = value;
                              });
                            },
                            initialSelection: _seasonUserStatus);
                      },
                    );
                  },
                  child: cv.LabeledWidget(
                    "User Status",
                    child: Text(
                      widget.user.seasonUserStatus(_seasonUserStatus),
                      style: const TextStyle(
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600,
                          fontSize: 18),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    FlutterSwitch(
                      value: _isSub,
                      height: 25,
                      width: 50,
                      toggleSize: 18,
                      activeColor: Theme.of(context).colorScheme.primary,
                      onToggle: (value) {
                        setState(() {
                          _isSub = value;
                        });
                      },
                    ),
                    const Spacer(),
                    const SizedBox(height: 40),
                    Text(
                      "Is A Sub",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context).withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          // season custom fields
          cv.NativeList(
            children: [
              for (var customField in _seasonCustomFields)
                CustomFieldCell(field: customField, color: dmodel.color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statsView(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Stats",
      child: cv.NativeList(
        children: [
          for (var i in _stats) _StatEditCell(stat: i, color: dmodel.color),
        ],
      ),
    );
  }

  void _function(BuildContext context, DataModel dmodel) async {
    if (!_isLoading) {
      if (_email == "") {
        dmodel.setError("Email cannot be blank", true);
      } else if (_firstName == "") {
        dmodel.setError("First name cannot be blank", true);
      } else if (_lastName == "") {
        dmodel.setError("Last name cannot be blank", true);
      } else {
        setState(() {
          _isLoading = true;
        });
        // create basic fields for what the user is able to edit
        Map<String, dynamic> body = {
          "date": dateToString(DateTime.now()),
          "email": _email,
          "userFields": {
            "firstName": _firstName,
            "lastName": _lastName,
            "phone": _phone,
          }
        };

        // if user is a team admin, create the team field portion
        if (widget.user.isTeamAdmin()) {
          body['teamFields'] = {
            "pos": _teamPos,
            "teamNote": _teamUserNote,
            "teamUserType": _teamUserType,
            "customFields": _teamCustomFields.map((e) => e.toJson()).toList(),
          };
        }

        // if season is not null, and if is season admin, add the season fields
        if (widget.user.isSeasonAdmin()) {
          body['seasonFields'] = {
            "pos": _seasonPos,
            "isManager": _isManager,
            "seasonUserStatus": _seasonUserStatus,
            "customFields": _seasonCustomFields.map((e) => e.toJson()).toList(),
          };
        }

        if (widget.isAdd) {
          if (widget.season != null) {
            // add user to the season
            await dmodel.seasonUserAdd(
                widget.teamId, widget.season!.seasonId, body, (seasonUser) {
              // add returned user to the list
              dmodel.seasonUsers!.add(seasonUser);
              Navigator.of(context).pop();
              widget.completion();
            });
          } else {
            // add user to the team
            print("TODO");
          }
        } else {
          if (widget.season != null) {
            // update the season user
            await dmodel.seasonUserUpdate(
                widget.teamId, widget.season!.seasonId, widget.user.email, body,
                (seasonUser) {
              // replace the user with the returned one
              for (var i in dmodel.seasonUsers!) {
                if (i.email == seasonUser.email) {
                  i.set(seasonUser);
                  break;
                }
              }
              Navigator.of(context).pop();
              widget.completion();
            });
          } else {
            // update the team user
            print("TODO");
          }
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _StatEditCell extends StatefulWidget {
  _StatEditCell({
    Key? key,
    required this.stat,
    this.color = Colors.blue,
  }) : super(key: key);
  SUStats stat;
  Color color;

  @override
  _StatEditCellState createState() => _StatEditCellState();
}

class _StatEditCellState extends State<_StatEditCell> {
  @override
  Widget build(BuildContext context) {
    return cv.LabeledWidget(
      widget.stat.title,
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                widget.stat.value.toString(),
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
              ),
            ),
          ),
          cv.NumberPicker(
            initialValue: widget.stat.value,
            plusBackgroundColor: widget.color,
            minusBackgroundColor:
                CustomColors.textColor(context).withOpacity(0.1),
            onMinusClick: (value) {
              setState(() {
                widget.stat.value = value;
              });
            },
            onPlusClick: (value) {
              setState(() {
                widget.stat.value = value;
              });
            },
          ),
        ],
      ),
    );
  }
}
