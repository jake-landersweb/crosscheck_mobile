import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../client/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';

class UserStatusSelect extends StatefulWidget {
  const UserStatusSelect({
    Key? key,
    required this.onSelect,
    this.initialSelection,
    this.isAdd = false,
  }) : super(key: key);
  final Function(int) onSelect;
  final int? initialSelection;
  final bool isAdd;

  @override
  _UserStatusSelectState createState() => _UserStatusSelectState();
}

class _UserStatusSelectState extends State<UserStatusSelect> {
  late int _selection;

  @override
  void initState() {
    super.initState();
    if (widget.initialSelection != null) {
      _selection = widget.initialSelection!;
    } else {
      _selection = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "User Status",
      color: dmodel.color,
      closeText: "Done",
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: widget.isAdd
              ? [
                  _userStatusCell(context, 3, "Recruit", dmodel.color),
                  const SizedBox(height: 8),
                  _userStatusCell(context, 5, "Sub Recruit", dmodel.color),
                ]
              : [
                  _userStatusCell(context, -1, "Inactive", dmodel.color),
                  const SizedBox(height: 8),
                  _userStatusCell(context, 1, "Active", dmodel.color),
                  const SizedBox(height: 8),
                  _userStatusCell(context, 3, "Recruit", dmodel.color),
                  const SizedBox(height: 8),
                  _userStatusCell(context, 4, "Invited", dmodel.color),
                ],
        ),
      ),
    );
  }

  Widget _userStatusCell(
      BuildContext context, int status, String title, Color color) {
    return cv.BasicButton(
      onTap: () {
        setState(() {
          _selection = status;
        });
        widget.onSelect(_selection);
      },
      child: Material(
        color: status == _selection ? color : Colors.transparent,
        shape:
            ContinuousRectangleBorder(borderRadius: BorderRadius.circular(40)),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: status == _selection
                    ? Colors.white
                    : CustomColors.textColor(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
