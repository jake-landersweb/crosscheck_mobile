import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/views/components/root.dart' as comp;
import 'dart:math' as math;

class CalendarAdvancedSettings extends StatelessWidget {
  const CalendarAdvancedSettings({
    super.key,
    required this.timezone,
    required this.onTimezoneChanged,
    required this.parseOpponents,
    required this.onParseOpponentsChanged,
    required this.ignoreString,
    required this.onIgnoreStringChanged,
  });

  final String timezone;
  final void Function(String tz) onTimezoneChanged;
  final bool parseOpponents;
  final void Function(bool v) onParseOpponentsChanged;
  final String ignoreString;
  final void Function(String v) onIgnoreStringChanged;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.Section(
      "Advanced Settings",
      allowsCollapse: true,
      initOpen: false,
      child: Column(
        children: [
          cv.BasicButton(
            onTap: () {
              cv.cupertinoSheet(
                context: context,
                builder: (context) => cv.TimezoneSelector(
                  initTimezone: timezone,
                  onSelect: (tz) => onTimezoneChanged(tz),
                ),
              );
            },
            child: Container(
              constraints: const BoxConstraints(
                minHeight: 50,
              ),
              decoration: BoxDecoration(
                color: CustomColors.cellColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: cv.LabeledCell(
                  label: "Time zone",
                  value: timezone,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "If enabled, Crosscheck will attempt to extract the opponent name from the calendar titles.",
            style: TextStyle(
              fontSize: 14,
              color: CustomColors.textColor(context).withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(
              minHeight: 50,
            ),
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: cv.LabeledWidget(
                "Parse Opponents",
                child: Row(
                  children: [
                    FlutterSwitch(
                      value: parseOpponents,
                      height: 25,
                      width: 50,
                      toggleSize: 18,
                      activeColor: dmodel.color,
                      onToggle: (value) => onParseOpponentsChanged(value),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "If there are specific phrases you want to exclude from the parsed titles, enter them here. (Each phrase separated by a comma)",
            style: TextStyle(
              fontSize: 14,
              color: CustomColors.textColor(context).withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Opacity(
            opacity: parseOpponents ? 1 : 0.5,
            child: cv.TextField2(
              value: ignoreString,
              labelText: "Ignore",
              labelEdgePadding: 16,
              hintText: "Ignore String",
              enabled: parseOpponents,
              maxLines: 4,
              onChanged: (val) => onIgnoreStringChanged(val),
            ),
          ),
        ],
      ),
    );
  }
}
