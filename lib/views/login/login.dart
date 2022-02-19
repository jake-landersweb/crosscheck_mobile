import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';

class Login extends StatefulWidget {
  static const String route = '/login';

  const Login({
    Key? key,
    required this.isCreate,
  }) : super(key: key);
  final bool isCreate;

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _email = "";
  String _password = "";
  String _firstName = "";
  String _lastName = "";

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: CustomColors.backgroundColor(context),
      body: Column(
        children: [
          // top content
          Container(
            // gradient background for the form
            decoration: BoxDecoration(
              color: dmodel.color.withOpacity(0.5),
            ),
            width: double.infinity,
            // actual form
            child: SafeArea(
              top: true,
              left: false,
              right: false,
              bottom: false,
              child: Column(
                children: [
                  // title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: _title(context)),
                  ),
                  // form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _form(context, dmodel),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: _button(context, dmodel),
                  ),
                ],
              ),
            ),
          ),
          // wave
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            width: double.infinity,
            child: SvgPicture.asset(
              "assets/svg/wave1.svg",
              semanticsLabel: 'wave',
              color: dmodel.color.withOpacity(0.5),
              width: double.infinity,
              fit: BoxFit.fill,
            ),
          ),
          const Spacer(),
          _footer(context),
        ],
      ),
    );
  }

  Widget _title(BuildContext context) {
    return Text(
      widget.isCreate ? "Create Account" : "Login",
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }

  Widget _form(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        Column(
          children: [
            if (widget.isCreate)
              Column(
                children: [
                  _formItem(context, dmodel, "First Name", Icons.person,
                      (value) {
                    setState(() {
                      _firstName = value;
                    });
                  }),
                  const SizedBox(height: 16),
                  _formItem(context, dmodel, "Last Name", Icons.person,
                      (value) {
                    setState(() {
                      _lastName = value;
                    });
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            _formItem(context, dmodel, "Email", Icons.mail, (value) {
              setState(() {
                _email = value;
              });
            }),
            const SizedBox(height: 16),
            _formItem(context, dmodel, "Password", Icons.lock, (value) {
              setState(() {
                _password = value;
              });
            }, obscure: true),
          ],
        ),
      ],
    );
  }

  Widget _formItem(BuildContext context, DataModel dmodel, String title,
      IconData icon, Function(String) onChanged,
      {bool obscure = false}) {
    return Material(
      color: Colors.transparent,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: cv.RoundedLabel(
        "",
        color: CustomColors.cellColor(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: cv.TextField(
            labelText: title,
            obscureText: obscure,
            showBackground: false,
            highlightColor: dmodel.color,
            icon: Icon(icon),
            onChanged: (value) => onChanged(value),
            validator: (value) {},
          ),
        ),
      ),
    );
  }

  Widget _button(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: cv.RoundedLabel(
            widget.isCreate ? "Create Account" : "Login",
            isLoading: _isLoading,
            color: dmodel.color,
            textColor: Colors.white,
            fontWeight: FontWeight.w600,
            onTap: () {
              if (_formIsValid(dmodel)) {
                _action(dmodel);
              }
            },
          ),
        ),
        const SizedBox(height: 32),
        if (!widget.isCreate)
          Center(
            child: cv.BasicButton(
              onTap: () {
                // TODO -- forgot password
                print("TODO -- forgot password");
              },
              child: Text(
                "Forgot your password?",
                style: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _footer(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          top: false,
          right: false,
          left: false,
          bottom: true,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
            child: Column(
              children: [
                Center(
                  child: cv.BasicButton(
                    onTap: () {
                      if (widget.isCreate) {
                        cv.Navigate(
                          context,
                          const Login(
                            isCreate: false,
                          ),
                        );
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      widget.isCreate
                          ? "Have an account? Login"
                          : "Create Account",
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.textColor(context).withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/launch/x.png", height: 25, width: 25),
                    const SizedBox(width: 4),
                    Text(
                      "Crosscheck",
                      style: TextStyle(
                        fontSize: 14,
                        color: CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        "|",
                        style: TextStyle(
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                    ),
                    Text(
                      "Powered by Landersweb",
                      style: TextStyle(
                        fontSize: 12,
                        color: CustomColors.textColor(context).withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _formIsValid(DataModel dmodel) {
    if (!emailIsValid(_email)) {
      dmodel.setError("Please enter a valid email", true);
      return false;
    } else if (_password == "") {
      dmodel.setError("Password cannot be empty", true);
      return false;
    } else {
      if (widget.isCreate) {
        if (_firstName.isEmpty) {
          dmodel.setError("First name cannot be empty", true);
          return false;
        } else {
          return true;
        }
      } else {
        return true;
      }
    }
  }

  void _action(DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    // log the user in and set the variable to show the home screen
    if (widget.isCreate) {
      Map<String, dynamic> body = {
        "firstName": _firstName.toLowerCase(),
        "lastName": _lastName,
        "email": _email.toLowerCase(),
        "password": _password,
      };
      await dmodel.createUser(body, (user) {
        dmodel.setUser(user);
      });
    } else {
      await dmodel.login(_email.toLowerCase(), _password, (user) {
        Navigator.of(context).pop();
        setState(() {
          dmodel.setUser(user);
        });
      });
    }
    setState(() {
      _isLoading = false;
    });
  }
}
