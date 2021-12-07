import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import 'root.dart';

class EditTeam extends StatefulWidget {
  const EditTeam({
    Key? key,
    required this.team,
  }) : super(key: key);
  final Team team;

  @override
  _EditTeamState createState() => _EditTeamState();
}

class _EditTeamState extends State<EditTeam> {
  late String _color;
  late String _image;
  late bool _isLight;

  late TeamPositions _positions;

  late List<CustomField> _customFields;
  late List<CustomUserField> _customUserFields;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _color = widget.team.color;
    _image = widget.team.image;
    _isLight = widget.team.isLight;
    _customFields = List.of(widget.team.customFields);
    _customUserFields = List.of(widget.team.customUserFields);
    _positions = TeamPositions.of(widget.team.positions);
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Edit My Team",
      isLarge: true,
      // itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      backgroundColor: CustomColors.backgroundColor(context),
      childPadding: EdgeInsets.fromLTRB(0, 15, 0, 45),
      color: dmodel.color,
      leading: [
        cv.BackButton(
          showIcon: false,
          title: "Cancel",
          showText: true,
        )
      ],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _basicInfo(dmodel, context),
        const SizedBox(height: 16),
        _pos(context, dmodel),
        const SizedBox(height: 16),
        _customF(context, dmodel),
        const SizedBox(height: 16),
        _customUserF(context, dmodel),
        const SizedBox(height: 16),
        _editButton(context, dmodel),
      ],
    );
  }

  Widget _basicInfo(DataModel dmodel, BuildContext context) {
    return cv.Section(
      "Basic Info",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: cv.NativeList(
          children: [
            cv.TextField(
              labelText: "Color (hex)",
              fieldPadding: const EdgeInsets.all(0),
              validator: (value) {},
              onChanged: (value) {
                setState(() {
                  _color = value;
                });
              },
            ),
            cv.TextField(
              labelText: "Image (url)",
              fieldPadding: const EdgeInsets.all(0),
              validator: (value) {},
              onChanged: (value) {
                setState(() {
                  _image = value;
                });
              },
            ),
            cv.LabeledWidget(
              "Light Background",
              child: FlutterSwitch(
                value: _isLight,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: dmodel.color,
                onToggle: (value) {
                  setState(() {
                    _isLight = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _newPos = "";

  Widget _pos(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: cv.NativeList(
              children: [
                cv.LabeledWidget(
                  "Is Active",
                  child: FlutterSwitch(
                    value: _positions.isActive,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (value) {
                      setState(() {
                        _positions.isActive = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: cv.LabeledCell(
                    label: "Default",
                    value: _positions.defaultPosition,
                  ),
                ),
              ],
            ),
          ),
          cv.Section(
            "Available Positions",
            headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
            child: cv.AnimatedList<String>(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _positions.available,
              allowTap: true,
              onTap: (item) {
                setState(() {
                  _positions.defaultPosition = item;
                });
              },
              cellBuilder: (context, item) {
                return SizedBox(
                  height: 40,
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(
                                fontWeight: FontWeight.w500, fontSize: 16),
                          ),
                        ),
                        Icon(
                            _positions.defaultPosition == item
                                ? Icons.radio_button_checked
                                : Icons.circle,
                            color: _positions.defaultPosition == item
                                ? dmodel.color
                                : CustomColors.textColor(context)
                                    .withOpacity(0.5)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                cv.TextField(
                  labelText: "Position",
                  onChanged: (value) {
                    setState(() {
                      _newPos = value;
                    });
                  },
                  validator: (value) {},
                ),
                const SizedBox(height: 16),
                cv.BasicButton(
                  onTap: () {
                    if (_newPos.isEmpty) {
                      dmodel.setError(
                          "New position title cannot be empty", true);
                    } else if (_positions.available.contains(_newPos)) {
                      dmodel.setError("This position already exists", true);
                    } else if (_positions.available.length > 20) {
                      dmodel.setError("Max of 20 positions", true);
                    } else {
                      setState(() {
                        _positions.available.add(_newPos);
                      });
                      if (_positions.available.length == 1) {
                        setState(() {
                          _positions.defaultPosition = _newPos;
                        });
                      }
                    }
                  },
                  child: const cv.NativeList(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            "Add New",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _customF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: false,
      child: Column(
        children: [
          cv.AnimatedList<CustomField>(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            buttonPadding: 20,
            children: _customFields,
            cellBuilder: (BuildContext context, CustomField item) {
              return CustomFieldField(item: item);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: cv.BasicButton(
              onTap: () {
                setState(() {
                  _customFields.add(
                    CustomField(
                      title: "",
                      type: "S",
                      stringVal: "",
                      intVal: 0,
                      boolVal: true,
                    ),
                  );
                });
              },
              child: const cv.NativeList(
                children: [
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        "Add new",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _customUserF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: false,
      child: Column(
        children: [
          cv.AnimatedList<CustomUserField>(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            buttonPadding: 20,
            children: _customUserFields,
            cellBuilder: (BuildContext context, CustomUserField item) {
              return CustomUserFieldField(item: item);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: cv.BasicButton(
              onTap: () {
                setState(() {
                  _customUserFields.add(CustomUserField.empty());
                });
              },
              child: const cv.NativeList(
                children: [
                  SizedBox(
                    height: 40,
                    child: Center(
                      child: Text(
                        "Add new",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        // check custom fields
        for (var i in _customFields) {
          if (i.title == "") {
            dmodel.setError("Custom field title cannot be blank", true);
            return;
          }
        }
        for (var i in _customUserFields) {
          if (i.title == "") {
            dmodel.setError("Custom user field title cannot be blank", true);
            return;
          }
        }
        _editTeam(context, dmodel);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Material(
          shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(35)),
          color: dmodel.color,
          child: SizedBox(
            height: 50,
            child: Center(
              child: _isLoading
                  ? const cv.LoadingIndicator(color: Colors.white)
                  : const Text(
                      "Confirm",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editTeam(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    // first update the custom user fields
    Map<String, dynamic> body = {
      "color": _color,
      "image": _image,
      "isLight": _isLight,
      "customFields": _customFields.map((e) => e.toJson()).toList(),
      "positions": _positions.toJson(),
    };

    Map<String, dynamic> userFields = {
      "customUserFields": _customUserFields.map((e) => e.toJson()).toList(),
    };

    print(body);
    print(userFields);

    await dmodel.updateTeam(widget.team.teamId, body, userFields, () {
      Navigator.of(context).pop();
      // get the new team data
      dmodel.teamUserSeasonsGet(widget.team.teamId, dmodel.user!.email, (tus) {
        dmodel.setTUS(tus);
        return;
      });
    });
    setState(() {
      _isLoading = false;
    });
  }
}
