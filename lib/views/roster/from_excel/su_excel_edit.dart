
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/views/roster/from_excel/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/core/labeled_row.dart';

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
    return HeaderBar.sheet(
      title: "Edit User",
      trailing: XCActionButton.cancel(),
      child: Column(
        children: [
        XCCellList<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.only(right: 16),
          children: [
            XCField(
              labelText: "Email",
              maxLines: 2,
              value: widget.user.email,
              icon: const Icon(Icons.email_rounded),
              onChanged: widget.onEmailChanged,
            ),
            XCField(
              labelText: "Name",
              maxLines: 2,
              value: widget.user.name,
              icon: const Icon(Icons.person_rounded),
              onChanged: widget.onNameChanged,
            ),
            XCField(
              labelText: "Phone",
              maxLines: 2,
              value: widget.user.phone,
              icon: const Icon(Icons.phone_rounded),
              onChanged: widget.onPhoneChanged,
            ),
            XCField(
              labelText: "Nickname",
              maxLines: 2,
              value: widget.user.nickname,
              icon: const Icon(Icons.person_rounded),
              onChanged: widget.onNicknameChanged,
            ),
            XCField(
              labelText: "Position",
              maxLines: 2,
              value: widget.user.position,
              icon: const Icon(Icons.location_on_rounded),
              onChanged: widget.onPositionChanged,
            ),
            XCField(
              labelText: "Jersey Size",
              maxLines: 2,
              value: widget.user.jerseySize,
              icon: const Icon(Icons.format_size_rounded),
              onChanged: widget.onJerseySizeChanged,
            ),
            XCField(
              labelText: "Jersey Number",
              maxLines: 2,
              value: widget.user.jerseyNumber,
              icon: const Icon(Icons.looks_3_rounded),
              onChanged: widget.onJerseyNumberChanged,
            ),
            XCField(
              labelText: "Note",
              maxLines: 2,
              value: widget.user.note,
              icon: const Icon(Icons.description_rounded),
              onChanged: widget.onNoteChanged,
            ),
          ],
        ),
        const SizedBox(height: 16),
        XCCellList<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            XCLabeledWidget(
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
            XCLabeledWidget(
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
      ),
    );
  }
}
