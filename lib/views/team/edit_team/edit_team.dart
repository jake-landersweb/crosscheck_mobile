import 'package:flutter/material.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../client/root.dart';
import '../../../data/root.dart';
import '../../../extras/root.dart';
import '../../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import 'root.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../shared/root.dart';

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
  late String _teamNote;
  late bool _isLight;

  late TeamPositions _positions;

  late List<CustomField> _customFields;
  late List<CustomField> _customUserFields;

  late TeamStat _stats;

  bool _isLoading = false;

  bool _showColorError = false;

  late bool _showNicknames;

  @override
  void initState() {
    super.initState();
    _color =
        context.read<DataModel>().color.value.toRadixString(16).substring(2);
    _teamNote = widget.team.teamNote;
    _isLight = widget.team.isLight;
    _customFields = [for (var i in widget.team.customFields) i.clone()];
    _customUserFields = [
      for (var i in List.of(widget.team.customUserFields)) i.clone()
    ];
    _positions = TeamPositions.of(widget.team.positions);
    _stats = widget.team.stats.clone();
    _showNicknames = widget.team.showNicknames;
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Edit My Team",
      isLarge: true,
      // itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 15, 8),
      backgroundColor: CustomColors.backgroundColor(context),
      childPadding: const EdgeInsets.fromLTRB(0, 15, 0, 45),
      color: dmodel.color,
      leading: [
        cv.BackButton(
          showIcon: false,
          title: "Cancel",
          showText: true,
          color: dmodel.color,
        )
      ],
      children: [_body(context, dmodel)],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        _logo(context, dmodel),
        const SizedBox(height: 16),
        _basicInfo(dmodel, context),
        const SizedBox(height: 16),
        _pos(context, dmodel),
        const SizedBox(height: 16),
        _customF(context, dmodel),
        const SizedBox(height: 16),
        _customUserF(context, dmodel),
        const SizedBox(height: 16),
        _statsView(context, dmodel),
        const SizedBox(height: 16),
        _editButton(context, dmodel),
      ],
    );
  }

  Widget _logo(BuildContext context, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        cv.showFloatingSheet(
          context: context,
          builder: (context) {
            return ImageUploader(team: widget.team);
          },
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.7,
            child: TeamLogo(
              url: widget.team.image,
              size: MediaQuery.of(context).size.width / 2,
            ),
          ),
          Icon(Icons.add_a_photo_outlined,
              color: CustomColors.textColor(context).withOpacity(0.5), size: 50)
        ],
      ),
    );
  }

  Widget _basicInfo(DataModel dmodel, BuildContext context) {
    return cv.Section(
      "Basic Info",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: true,
      child: cv.ListView<Widget>(
        childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "#" + _color,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              if (_showColorError)
                const Icon(Icons.priority_high, color: Colors.red),
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
                            pickerColor: dmodel.color,
                            onColorChanged: (color) {
                              setState(() {
                                _color =
                                    color.value.toRadixString(16).substring(2);
                                _showColorError =
                                    ThemeData.estimateBrightnessForColor(
                                            color) ==
                                        Brightness.light;
                              });
                            },
                            displayThumbColor: false,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: cv.Circle(40, CustomColors.fromHex(_color)),
              ),
            ],
          ),
          cv.TextField2(
            labelText: "Team Note",
            value: _teamNote,
            fieldPadding: const EdgeInsets.all(0),
            validator: (value) => null,
            onChanged: (value) {
              setState(() {
                _teamNote = value;
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
          cv.LabeledWidget(
            "Show Player Nicknames",
            child: FlutterSwitch(
              value: _showNicknames,
              height: 25,
              width: 50,
              toggleSize: 18,
              activeColor: dmodel.color,
              onToggle: (value) {
                setState(() {
                  _showNicknames = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _pos(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: false,
      child: PositionsCreate(positions: _positions),
    );
  }

  Widget _customF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: false,
      child: CustomFieldCreate(
        customFields: _customFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _customUserF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom User Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: false,
      child: CustomFieldCreate(
        customFields: _customUserFields,
        onAdd: () {
          return CustomField(title: "", type: "S", value: "");
        },
      ),
    );
  }

  Widget _statsView(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Stats",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 16, 4),
      allowsCollapse: true,
      initOpen: false,
      child: StatCEList(
        color: dmodel.color,
        team: widget.team,
        stats: _stats,
      ),
    );
  }

  Widget _editButton(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.RoundedLabel(
        "",
        color: dmodel.color,
        child: _isLoading
            ? const cv.LoadingIndicator(color: Colors.white)
            : const Text(
                "Confirm",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
        onTap: () {
          // check custom fields
          for (var i in _customFields) {
            if (i.title == "") {
              dmodel.addIndicator(
                  IndicatorItem.error("Custom field title cannot be blank"));
              return;
            }
          }
          for (var i in _customUserFields) {
            if (i.title == "") {
              dmodel.addIndicator(IndicatorItem.error(
                  "Custom user field title cannot be blank"));
              return;
            }
          }
          _editTeam(context, dmodel);
        },
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
      "isLight": _isLight,
      "teamNote": _teamNote,
      "customFields": _customFields.map((e) => e.toJson()).toList(),
      "positions": _positions.toJson(),
      "showNicknames": _showNicknames,
    };

    // determine whether to add customUserFields
    void addUserFields() {
      body['customUserFields'] =
          _customUserFields.map((e) => e.toJson()).toList();
    }

    if (_customUserFields.length == widget.team.customUserFields.length) {
      for (var i in widget.team.customUserFields) {
        if (!_customUserFields.any((element) => element == i)) {
          addUserFields();
        }
      }
    } else {
      addUserFields();
    }

    // determine whether to add stats
    void addStats() {
      body['stats'] = _stats.toJson();
    }

    // check length
    if (_stats.stats.length != widget.team.stats.stats.length) {
      addStats();
    } else {
      // check for new items
      for (var i in widget.team.stats.stats) {
        if (!_stats.stats.any((element) => element.title == i.title)) {
          addStats();
        }
      }
    }

    print(body);

    await dmodel.updateTeam(widget.team.teamId, body, () {
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
