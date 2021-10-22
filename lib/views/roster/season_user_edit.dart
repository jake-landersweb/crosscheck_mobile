// ignore_for_file: prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
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
    required this.seasonId,
    required this.completion,
    this.isAdd = false,
  }) : super(key: key);
  final Team team;
  final SeasonUser user;
  final String teamId;
  final String seasonId;
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
  late int _tPosition;
  late String _teamUserNote;
  late int _teamUserType;

  // season fields
  late int _sPosition;
  late List<SUStats> _stats;
  late bool _isManager;
  late bool _isPlaying;
  late Jersey _jersey;
  late int _seasonUserStatus;

  @override
  void initState() {
    super.initState();
    _email = widget.user.email;
    _firstName = widget.user.userFields?.firstName ?? "";
    _lastName = widget.user.userFields?.lastName ?? "";
    _phone = widget.user.userFields?.phone ?? "";
    _tPosition = widget.user.teamFields?.tPosition ?? 0;
    _teamUserNote = widget.user.teamFields?.teamUserNote ?? "";
    _teamUserType = widget.user.teamFields?.teamUserType ?? 0;
    _sPosition = widget.user.seasonFields?.sPosition ?? 0;
    _stats = widget.user.seasonFields?.stats ?? [];
    _isManager = widget.user.seasonFields?.isManager ?? false;
    _isPlaying = widget.user.seasonFields?.isPlaying ?? true;
    _jersey = widget.user.seasonFields?.jersey ??
        Jersey(
          size: widget.user.seasonFields?.jerseySize ?? "",
          number:
              int.tryParse(widget.user.seasonFields?.jerseyNumber ?? "0") ?? 0,
        );
    _seasonUserStatus = widget.user.seasonFields?.seasonUserStatus ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: widget.isAdd ? "Add User" : "Edit User",
      titlePadding: const EdgeInsets.only(left: 8),
      leading: cv.BackButton(
        color: dmodel.color,
      ),
      children: [
        const SizedBox(height: 16),
        cv.NativeList(
          children: [
            if (widget.isAdd)
              _UserTextField(
                label: "Email",
                initialValue: _email,
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
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
        _teamFields(context),
        _seasonFields(context, dmodel),
        cv.Section(
          "",
          child: cv.BasicButton(
            onTap: () {
              _function(context, dmodel);
            },
            child: cv.NativeList(
              itemPadding: const EdgeInsets.all(16),
              children: [
                if (_isLoading)
                  cv.LoadingIndicator()
                else
                  Text(
                    widget.isAdd ? "Add" : "Update",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: dmodel.color),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _userFields(BuildContext context) {
    return cv.Section(
      "User Fields",
      child: cv.NativeList(
        children: [
          _UserTextField(
            label: "First Name",
            initialValue: _firstName,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              _firstName = value;
            },
          ),
          _UserTextField(
            label: "Last Name",
            initialValue: _lastName,
            keyboardType: TextInputType.name,
            onChanged: (value) {
              _lastName = value;
            },
          ),
          _UserTextField(
            label: "Phone",
            initialValue: _phone,
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              _phone = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _teamFields(BuildContext context) {
    return cv.Section(
      "Team Fields",
      child: cv.NativeList(
        children: [
          // team position
          if (widget.team.positions != null &&
              (widget.team.positions?.available.length ?? 0) < 4)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        "Team Position",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              CustomColors.textColor(context).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                cv.SegmentedPicker<int>(
                  onSelection: (value) {
                    setState(() {
                      _tPosition = value;
                    });
                  },
                  titles: widget.team.positions!.available
                      .map((e) => widget.user.getPosition(e.round()))
                      .toList(),
                  initialSelection: _tPosition,
                  selections: widget.team.positions!.available,
                ),
              ],
            ),
          // team note
          _UserTextField(
            label: "Team Note",
            initialValue: _teamUserNote,
            keyboardType: TextInputType.text,
            onChanged: (value) {
              _teamUserNote = value;
            },
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
                        color: CustomColors.textColor(context).withOpacity(0.7),
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
          )
        ],
      ),
    );
  }

  Widget _seasonFields(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Season Fields",
      child: cv.NativeList(
        children: [
          // season position
          if (widget.team.positions != null &&
              (widget.team.positions?.available.length ?? 0) < 4)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      const Spacer(),
                      Text(
                        "Season Position",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color:
                              CustomColors.textColor(context).withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                cv.SegmentedPicker<int>(
                  onSelection: (value) {
                    setState(() {
                      _sPosition = value;
                    });
                  },
                  titles: widget.team.positions!.available
                      .map((e) => widget.user.getPosition(e.round()))
                      .toList(),
                  initialSelection: _sPosition,
                  selections: widget.team.positions!.available,
                ),
              ],
            ),
          // stats
          for (var i in _stats) _StatEditCell(stat: i, color: dmodel.color),
          // isManager
          Row(
            children: [
              FlutterSwitch(
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
              const Spacer(),
              const SizedBox(height: 40),
              Text(
                "Is Manager",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textColor(context).withOpacity(0.7),
                ),
              ),
            ],
          ),
          // isPlaying
          Row(
            children: [
              FlutterSwitch(
                value: _isPlaying,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: dmodel.color,
                onToggle: (value) {
                  setState(() {
                    _isPlaying = value;
                  });
                },
              ),
              const Spacer(),
              const SizedBox(height: 40),
              Text(
                "Is Playing",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textColor(context).withOpacity(0.7),
                ),
              ),
            ],
          ),
          // jersey
          _UserTextField(
            label: "Jersey Size",
            initialValue: _jersey.size ?? "",
            onChanged: (value) {
              setState(() {
                _jersey.size = value;
              });
            },
          ),
          // user status
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
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    widget.user.seasonUserStatus(_seasonUserStatus),
                    style: const TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w600,
                        fontSize: 18),
                  ),
                ),
                const Spacer(),
                Text(
                  "User Status",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
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
        // create stats
        Map<String, dynamic> body = {
          "date": dateToString(DateTime.now()),
          "email": _email,
          "userFields": {
            "firstName": _firstName,
            "lastName": _lastName,
            "phone": _phone,
          },
          "teamFields": {
            "tPosition": _tPosition,
            "teamUserNote": _teamUserNote,
            "teamUserType": _teamUserType,
          },
          "seasonFields": {
            "sPosition": _sPosition,
            "stats": _stats.map((v) => v.toJson()).toList(),
            "isManager": _isManager,
            "isPlaying": _isPlaying,
            "jersey": _jersey.toJson(),
            "seasonUserStatus": _seasonUserStatus,
          }
        };
        if (widget.isAdd) {
          await dmodel.seasonUserAdd(widget.teamId, widget.seasonId, body,
              (seasonUser) {
            // add returned user to the list
            dmodel.seasonUsers!.add(seasonUser);
            Navigator.of(context).pop();
            widget.completion();
          });
        } else {
          await dmodel.seasonUserUpdate(
              widget.teamId, widget.seasonId, widget.user.email, body,
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
        }
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _UserTextField extends StatefulWidget {
  _UserTextField({
    Key? key,
    required this.label,
    this.initialValue = "",
    this.keyboardType = TextInputType.text,
    required this.onChanged,
  }) : super(key: key);
  String label;
  String initialValue;
  TextInputType keyboardType;
  Function(String) onChanged;

  @override
  _UserTextFieldState createState() => _UserTextFieldState();
}

class _UserTextFieldState extends State<_UserTextField> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.centerEnd,
      children: [
        cv.TextField(
          labelText: widget.label,
          showBackground: false,
          initialvalue: widget.initialValue,
          keyboardType: TextInputType.phone,
          validator: (value) {},
          onChanged: widget.onChanged,
        ),
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CustomColors.textColor(context).withOpacity(0.7),
          ),
        ),
      ],
    );
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
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget.stat.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
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
        const Spacer(),
        Text(
          widget.stat.title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: CustomColors.textColor(context).withOpacity(0.7),
          ),
        ),
      ],
    );
  }
}
