import 'dart:io';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';

class UploadCalendar extends StatefulWidget {
  const UploadCalendar({
    super.key,
    required this.teamId,
    required this.seasonId,
  });
  final String teamId;
  final String seasonId;

  @override
  State<UploadCalendar> createState() => _UploadCalendarState();
}

class _UploadCalendarState extends State<UploadCalendar> {
  String _contents = "";
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Upload Calendar",
      leading: [cv.CancelButton(color: dmodel.color)],
      children: [
        cv.BasicButton(
          onTap: () {
            _selectFile();
          },
          child: Center(
            child: Text("Select File:", style: TextStyle(color: dmodel.color)),
          ),
        ),
        if (_contents.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: cv.BasicButton(
              onTap: () {
                _upload(dmodel);
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 50),
                decoration: BoxDecoration(
                  color: CustomColors.cellColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: _loading
                            ? cv.LoadingIndicator(color: dmodel.color)
                            : const Text("Upload"),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        Text(_contents),
      ],
    );
  }

  Future<void> _selectFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['ics'],
    );
    if (result != null && result.files.single.path != null) {
      File file = File(result.files.single.path!);
      var contents = await file.readAsString();
      setState(() {
        _contents = contents;
      });
    } else {
      // User canceled the picker
    }
  }

  Future<void> _upload(DataModel dmodel) async {
    setState(() {
      _loading = true;
    });

    await dmodel.uploadCalendar(
      widget.teamId,
      widget.seasonId,
      _contents,
      () {
        RestartWidget.restartApp(context);
      },
    );

    setState(() {
      _loading = false;
    });
  }
}
