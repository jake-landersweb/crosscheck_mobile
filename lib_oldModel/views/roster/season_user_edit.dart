import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';

class SeasonUserEdit extends StatefulWidget {
  const SeasonUserEdit({
    Key? key,
    required this.user,
    required this.teamId,
    required this.seasonId,
    required this.completion,
    this.editNickname,
  }) : super(key: key);
  final SeasonUser user;
  final String teamId;
  final String seasonId;
  final VoidCallback completion;
  final bool? editNickname;

  @override
  _SeasonUserEditState createState() => _SeasonUserEditState();
}

class _SeasonUserEditState extends State<SeasonUserEdit> {
  late String _firstName;
  late String _lastName;
  late String _phone;
  late String _nickName;

  @override
  void initState() {
    super.initState();
    _firstName = widget.user.userFields?.firstName ?? "";
    _lastName = widget.user.userFields?.lastName ?? "";
    _phone = widget.user.userFields?.phone ?? "";
    _nickName = widget.user.seasonFields?.nickName ?? "";
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Edit ${widget.user.seasonName()}",
      titlePadding: const EdgeInsets.only(left: 8),
      leading: cv.BackButton(
        color: dmodel.color,
      ),
      children: [
        const SizedBox(height: 16),
        cv.NativeList(
          children: [
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                cv.TextField(
                  labelText: "First Name",
                  showBackground: false,
                  initialvalue: _firstName,
                  keyboardType: TextInputType.name,
                  validator: (value) {},
                  onChanged: (value) {
                    _firstName = value;
                  },
                ),
                Text(
                  "First Name",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                cv.TextField(
                  labelText: "Last Name",
                  showBackground: false,
                  initialvalue: _lastName,
                  keyboardType: TextInputType.name,
                  validator: (value) {},
                  onChanged: (value) {
                    _lastName = value;
                  },
                ),
                Text(
                  "Last Name",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
            Stack(
              alignment: AlignmentDirectional.centerEnd,
              children: [
                cv.TextField(
                  labelText: "Phone",
                  showBackground: false,
                  initialvalue: _phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {},
                  onChanged: (value) {
                    _phone = value;
                  },
                ),
                Text(
                  "Phone",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ],
            ),
            if (widget.editNickname ?? true)
              Stack(
                alignment: AlignmentDirectional.centerEnd,
                children: [
                  cv.TextField(
                    labelText: "Nickname",
                    showBackground: false,
                    initialvalue: _nickName,
                    keyboardType: TextInputType.name,
                    validator: (value) {},
                    onChanged: (value) {
                      _nickName = value;
                    },
                  ),
                  Text(
                    "Nickname",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: CustomColors.textColor(context).withOpacity(0.7),
                    ),
                  ),
                ],
              ),
          ],
        ),
        cv.Section(
          "",
          child: cv.BasicButton(
            onTap: () {
              _update(context, dmodel);
            },
            child: cv.NativeList(
              itemPadding: const EdgeInsets.all(16),
              children: [
                Text(
                  "Update",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: dmodel.color),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  void _update(BuildContext context, DataModel dmodel) async {
    if (_firstName == "") {
      dmodel.setError("First name cannot be blank", true);
    } else if (_lastName == "") {
      dmodel.setError("Last name cannot be blank", true);
    } else {
      if (widget.user.seasonFields == null) {
        await dmodel.teamUserUpdate(
            widget.teamId, widget.user.email, _firstName, _lastName, _phone,
            () {
          Navigator.of(context).pop();
          widget.completion();
        });
      } else {
        await dmodel.seasonUserUpdate(widget.teamId, widget.seasonId,
            widget.user.email, _firstName, _lastName, _phone, _nickName, () {
          Navigator.of(context).pop();
          widget.completion();
        });
      }
    }
  }
}
