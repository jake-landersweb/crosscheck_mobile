import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import 'dart:math' as math;

class ECELocation extends StatefulWidget {
  const ECELocation({Key? key}) : super(key: key);

  @override
  _ECELocationState createState() => _ECELocationState();
}

class _ECELocationState extends State<ECELocation> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _location(context, dmodel, ecemodel),
        _color(context, dmodel, ecemodel),
        // if (ecemodel.isCreate) _subs(context, dmodel, ecemodel),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _location(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Location",
        child: cv.ListView<Widget>(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          horizontalPadding: 0,
          children: [
            // location
            cv.TextField2(
              labelText: "Name",
              onChanged: (value) {
                setState(() {
                  ecemodel.event.eventLocation.name = value;
                });
              },
              showBackground: false,
              value: ecemodel.event.eventLocation.name ?? "",
              isLabeled: true,
            ),
            cv.TextField2(
              labelText: "Address",
              onChanged: (value) {
                setState(() {
                  ecemodel.event.eventLocation.address = value;
                });
              },
              showBackground: false,
              value: ecemodel.event.eventLocation.address ?? "",
              isLabeled: true,
            ),
          ],
        ),
      ),
    );
  }

  // final List<String> _availableColors = [
  //   "f97180",
  //   "cb99a7",
  //   "d4afb9",
  //   "fab2a7",
  //   "f0bea6",
  //   "fcc8a7",
  //   "bbccc2",
  //   "9ed6c2",
  //   "6facc8",
  //   "7bc5d6",
  //   "96d8e7",
  //   "9cadce",
  //   "9ec2e3",
  //   "d9aed1",
  //   "dbb3f2",
  //   "f9b5c8",
  // ];

// 415270
  List<String> _availableColors(DataModel dmodel) {
    var list = [
      // red
      "b57070",
      "854a4a",
      // orange
      "aa8073",
      "ac775d",
      // yellow
      "c0aa55",
      "9d8b46",
      // green
      "6d9171",
      "506653",
      // blue
      "547598",
      "495e73",
      // purple
      "81738b",
      "5a525f",
      // greys
      "898992",
      "74767d",
    ];
    if (dmodel.tus!.team.color.isNotEmpty) {
      list.add(dmodel.tus!.team.color);
    }
    return list;
  }

  Widget _color(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return cv.Section(
      "Color:  ${ecemodel.event.eventColor == "" ? "None" : ecemodel.event.eventColor}",
      headerPadding: const EdgeInsets.fromLTRB(32, 8, 0, 4),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            AlignedGridView.count(
              crossAxisCount: 4,
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _availableColors(dmodel).length,
              mainAxisSpacing: 18,
              // crossAxisSpacing: 16,
              itemBuilder: ((context, index) {
                return _colorCell(
                  context,
                  dmodel,
                  ecemodel,
                  _availableColors(dmodel)[index],
                );
              }),
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
                          pickerColor: ecemodel.event.eventColor.isEmpty
                              ? Colors.grey
                              : CustomColors.fromHex(ecemodel.event.eventColor),
                          onColorChanged: (color) {
                            setState(() {
                              ecemodel.event.eventColor =
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
                      _colorCellItem(
                        context,
                        ecemodel.event.eventColor.isEmpty
                            ? "696969"
                            : ecemodel.event.eventColor,
                        ecemodel,
                        showIndicator: !_availableColors(dmodel)
                            .contains(ecemodel.event.eventColor),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        "Custom Color",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color:
                              CustomColors.textColor(context).withOpacity(0.7),
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
    );
  }

  Widget _colorCell(
    BuildContext context,
    DataModel dmodel,
    ECEModel ecemodel,
    String color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        cv.BasicButton(
          onTap: () {
            if (color == ecemodel.event.eventColor) {
              setState(() {
                ecemodel.event.eventColor = "";
              });
            } else {
              setState(() {
                ecemodel.event.eventColor = color;
              });
            }
          },
          child: _colorCellItem(context, color, ecemodel),
        ),
      ],
    );
  }

  Widget _colorCellItem(
    BuildContext context,
    String color,
    ECEModel ecemodel, {
    bool showIndicator = true,
  }) {
    Color col = CustomColors.fromHex(color);
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: math.pi / 4,
          child: ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect rect) {
              return LinearGradient(
                stops: const [0, 0.5, 0.5],
                colors: [
                  col,
                  col,
                  col.lighten(0.1),
                ],
              ).createShader(rect);
            },
            child: Container(
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Colors.white),
              width: 50,
              height: 50,
            ),
          ),
        ),
        ecemodel.event.eventColor == color && showIndicator
            ? Container(
                decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: Colors.white, width: 3),
                    shape: BoxShape.circle),
                height: 40,
                width: 40,
              )
            : Container(),
      ],
    );
  }
}
