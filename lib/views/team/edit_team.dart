import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../extras/root.dart';
import '../menu/root.dart';
import '../../custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _basicInfo(dmodel, context),
        ),
        _customF(context, dmodel),
        const SizedBox(height: 16),
        _editButton(context, dmodel),
      ],
    );
  }

  Widget _basicInfo(DataModel dmodel, BuildContext context) {
    return cv.Section(
      "Basic Info",
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
          Row(
            children: [
              FlutterSwitch(
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
              const Spacer(),
              const SizedBox(height: 50),
              Text(
                "Light Background",
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
    );
  }

  Widget _customF(BuildContext context, DataModel dmodel) {
    return cv.Section(
      "Custom Fields",
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
    Map<String, dynamic> body = {
      "color": _color,
      "image": _image,
      "isLight": _isLight,
      "customFields": _customFields.map((e) => e.toJson()).toList(),
    };

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

class CustomFieldField extends StatefulWidget {
  const CustomFieldField({
    Key? key,
    required this.item,
  }) : super(key: key);
  final CustomField item;

  @override
  _CustomFieldFieldState createState() => _CustomFieldFieldState();
}

class _CustomFieldFieldState extends State<CustomFieldField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        cv.TextField(
          fieldPadding: const EdgeInsets.all(0),
          showBackground: false,
          initialvalue: widget.item.title,
          isLabeled: true,
          labelText: "Title",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.title = value;
          },
          validator: (value) {},
        ),
        cv.SegmentedPicker(
          initialSelection: widget.item.type,
          titles: const ["Word", "Number", "True/False"],
          selections: const ["S", "I", "B"],
          onSelection: (value) {
            setState(() {
              widget.item.setType(value);
            });
          },
        ),
        SizedBox(height: 50, child: Center(child: _valField(context))),
      ],
    );
  }

  Widget _valField(BuildContext context) {
    switch (widget.item.type) {
      case "S":
        return cv.TextField(
          fieldPadding: const EdgeInsets.all(0),
          showBackground: false,
          isLabeled: true,
          initialvalue: widget.item.stringVal ?? "",
          labelText: "Value",
          charLimit: 25,
          showCharacters: true,
          onChanged: (value) {
            widget.item.setStringVal(value);
          },
          validator: (value) {},
        );
      case "I":
        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    child: Center(
                      child: Text(
                        (widget.item.intVal ?? 0).toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  cv.NumberPicker(
                    minValue: -100,
                    maxValue: 100,
                    onMinusClick: (value) {
                      setState(() {
                        widget.item.setIntVal(value);
                      });
                    },
                    onPlusClick: (value) {
                      setState(() {
                        widget.item.setIntVal(value);
                      });
                    },
                  ),
                ],
              ),
            ),
            Text(
              "Value",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        );
      default:
        return Row(
          children: [
            SizedBox(
              height: 25,
              child: FlutterSwitch(
                value: widget.item.boolVal ?? false,
                height: 25,
                width: 50,
                toggleSize: 18,
                activeColor: Theme.of(context).colorScheme.primary,
                onToggle: (value) {
                  setState(() {
                    widget.item.setBoolVal(value);
                  });
                },
              ),
            ),
            const Spacer(),
            Text(
              "Value",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.7)
                    : Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        );
    }
  }
}
