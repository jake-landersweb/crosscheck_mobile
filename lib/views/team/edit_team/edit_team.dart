import 'package:flutter/material.dart';
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
  late String _image;
  late bool _isLight;

  late TeamPositions _positions;

  late List<CustomField> _customFields;
  late List<CustomUserField> _customUserFields;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _color =
        context.read<DataModel>().color.value.toRadixString(16).substring(2);
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

  Widget pickerItemBuilder(
      Color color, bool isCurrentColor, void Function() changeColor) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.8),
              offset: const Offset(1, 2),
              blurRadius: 1)
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: changeColor,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isCurrentColor ? 1 : 0,
            child: Icon(
              Icons.done,
              size: 20,
              color: useWhiteForeground(color) ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget pickerLayoutBuilder(
      BuildContext context, List<Color> colors, PickerItem child) {
    Orientation orientation = MediaQuery.of(context).orientation;

    return SizedBox(
      width: 300,
      height: orientation == Orientation.portrait ? 360 : 240,
      child: GridView.count(
        crossAxisCount: orientation == Orientation.portrait ? 3 : 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        children: [for (Color color in colors) child(color)],
      ),
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    "#" + _color,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
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
                                  _color = color.value
                                      .toRadixString(16)
                                      .substring(2);
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

  Widget _pos(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Positions",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: false,
      child: PositionsCreate(positions: _positions),
    );
  }

  Widget _customF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
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
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: false,
      child: CustomFieldCreate(
        customFields: _customUserFields,
        onAdd: () {
          return CustomUserField(title: "", type: "S", defaultValue: "");
        },
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
            height: cellHeight,
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
