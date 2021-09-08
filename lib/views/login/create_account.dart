import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import 'root.dart';
import '../../extras/root.dart';

class CreateUser extends StatefulWidget {
  static const String route = '/createAccount';

  const CreateUser({Key? key}) : super(key: key);

  @override
  _CreateUserState createState() => _CreateUserState();
}

class _CreateUserState extends State<CreateUser> {
  String _firstName = "";
  String _lastName = "";
  String _email = "";
  String _password = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      body: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          cv.AppBar(
            title: "Create Account",
            isLarge: true,
            actions: [
              _loginButton(context),
            ],
            children: [
              cv.NativeList(
                children: _form(context),
              ),
              cv.Section(
                '',
                child: cv.BasicButton(
                  onTap: () {
                    dismissKeyboard(context);
                    if (_formIsValid(dmodel)) {
                      _createAccount(dmodel);
                    }
                  },
                  child: const cv.NativeList(
                    itemPadding: EdgeInsets.all(16),
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: Text("Create Account",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_isLoading) cv.LoadingIndicator()
        ],
      ),
    );
  }

  List<Widget> _form(BuildContext context) {
    return [
      cv.TextField(
        showBackground: false,
        labelText: "Firstname",
        keyboardType: TextInputType.name,
        validator: (value) {},
        onChanged: (value) {
          _firstName = value;
        },
      ),
      cv.TextField(
        showBackground: false,
        labelText: "Lastname",
        keyboardType: TextInputType.name,
        validator: (value) {},
        onChanged: (value) {
          _lastName = value;
        },
      ),
      cv.TextField(
        showBackground: false,
        labelText: "Email",
        keyboardType: TextInputType.emailAddress,
        validator: (value) {},
        onChanged: (value) {
          _email = value;
        },
      ),
      cv.TextField(
        showBackground: false,
        obscureText: true,
        labelText: "Password",
        keyboardType: TextInputType.visiblePassword,
        validator: (value) {},
        onChanged: (value) {
          _password = value;
        },
      ),
    ];
  }

  bool _formIsValid(DataModel dmodel) {
    if (_firstName == "") {
      dmodel.setError("Firstname cannot be blank", true);
      return false;
    } else if (_lastName == "") {
      dmodel.setError("Lastname cannot be blank", true);
      return false;
    } else if (!_email.contains("@") || !_email.contains(".co")) {
      dmodel.setError("Please enter a valid email", true);
      return false;
    } else if (_password == "") {
      dmodel.setError("Password cannot be empty", true);
      return false;
    } else {
      return true;
    }
  }

  void _createAccount(DataModel dmodel) async {
    // TODO - add create user call
  }

  Widget _loginButton(BuildContext context) {
    return cv.BasicButton(
      onTap: () {
        cv.Navigate(context, const Login());
      },
      child: const Text("Login",
          style: TextStyle(
            color: Colors.blue,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          )),
    );
  }
}
