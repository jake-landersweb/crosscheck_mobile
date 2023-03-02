import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

import 'root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import '../../client/root.dart';
import '../root.dart';
import '../../data/season/root.dart';

class MenuButton extends StatefulWidget {
  const MenuButton({Key? key}) : super(key: key);

  @override
  _MenuButtonState createState() => _MenuButtonState();
}

class _MenuButtonState extends State<MenuButton> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    var _menu = Provider.of<MenuModel>(context);
    return cv.BasicButton(
      child: Icon(_menu.isOpen ? Icons.close : Icons.menu,
          color: Theme.of(context).colorScheme.primary),
      // actionn of the button
      onTap: () {
        // allow for animation
        _menu.animate = true;
        // toggle menu
        if (_menu.isOpen) {
          _menu.close();
        } else {
          _menu.open(MediaQuery.of(context).size);
        }
      },
    );
  }
}
