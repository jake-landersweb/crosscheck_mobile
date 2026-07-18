import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/custom_views/timezone_select.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../components/root.dart' as comp;
import 'package:crosscheck_sports/components/layer/snapping_sheet.dart';
import 'package:crosscheck_sports/components/core/clickable.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/section.dart';

class TSCEBasic extends StatefulWidget {
  const TSCEBasic({super.key});

  @override
  State<TSCEBasic> createState() => _TSCEBasicState();
}

class _TSCEBasicState extends State<TSCEBasic> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _body(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _body(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    var model = Provider.of<TSCEModel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          XCSection(
            "Required",
            child: XCCellList<Widget>(
              childPadding: const EdgeInsets.only(right: 16),
              horizontalPadding: 0,
              minHeight: 50,
              children: [
                Center(
                  child: XCField(
              labelText: "Team Name",
              controller: model.teamName,
              onChanged: (v) {},
            ),
                ),
                Center(
                  child: XCField(
              labelText: "Season",
              hintText: "First Season Name",
              controller: model.seasonName,
              onChanged: (v) {},
            ),
                ),
              ],
            ),
          ),
          XCSection(
            "Optional Info",
            child: XCCellList<Widget>(
              childPadding: const EdgeInsets.only(right: 16),
              horizontalPadding: 0,
              minHeight: 50,
              children: [
                Clickable(
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
                              pickerColor: model.color.isEmpty
                                  ? dmodel.color
                                  : CustomColors.fromHex(model.color),
                              onColorChanged: (color) {
                                setState(() {
                                  model.color = color.value
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
                  child: Center(
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              "Accent Color: #${model.color}",
                              style: TextStyle(
                                fontSize: 16,
                                color: CustomColors.textColor(context)
                                    .withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: model.color.isEmpty
                                ? dmodel.color
                                : CustomColors.fromHex(model.color),
                            shape: BoxShape.circle,
                          ),
                          height: 30,
                          width: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Light App",
                            style: TextStyle(
                              fontSize: 16,
                              color: CustomColors.textColor(context)
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      FlutterSwitch(
                        value: model.isLight,
                        height: 25,
                        width: 50,
                        toggleSize: 18,
                        activeColor: CustomColors.fromHex(model.color),
                        onToggle: (value) {
                          setState(() {
                            model.isLight = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            "Show Nicknames",
                            style: TextStyle(
                              fontSize: 16,
                              color: CustomColors.textColor(context)
                                  .withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      FlutterSwitch(
                        value: model.showNicknames,
                        height: 25,
                        width: 50,
                        toggleSize: 18,
                        activeColor: CustomColors.fromHex(model.color),
                        onToggle: (value) {
                          setState(() {
                            model.showNicknames = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Center(
                  child: XCField(
              labelText: "Website",
              onChanged: (v) {
                      setState(() {
                        model.website = v;
                      });
                    },
            ),
                ),
                Center(
                  child: XCField(
              labelText: "Notes",
              onChanged: (v) {
                      setState(() {
                        model.seasonNote = v;
                      });
                    },
            ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Clickable(
            onTap: () {
              showSnappingSheet(
      context: context,
      child: TimezoneSelector(
                  initTimezone: model.timezone,
                  onSelect: (v) {
                    setState(() {
                      model.timezone = v;
                    });
                  },
                ),
    );
            },
            child: comp.ListWrapper(
              child: Text(
                "Timezone: ${model.timezone}",
                style: TextStyle(
                  fontSize: 18,
                  color: CustomColors.textColor(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
