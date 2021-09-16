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
          cv.AppBar(
            title: "Login",
            isLarge: true,
            // leading: cv.BackButton(
            //   color: Colors.blue,
            // ),
            children: [
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
                    child: const cv.NativeList(
                      itemPadding: EdgeInsets.all(16),
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ))
            ],
          ),
          // for showing that the view is actually doing something
          if (_isLoading) cv.LoadingIndicator()
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
    if (!_email.contains("@") || !_email.contains(".co")) {
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
