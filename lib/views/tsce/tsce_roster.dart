import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/custom_views/timezone_select.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/roster/from_excel/root.dart';
import 'package:crosscheck_sports/views/roster/from_excel/su_excel_edit.dart';
import 'package:crosscheck_sports/views/roster/from_excel/su_excel_root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;
import 'dart:math' as math;

class TSCERoster extends StatefulWidget {
  const TSCERoster({super.key});

  @override
  State<TSCERoster> createState() => _TSCERosterState();
}

class _TSCERosterState extends State<TSCERoster> {
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
          const SizedBox(height: 16),
          cv.BasicButton(
            onTap: () {
              cv.cupertinoSheet(
                context: context,
                builder: (context) {
                  return SUFromExcel(
                    actionText: "Save",
                    positions: model.positions.available,
                    onCreate: (users) async {
                      setState(() {
                        model.users = users;
                        model.autoPositions = true;
                      });
                      return true;
                    },
                    onDispose: () {
                      dmodel.blockRefresh = false;
                    },
                  );
                },
              );
            },
            child: comp.ListWrapper(
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.newspaper_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      "Add Users From Excel",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: CustomColors.textColor(context),
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: -math.pi / 2,
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (model.users.isNotEmpty)
            cv.Section(
              "User Preivew",
              allowsCollapse: true,
              initOpen: true,
              animateOpen: true,
              child: cv.ListView<SUExcel>(
                children: model.users,
                horizontalPadding: 0,
                childBuilder: (context, item) =>
                    _userCell(context, model, item),
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
      ),
    );
  }

  Widget _userCell(BuildContext context, TSCEModel model, SUExcel user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _userCellItem(context, "Email", user.email),
        _userCellItem(context, "Name", user.name),
        _userCellItem(context, "Phone", user.phone),
        _userCellItem(context, "Nickname", user.nickname),
        _userCellItem(context, "Position", user.position),
        if (!model.autoPositions &&
            model.positions.available.isNotEmpty &&
            !model.positions.available.contains(user.position))
          Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.yellow[300]),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  "Warning: This position is not in your position list.",
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
}
