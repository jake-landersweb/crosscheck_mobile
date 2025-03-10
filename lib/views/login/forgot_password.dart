import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:math' as math;

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import '../../extras/root.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  _ForgotPasswordState createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  String _email = "";
  String _code = "";
  String _password = "";
  String _confirmPassword = "";

  bool _isLoading = false;
  bool _sentCode = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      color: dmodel.color,
      title: "Forgot Password",
      child: cv.ListView<Widget>(
        showStyling: false,
        childPadding: EdgeInsets.zero,
        horizontalPadding: 0,
        hasDividers: false,
        children: [
          cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.symmetric(horizontal: 16),
            backgroundColor: CustomColors.sheetCell(context),
            children: [
              cv.TextField2(
                labelText: "Email",
                obscureText: false,
                isLabeled: true,
                showBackground: false,
                highlightColor: dmodel.color,
                icon: const Icon(Icons.email),
                onChanged: (value) {
                  setState(() {
                    _email = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: _sentCode ? 0.5 : 1,
            child: cv.RoundedLabel(
              "Send Reset Code",
              color: dmodel.color,
              textColor: Colors.white,
              isLoading: _isLoading,
              onTap: () {
                if (!_isLoading && !_sentCode) {
                  if (emailIsValid(_email)) {
                    _sendResetCode(context, dmodel);
                  } else {
                    dmodel.addIndicator(
                        IndicatorItem.error("Email is not valid."));
                  }
                }
              },
            ),
          ),
          if (_sentCode)
            for (var i in _codeInput(context, dmodel)) i
        ],
      ),
    );
  }

  List<Widget> _codeInput(BuildContext context, DataModel dmodel) {
    return [
      const SizedBox(height: 16),
      cv.ListView<Widget>(
        horizontalPadding: 0,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: CustomColors.sheetCell(context),
        children: [
          cv.TextField2(
            labelText: "Code",
            obscureText: false,
            showBackground: false,
            highlightColor: dmodel.color,
            icon: const Icon(Icons.code),
            onChanged: (value) {
              setState(() {
                _code = value;
              });
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      cv.ListView<Widget>(
        horizontalPadding: 0,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: CustomColors.sheetCell(context),
        children: [
          cv.TextField2(
            labelText: "New Password",
            obscureText: true,
            showBackground: false,
            highlightColor: dmodel.color,
            icon: const Icon(Icons.lock),
            onChanged: (value) {
              setState(() {
                _password = value;
              });
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      cv.ListView<Widget>(
        horizontalPadding: 0,
        childPadding: const EdgeInsets.symmetric(horizontal: 16),
        backgroundColor: CustomColors.sheetCell(context),
        children: [
          cv.TextField2(
            labelText: "Confirm Password",
            obscureText: true,
            showBackground: false,
            highlightColor: dmodel.color,
            icon: const Icon(Icons.lock),
            onChanged: (value) {
              setState(() {
                _confirmPassword = value;
              });
            },
          ),
        ],
      ),
      const SizedBox(height: 16),
      cv.RoundedLabel(_getPassButtonTitle(),
          color: _getPassButtonTitle() == "Reset Password"
              ? dmodel.color
              : Colors.red,
          isLoading: _isLoading,
          textColor: Colors.white, onTap: () {
        if (!_isLoading) {
          _resetPassword(context, dmodel);
        }
      }),
    ];
  }

  String _getPassButtonTitle() {
    if (_code == "") {
      return "Code cannot be empty";
    } else if (_code.length > 6) {
      return "Code is too long";
    } else if (_code[0] != "P") {
      return "Invalid Code";
    } else if (_password == "") {
      return "Password cannot be empty";
    } else if (_password != _confirmPassword) {
      return "Passwords do not match";
    } else {
      return "Reset Password";
    }
  }

  Future<void> _sendResetCode(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    await dmodel.sendPasswordResetCode(_email.toLowerCase(), () {
      print("successfully sent code");
      setState(() {
        _sentCode = true;
      });
    }, () {
      print("There was an error");
    });
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _resetPassword(BuildContext context, DataModel dmodel) async {
    setState(() {
      _isLoading = true;
    });
    Map<String, dynamic> body = {
      "password": _password,
      "code": _code,
    };
    await dmodel.resetPassword(_email.toLowerCase(), body, () async {
      // google analytics
      await FirebaseAnalytics.instance.logEvent(name: "reset_password");
      Navigator.of(context).pop();
    }, () {});
    setState(() {
      _isLoading = false;
    });
  }
}
