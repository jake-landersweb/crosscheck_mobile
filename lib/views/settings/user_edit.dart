import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/main.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;

class UserEdit extends StatefulWidget {
  const UserEdit({
    Key? key,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.nickname,
  }) : super(key: key);

  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? nickname;

  @override
  State<UserEdit> createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  late String _firstName;
  late String _lastName;
  late String _phone;
  late String _nickname;

  bool _isLoading = false;

  @override
  void initState() {
    _firstName = widget.firstName ?? "";
    _lastName = widget.lastName ?? "";
    _phone = widget.phone ?? "";
    _nickname = widget.nickname ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Edit User",
      isLarge: true,
      leading: [
        cv.BackButton(
          title: "Cancel",
          color: dmodel.color,
          showIcon: false,
          showText: true,
        ),
      ],
      children: [
        cv.ListView(
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          horizontalPadding: 0,
          children: [
            _firstNameField(context, dmodel),
            _lastNameField(context, dmodel),
            _phoneField(context, dmodel),
            _nicknameField(context, dmodel),
          ],
        ),
        const SizedBox(height: 16),
        _button(context, dmodel)
      ],
    );
  }

  Widget _firstNameField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "First Name",
      isLabeled: true,
      showBackground: false,
      value: _firstName,
      onChanged: (value) {
        setState(() {
          _firstName = value;
        });
      },
      validator: (value) => null,
    );
  }

  Widget _lastNameField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "Last Name",
      isLabeled: true,
      showBackground: false,
      value: _lastName,
      onChanged: (value) {
        _lastName = value;
      },
      validator: (value) => null,
    );
  }

  Widget _phoneField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "Phone",
      isLabeled: true,
      showBackground: false,
      value: _phone,
      onChanged: (value) {
        _phone = value;
      },
      validator: (value) => null,
    );
  }

  Widget _nicknameField(BuildContext context, DataModel dmodel) {
    return cv.TextField2(
      labelText: "Nickname",
      isLabeled: true,
      showBackground: false,
      value: _nickname,
      onChanged: (value) {
        _nickname = value;
      },
      validator: (value) => null,
    );
  }

  Widget _button(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.RoundedLabel(
        _buttonText(),
        color: _buttonText() == "Confirm"
            ? dmodel.color
            : Colors.red.withOpacity(0.5),
        textColor: Colors.white,
        isLoading: _isLoading,
        onTap: () => _action(context, dmodel),
      ),
    );
  }

  String _buttonText() {
    if (_firstName.isEmpty) {
      return "First name is Blank";
    } else {
      return "Confirm";
    }
  }

  Future<void> _action(BuildContext context, DataModel dmodel) async {
    if (!_isLoading) {
      if (_buttonText() == "Confirm") {
        setState(() {
          _isLoading = true;
        });
        // update the user
        Map<String, String> _body = {
          "firstName": _firstName,
          "lastName": _lastName,
          "phone": _phone,
          "nickname": _nickname,
        };
        await dmodel.updateUser(widget.email, _body, () async {
          // just reset app to keep data integrity
          RestartWidget.restartApp(context);
        });
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
