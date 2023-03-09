import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/extensions.dart';
import 'package:crosscheck_sports/views/roster/from_excel/root.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:url_launcher/url_launcher.dart';
import '../../components/root.dart' as comp;
import 'package:excel/excel.dart';

class SUExcelEdit extends StatefulWidget {
  const SUExcelEdit({
    super.key,
    required this.user,
    required this.onEmailChanged,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onNicknameChanged,
    required this.onPositionChanged,
    required this.onJerseySizeChanged,
    required this.onJerseyNumberChanged,
    required this.onIsManagerChanged,
    required this.onIsSubChanged,
    required this.onNoteChanged,
  });

  final SUExcel user;
  final Function(String v) onEmailChanged;
  final Function(String v) onNameChanged;
  final Function(String v) onPhoneChanged;
  final Function(String v) onNicknameChanged;
  final Function(String v) onPositionChanged;
  final Function(String v) onJerseySizeChanged;
  final Function(String v) onJerseyNumberChanged;
  final Function(bool v) onIsManagerChanged;
  final Function(bool v) onIsSubChanged;
  final Function(String v) onNoteChanged;

  @override
  State<SUExcelEdit> createState() => _SUExcelEditState();
}

class _SUExcelEditState extends State<SUExcelEdit> {
  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Edit User",
      trailing: [cv.CancelButton(color: dmodel.color, closeText: "Done")],
      children: [
        cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.only(right: 16),
          children: [
            cv.TextField2(
              labelText: "Email",
              maxLines: 2,
              value: widget.user.email,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.email_rounded),
              onChanged: widget.onEmailChanged,
            ),
            cv.TextField2(
              labelText: "Name",
              maxLines: 2,
              value: widget.user.name,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.person_rounded),
              onChanged: widget.onNameChanged,
            ),
            cv.TextField2(
              labelText: "Phone",
              maxLines: 2,
              value: widget.user.phone,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.phone_rounded),
              onChanged: widget.onPhoneChanged,
            ),
            cv.TextField2(
              labelText: "Nickname",
              maxLines: 2,
              value: widget.user.nickname,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.person_rounded),
              onChanged: widget.onNicknameChanged,
            ),
            cv.TextField2(
              labelText: "Position",
              maxLines: 2,
              value: widget.user.position,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.location_on_rounded),
              onChanged: widget.onPositionChanged,
            ),
            cv.TextField2(
              labelText: "Jersey Size",
              maxLines: 2,
              value: widget.user.jerseySize,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.format_size_rounded),
              onChanged: widget.onJerseySizeChanged,
            ),
            cv.TextField2(
              labelText: "Jersey Number",
              maxLines: 2,
              value: widget.user.jerseyNumber,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.looks_3_rounded),
              onChanged: widget.onJerseyNumberChanged,
            ),
            cv.TextField2(
              labelText: "Note",
              maxLines: 2,
              value: widget.user.note,
              highlightColor: dmodel.color,
              icon: const Icon(Icons.description_rounded),
              onChanged: widget.onNoteChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        cv.ListView<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            cv.LabeledWidget(
              "Is a Manager",
              child: Row(
                children: [
                  FlutterSwitch(
                    value: widget.user.isManager,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (v) {
                      setState(() {
                        widget.onIsManagerChanged(v);
                      });
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
            cv.LabeledWidget(
              "Is a Sub",
              child: Row(
                children: [
                  FlutterSwitch(
                    value: widget.user.isSub,
                    height: 25,
                    width: 50,
                    toggleSize: 18,
                    activeColor: dmodel.color,
                    onToggle: (v) {
                      setState(() {
                        widget.onIsSubChanged(v);
                      });
                    },
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
