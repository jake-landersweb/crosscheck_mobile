import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';

class Login extends StatefulWidget {
  static const String route = '/login';

  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
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
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment
                    .bottomRight, // 10% of the width, so there are ten blinds.
                colors: [
                  CustomColors.fromHex("00a1ff"),
                  CustomColors.fromHex("00ff8f")
                ], // red to yellow
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Opacity(
                  opacity: 0.7,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Image.asset("assets/launch/x_white_centered.png"),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                cv.NativeList(
                  children: _form(context),
                ),
                cv.Section('',
                    child: cv.BasicButton(
                      onTap: () {
                        dismissKeyboard(context);
                        if (_formIsValid(dmodel)) {
                          _login(dmodel);
                        }
                      },
                      child: cv.NativeList(
                        itemPadding: EdgeInsets.all(0),
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: Center(
                              child: _isLoading
                                  ? cv.LoadingIndicator()
                                  : Text(
                                      "Login",
                                      style: TextStyle(
                                          color: CustomColors.fromHex("00a1ff"),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _form(BuildContext context) {
    return [
      cv.TextField(
        showBackground: false,
        labelText: "Email",
        keyboardType: TextInputType.emailAddress,
        textCapitalization: TextCapitalization.none,
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
        textCapitalization: TextCapitalization.none,
        validator: (value) {},
        onChanged: (value) {
          _password = value;
        },
      ),
    ];
  }

  bool _formIsValid(DataModel dmodel) {
    if (!_email.contains("@") ||
        _email.endsWith(".") ||
        _email.endsWith("@") ||
        !_email.contains(".")) {
      dmodel.setError("Please enter a valid email", true);
      return false;
    } else if (_password == "") {
      dmodel.setError("Password cannot be empty", true);
      return false;
    } else {
      return true;
    }
  }

  void _login(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    // log the user in and set the variable to show the home screen
    await dmodel.login(_email, _password, (user) {
      setState(() {
        dmodel.setUser(user);
      });
      // for when user is able to create an account in the app
      // Navigator.of(context).pop();
    });
    setState(() {
      _isLoading = false;
    });
  }
}
