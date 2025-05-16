import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Navigate extends Navigator {
  Navigate(BuildContext context, Widget body, {super.key}) {
    Navigator.push(
      context,
      MaterialWithModalsPageRoute(
        builder: (context) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: body,
          );
        },
      ),
    );
  }
}
