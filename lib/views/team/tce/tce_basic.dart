import 'package:crosscheck_sports/views/team/tce/image_uploader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TCEBasic extends StatefulWidget {
  const TCEBasic({Key? key}) : super(key: key);

  @override
  _TCEBasicState createState() => _TCEBasicState();
}

class _TCEBasicState extends State<TCEBasic> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    TCEModel tcemodel = Provider.of<TCEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        if (tcemodel.isCreate) _title(context, tcemodel, dmodel),
        _body(context, tcemodel, dmodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _logo(BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return Column(
      children: [
        cv.BasicButton(
          onTap: () {
            cv.showFloatingSheet(
              context: context,
              builder: (context) {
                return ImageUploader(
                  team: tcemodel.team,
                  imgIsUrl: tcemodel.imgIsUrl,
                  onImageChange: (img) {
                    setState(() {
                      tcemodel.team.image = img;
                      dmodel.tus!.team.image = img;
                    });
                  },
                );
              },
            );
          },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Opacity(
                opacity: 0.7,
                child: TeamLogo(
                  url: tcemodel.team.image,
                  size: MediaQuery.of(context).size.width / 2,
                  color: dmodel.color,
                ),
              ),
              Icon(Icons.add_a_photo_outlined,
                  color: CustomColors.textColor(context).withOpacity(0.5),
                  size: 50)
            ],
          ),
        ),
      ],
    );
  }

  Widget _title(BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Title",
        child: cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            cv.TextField2(
              labelText: "Title (CANNOT CHANGE)",
              value: tcemodel.team.title,
              showBackground: false,
              onChanged: (value) {
                setState(() {
                  tcemodel.team.title = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context, TCEModel tcemodel, DataModel dmodel) {
    return cv.Section(
      "Basic Info",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 8, 4),
      allowsCollapse: true,
      initOpen: true,
      helperTitle: "Hints",
      color: dmodel.color,
      helperView: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            cv.Section(
              "Color",
              child: Text(
                  "The color will control the color you and your users see throughout the entire app. Make sure to be careful placing light colors on a light background, or a dark color on a dark background as this will impact your user's experience."),
            ),
            cv.Section(
              "Light Background",
              child: Text(
                  "Whether the app will have a light or dark background. This will control what your users see as well, so if your logo looks better with a dark themed app control that here."),
            ),
            cv.Section(
              "Show Nicknames",
              child: Text(
                  "Users have control over a nickname field, so if you would like all names to be replaced in app with these nicknames, control that here"),
            ),
            cv.Section(
              "Note",
              child: Text(
                  "All of these fields can be changed later, so no need to commit now!"),
            ),
          ],
        );
      },
      child: cv.ListView<Widget>(
        childPadding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tcemodel.team.color.isEmpty
                      ? "Default"
                      : "#${tcemodel.team.color}",
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
                                tcemodel.team.color =
                                    color.value.toRadixString(16).substring(2);
                                // _showColorError =
                                //     ThemeData.estimateBrightnessForColor(
                                //             color) ==
                                //         Brightness.light;
                              });
                            },
                            displayThumbColor: false,
                          ),
                        ),
                      );
                    },
                  );
                },
                child: cv.Circle(40, _getColor(tcemodel)),
              ),
            ],
          ),
          cv.TextField2(
            labelText: "Team Note",
            value: tcemodel.team.teamNote,
            fieldPadding: const EdgeInsets.all(0),
            onChanged: (value) {
              setState(() {
                tcemodel.team.teamNote = value;
              });
            },
          ),
          cv.LabeledWidget(
            "Light Background",
            child: Row(
              children: [
                FlutterSwitch(
                  value: tcemodel.team.isLight,
                  height: 25,
                  width: 50,
                  toggleSize: 18,
                  activeColor: dmodel.color,
                  onToggle: (value) {
                    setState(() {
                      tcemodel.team.isLight = value;
                    });
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
          cv.LabeledWidget(
            "Show Player Nicknames",
            child: Row(
              children: [
                FlutterSwitch(
                  value: tcemodel.team.showNicknames,
                  height: 25,
                  width: 50,
                  toggleSize: 18,
                  activeColor: dmodel.color,
                  onToggle: (value) {
                    setState(() {
                      tcemodel.team.showNicknames = value;
                    });
                  },
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColor(TCEModel tcemodel) {
    try {
      return CustomColors.fromHex(tcemodel.team.color);
    } catch (error) {
      return CustomColors.base();
    }
  }
}
