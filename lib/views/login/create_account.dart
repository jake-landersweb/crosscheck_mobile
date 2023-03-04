import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    super.key,
    required this.isCreate,
  });
  final bool isCreate;

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String _name = "";
  String _email = "";
  String _password = "";
  bool _showValidity = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Container(
      color: CustomColors.backgroundColor(context),
      child: Theme(
        data: Theme.of(context).copyWith(
          colorScheme:
              Theme.of(context).colorScheme.copyWith(primary: dmodel.color),
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            _contentWrapper(context, dmodel),
            if (widget.isCreate)
              cv.GlassContainer(
                height:
                    widget.isCreate ? MediaQuery.of(context).padding.top : 0,
                width: double.infinity,
                backgroundColor: CustomColors.backgroundColor(context),
                opacity: 0.7,
                blur: 10,
              ),
            if (_showValidity)
              SafeArea(
                top: widget.isCreate,
                left: false,
                right: false,
                bottom: false,
                child: Text(
                  _validText(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    color: _validText() == "Your information looks great!"
                        ? CustomColors.textColor(context).withOpacity(0.5)
                        : Colors.red.withOpacity(0.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _contentWrapper(BuildContext context, DataModel dmodel) {
    if (widget.isCreate) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _content(context, dmodel),
          )
        ],
      );
    } else {
      return cv.AppBar.sheet(
        title: "",
        leading: const [
          cv.BackButton(
            useRoot: true,
            title: "Close",
            showIcon: false,
            showText: true,
          )
        ],
        children: [_content(context, dmodel)],
      );
    }
  }

  Widget _content(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        if (widget.isCreate)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset("assets/launch/x.png", height: 50),
              const Text(
                "Crosscheck",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              )
            ],
          ),
        const SizedBox(height: 16),
        if (widget.isCreate)
          _formItem(Icons.person_rounded, "Name", (val) {
            setState(() {
              _showValidity = true;
              _name = val;
            });
          }),
        _formItem(Icons.mail_rounded, "Email", (val) {
          setState(() {
            _showValidity = true;
            _email = val;
          });
        }),
        _formItem(Icons.lock_rounded, "Password", (val) {
          setState(() {
            _showValidity = true;
            _password = val;
          });
        }, obscure: true),
        _actionButton(context, dmodel),
        if (!widget.isCreate)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Center(
              child: cv.BasicButton(
                onTap: () {
                  cv.showFloatingSheet(
                    context: context,
                    isDismissable: false,
                    builder: (context) {
                      return const ForgotPassword();
                    },
                  );
                },
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: CustomColors.textColor(context).withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        // SvgPicture.asset(
        //   widget.isCreate
        //       ? "assets/svg/soccer-goal.svg"
        //       : "assets/svg/login.svg",
        //   // fit: BoxFit.contain,
        //   height: MediaQuery.of(context).size.height * 0.4,
        // ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
        ),
        if (widget.isCreate)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Center(
              child: cv.BasicButton(
                onTap: () {
                  cv.cupertinoSheet(
                    context: context,
                    builder: (context) {
                      return const CreateAccount(isCreate: false);
                    },
                  );
                },
                child: Text(
                  "Have an account? Login",
                  style: TextStyle(
                    fontSize: 14,
                    color: CustomColors.textColor(context).withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/sapphire.svg",
              height: 25,
              width: 25,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                "|",
                style: TextStyle(
                  color: CustomColors.textColor(context).withOpacity(0.5),
                ),
              ),
            ),
            Text(
              "Powered by Sapphire",
              style: TextStyle(
                fontSize: 12,
                color: CustomColors.textColor(context).withOpacity(0.5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _formItem(
      IconData icon, String label, void Function(String val) onChanged,
      {bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: cv.TextField2(
        labelText: label,
        icon: Icon(icon),
        textCapitalization:
            obscure ? TextCapitalization.none : TextCapitalization.words,
        onChanged: onChanged,
        obscureText: obscure,
      ),
    );
  }

  Widget _actionButton(BuildContext context, DataModel dmodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: comp.ActionButton(
        color: dmodel.color,
        title: widget.isCreate ? "Create Account" : "Login",
        isLoading: _isLoading,
        onTap: () => _action(dmodel),
      ),
    );
  }

  String _validText() {
    if (_name.isEmpty && widget.isCreate) {
      return "Your name cannot be empty.";
    } else if (_email.isEmpty) {
      return "Your email cannot be empty.";
    } else if (!emailIsValid(_email)) {
      return "Please enter a valid email.";
    } else if (_password.isEmpty) {
      return "Your password cannot be empty.";
    } else if (_password.length < 5 && widget.isCreate) {
      return "Your password must be at least 5 characters.";
    } else {
      return "Your information looks great!";
    }
  }

  void _action(DataModel dmodel) async {
    if (_validText() == "Your information looks great!") {
      setState(() {
        _isLoading = true;
      });
      if (widget.isCreate) {
        List<String> names = _name.split(" ");
        late String fname;
        late String lname;
        if (names.length == 2) {
          fname = names[0];
          lname = names[1];
        } else {
          fname = names[0];
          lname = "";
        }
        // Create the account
        Map<String, dynamic> body = {
          "firstName": fname,
          "lastName": lname,
          "email": _email.toLowerCase(),
          "password": _password,
        };
        await dmodel.createUser(body, (user) async {
          // google analytics
          await FirebaseAnalytics.instance
              .logSignUp(signUpMethod: "mobile_create_account");
          dmodel.setUser(user);
        });
      } else {
        await dmodel.login(_email.toLowerCase(), _password, (user) async {
          // google analytics
          await FirebaseAnalytics.instance
              .logLogin(loginMethod: "mobile_login");
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            dmodel.isScaled = false;
            dmodel.setUser(user);
          });
        });
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      dmodel.addIndicator(IndicatorItem.error(_validText()));
    }
  }
}
