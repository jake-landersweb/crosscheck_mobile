import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';

class RUCEUser extends StatefulWidget {
  const RUCEUser({Key? key}) : super(key: key);

  @override
  _RUCEUserState createState() => _RUCEUserState();
}

class _RUCEUserState extends State<RUCEUser> {
  @override
  Widget build(BuildContext context) {
    RUCEModel rmodel = Provider.of<RUCEModel>(context);
    return Column(
      children: [
        // email
        _email(context, rmodel),
        const SizedBox(height: 16),
        // first and last name
        cv.Section(
          "User Fields",
          child: cv.NativeList(
            itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            children: [
              _firstName(context, rmodel),
              _lastName(context, rmodel),
              _phone(context, rmodel),
              _nickname(context, rmodel),
            ],
          ),
        ),
      ],
    );
  }

  Widget _email(BuildContext context, RUCEModel rmodel) {
    if (rmodel.isCreate) {
      return cv.NativeList(
        itemPadding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          cv.TextField2(
            labelText: "Email",
            isLabeled: true,
            showBackground: false,
            onChanged: (value) {
              rmodel.email = value;
            },
            validator: (value) => null,
          ),
        ],
      );
    } else {
      return Opacity(
        opacity: 0.7,
        child: cv.RoundedLabel(
          rmodel.email,
          color: CustomColors.cellColor(context),
        ),
      );
    }
  }

  Widget _firstName(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "First Name",
      isLabeled: true,
      showBackground: false,
      value: rmodel.userFields.firstName,
      onChanged: (value) {
        rmodel.userFields.firstName = value;
      },
      validator: (value) => null,
    );
  }

  Widget _lastName(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "Last Name",
      isLabeled: true,
      showBackground: false,
      value: rmodel.userFields.lastName,
      onChanged: (value) {
        rmodel.userFields.lastName = value;
      },
      validator: (value) => null,
    );
  }

  Widget _phone(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "Phone",
      isLabeled: true,
      showBackground: false,
      value: rmodel.userFields.phone,
      onChanged: (value) {
        rmodel.userFields.phone = value;
      },
      validator: (value) => null,
    );
  }

  Widget _nickname(BuildContext context, RUCEModel rmodel) {
    return cv.TextField2(
      labelText: "Nickname",
      isLabeled: true,
      showBackground: false,
      value: rmodel.userFields.nickname,
      onChanged: (value) {
        rmodel.userFields.nickname = value;
      },
      validator: (value) => null,
    );
  }
}
