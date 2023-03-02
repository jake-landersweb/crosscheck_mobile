import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';
import 'package:async/async.dart';

class RUCEUser extends StatefulWidget {
  const RUCEUser({Key? key}) : super(key: key);

  @override
  _RUCEUserState createState() => _RUCEUserState();
}

class _RUCEUserState extends State<RUCEUser> {
  bool _foundUser = false;
  bool _isLoading = false;

  RestartableTimer? _timer;

  @override
  Widget build(BuildContext context) {
    RUCEModel rmodel = Provider.of<RUCEModel>(context);
    return Column(
      children: [
        // email
        _email(context, rmodel),
        // const SizedBox(height: 16),
        // first and last name
        cv.Section(
          _foundUser ? "Information Found" : "Personal Information",
          child: cv.ListView<Widget>(
            horizontalPadding: 0,
            childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            children: [
              AnimatedOpacity(
                opacity: _foundUser ? 0.5 : 1,
                curve: Sprung.overDamped,
                duration: const Duration(milliseconds: 500),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _firstName(context, rmodel),
                    _lastName(context, rmodel),
                    _phone(context, rmodel),
                    _nickname(context, rmodel),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _email(BuildContext context, RUCEModel rmodel) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (rmodel.isCreate) {
      return cv.ListView<Widget>(
        horizontalPadding: 0,
        childPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          Row(
            children: [
              Expanded(
                child: cv.TextField2(
                  labelText: "Email",
                  isLabeled: !_isLoading,
                  showBackground: false,
                  onChanged: (value) {
                    rmodel.email = value;
                    _timer ??= RestartableTimer(
                        const Duration(milliseconds: 500), () async {
                      print("FETCHING");
                      if (emailIsValid(rmodel.email)) {
                        await _getUser(dmodel, rmodel);
                      } else {
                        setState(() {
                          _foundUser = false;
                          rmodel.updateState();
                        });
                      }
                    });
                    if (_timer != null) {
                      _timer!.reset();
                    }
                  },
                ),
              ),
              if (_isLoading)
                SizedBox(
                  height: 30,
                  width: 30,
                  child: cv.LoadingIndicator(color: dmodel.color),
                ),
            ],
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  Widget _firstName(BuildContext context, RUCEModel rmodel) {
    if (_foundUser) {
      return cv.LabeledWidget(
        "First Name",
        height: 50,
        child: Text(
          rmodel.userFields.firstName ?? "",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return cv.TextField2(
        labelText: "First Name",
        isLabeled: true,
        showBackground: false,
        value: rmodel.userFields.firstName,
        onChanged: (value) {
          rmodel.userFields.firstName = value;
        },
      );
    }
  }

  Widget _lastName(BuildContext context, RUCEModel rmodel) {
    if (_foundUser) {
      return cv.LabeledWidget(
        "Last Name",
        height: 50,
        child: Text(
          rmodel.userFields.lastName ?? "",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return cv.TextField2(
        labelText: "Last Name",
        isLabeled: true,
        showBackground: false,
        value: rmodel.userFields.lastName,
        onChanged: (value) {
          rmodel.userFields.lastName = value;
        },
      );
    }
  }

  Widget _phone(BuildContext context, RUCEModel rmodel) {
    if (_foundUser) {
      return cv.LabeledWidget(
        "Phone",
        height: 50,
        child: Text(
          rmodel.userFields.phone ?? "",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return cv.TextField2(
        labelText: "Phone",
        isLabeled: true,
        showBackground: false,
        value: rmodel.userFields.phone,
        onChanged: (value) {
          rmodel.userFields.phone = value;
        },
      );
    }
  }

  Widget _nickname(BuildContext context, RUCEModel rmodel) {
    if (_foundUser) {
      return cv.LabeledWidget(
        "Nickname",
        height: 50,
        child: Text(
          rmodel.userFields.nickname ?? "",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    } else {
      return cv.TextField2(
        labelText: "Nickname",
        isLabeled: true,
        showBackground: false,
        value: rmodel.userFields.nickname,
        onChanged: (value) {
          rmodel.userFields.nickname = value;
        },
      );
    }
  }

  Future<void> _getUser(DataModel dmodel, RUCEModel rmodel) async {
    // only fetch when email is valid
    debugPrint("Finding existing user data for: ${rmodel.email}");
    setState(() {
      _isLoading = true;
    });
    await dmodel.getUser(rmodel.email.toLowerCase(), (p0) {
      debugPrint("Successfully found user data for: ${rmodel.email}");
      setState(() {
        _foundUser = true;
        rmodel.userFields.firstName = p0.firstName;
        rmodel.userFields.lastName = p0.lastName;
        rmodel.userFields.phone = p0.phone;
        rmodel.userFields.nickname = p0.nickname;
        rmodel.updateState();
      });
    }, onError: () {
      setState(() {
        if (_foundUser) {
          rmodel.userFields.firstName = "";
          rmodel.userFields.lastName = "";
          rmodel.userFields.phone = "";
          rmodel.userFields.nickname = "";
        }
        _foundUser = false;
        rmodel.updateState();
      });
    }, showErrors: false);
    setState(() {
      _isLoading = false;
    });
  }
}
