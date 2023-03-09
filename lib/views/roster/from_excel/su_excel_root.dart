import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/extensions.dart';
import 'package:crosscheck_sports/views/roster/from_excel/root.dart';
import 'package:crosscheck_sports/views/roster/from_excel/su_excel_edit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:url_launcher/url_launcher.dart';
import '../../components/root.dart' as comp;
import 'package:excel/excel.dart';

class SUFromExcel extends StatefulWidget {
  const SUFromExcel({
    super.key,
    this.positions = const [],
    required this.onCreate,
    required this.onDispose,
    this.actionText = "Upload",
  });
  final List<String> positions;
  final Future<bool> Function(List<SUExcel> users) onCreate;
  final VoidCallback onDispose;
  final String actionText;

  @override
  State<SUFromExcel> createState() => _SUFromExcelState();
}

class _SUFromExcelState extends State<SUFromExcel> {
  List<SUExcel> _users = [];
  bool _isLoading = false;
  bool _isLoadingExcel = false;

  @override
  void initState() {
    context.read<DataModel>().blockRefresh = true;
    super.initState();
  }

  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Upload Excel",
      leading: [cv.CancelButton(color: dmodel.color)],
      trailing: [
        cv.BasicButton(
          onTap: () {
            if (!_isLoading && _users.isNotEmpty) {
              _onComplete(context);
            }
          },
          child: _isLoading
              ? cv.LoadingIndicator(color: dmodel.color)
              : Text(
                  widget.actionText,
                  style: TextStyle(
                    fontSize: 18,
                    color: _users.isEmpty
                        ? CustomColors.textColor(context).withOpacity(0.5)
                        : dmodel.color,
                  ),
                ),
        )
      ],
      children: [
        cv.ListView<Tuple3<String, IconData, Color>>(
          children: [
            Tuple3("Download Template", Icons.newspaper_rounded, Colors.green),
            Tuple3("Upload Template", Icons.upload_rounded, Colors.grey),
          ],
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          onChildTap: (context, item) async {
            switch (item.v1) {
              case "Download Template":
                _launchUrl(dmodel);
                break;
              case "Upload Template":
                _selectFile(dmodel);
                break;
            }
          },
          childBuilder: (context, item) {
            return ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 50),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: item.v3,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Icon(
                        item.v2,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    item.v1,
                    style: TextStyle(
                      fontSize: 18,
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (_isLoadingExcel)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: SizedBox(
              height: 30,
              child: cv.LoadingIndicator(color: dmodel.color),
            ),
          ),
        if (_users.isNotEmpty)
          cv.Section(
            "User Preivew",
            allowsCollapse: true,
            initOpen: true,
            animateOpen: true,
            child: cv.ListView<SUExcel>(
              children: _users,
              horizontalPadding: 0,
              childBuilder: (context, item) => _userCell(context, item),
              onChildTap: (context, item) {
                cv.cupertinoSheet(
                  context: context,
                  builder: (context) => SUExcelEdit(
                    user: item,
                    onEmailChanged: (v) => setState(
                      () => item.email = v,
                    ),
                    onNameChanged: (v) => setState(
                      () => item.name = v,
                    ),
                    onPhoneChanged: (v) => setState(
                      () => item.phone = v,
                    ),
                    onNicknameChanged: (v) => setState(
                      () => item.nickname = v,
                    ),
                    onPositionChanged: (v) => setState(
                      () => item.position = v,
                    ),
                    onJerseySizeChanged: (v) => setState(
                      () => item.jerseySize = v,
                    ),
                    onJerseyNumberChanged: (v) => setState(
                      () => item.jerseyNumber = v,
                    ),
                    onIsManagerChanged: (v) => setState(
                      () => item.isManager = v,
                    ),
                    onIsSubChanged: (v) => setState(
                      () => item.isSub = v,
                    ),
                    onNoteChanged: (v) => setState(
                      () => item.note = v,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _userCell(BuildContext context, SUExcel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _userCellItem(context, "Email", user.email),
        _userCellItem(context, "Name", user.name),
        _userCellItem(context, "Phone", user.phone),
        _userCellItem(context, "Nickname", user.nickname),
        _userCellItem(context, "Position", user.position),
        if (widget.positions.isNotEmpty &&
            !widget.positions.contains(user.position))
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow[300]),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Warning: This position is not in your default season list.",
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        _userCellItem(context, "Jersey Size", user.jerseySize),
        _userCellItem(context, "Jersey Number", user.jerseyNumber),
        _userCellItem(
            context, "Is a Manager", user.isManager ? "TRUE" : "FALSE"),
        _userCellItem(context, "Is a Sub", user.isSub ? "TRUE" : "FALSE"),
        _userCellItem(context, "Note", user.note),
      ],
    );
  }

  Widget _userCellItem(
    BuildContext context,
    String label,
    String value,
  ) {
    if (value.isEmpty) {
      return Container();
    } else {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "$label:",
              style: TextStyle(
                color: CustomColors.textColor(context).withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                value,
                style: TextStyle(
                  color: CustomColors.textColor(context),
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _launchUrl(DataModel dmodel) async {
    var uri = Uri.parse(
        "https://www.crosschecksports.com/docs/xcheck_roster_input.xlsx");
    if (!await launchUrl(uri)) {
      dmodel.addIndicator(
          IndicatorItem.error("There was an issue downloading the file"));
    }
  }

  Future<void> _selectFile(DataModel dmodel) async {
    setState(() {
      _isLoadingExcel = true;
    });
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['.xlsx'],
      );
      if (result != null && result.files.single.path != null) {
        _users = [];
        File file = File(result.files.single.path!);
        var bytes = await file.readAsBytes();
        var excel = Excel.decodeBytes(bytes);
        if (!excel.tables.containsKey("Sheet1")) {
          dmodel.addIndicator(IndicatorItem.error(
              "Error: 'Sheet1' must exist in the excel file"));
          return;
        }
        var table = excel.tables['Sheet1']!;

        if (table.rows.length < 3) {
          dmodel.addIndicator(IndicatorItem.error(
              "Error: The excel sheet must have at least one user"));
          return;
        }
        for (var row in table.rows.sublist(2)) {
          try {
            _users.add(SUExcel.fromExcelData(row));
          } catch (e) {
            dmodel.addIndicator(IndicatorItem.error(e.toString()));
            _users = [];
            return;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print("[ERROR] $e");
      dmodel.addIndicator(
        IndicatorItem.error("There was an issue picking the file"),
      );
    }
    setState(() {
      _isLoadingExcel = false;
    });
  }

  Future<void> _onComplete(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    var response = await widget.onCreate(_users);

    if (response) {
      Navigator.of(context).pop();
    }

    setState(() {
      _isLoading = false;
    });
  }
}
