import 'package:flutter/material.dart';

class MenuModel extends ChangeNotifier {
  double offset = 0;
  double cachedOffset = 0;
  double dragStart = 0;
  bool isPan = false;
  bool isOpen = false;

  bool animate = false;

  Pages selectedPage = Pages.schedule;

  final double sizeThreashold = 1.5;

  void open(Size size) {
    offset = -size.width / sizeThreashold;
    cachedOffset = -size.width / sizeThreashold;
    isOpen = true;
    // update state
    notifyListeners();
  }

  void close() {
    offset = 0;
    cachedOffset = 0;
    isOpen = false;
    // update state
    notifyListeners();
  }

  void resetMenu() {
    // close();
    selectedPage = Pages.schedule;
    notifyListeners();
    print(selectedPage);
  }
}

enum Pages {
  team,
  schedule,
  calendar,
  seasonRoster,
  seasonSettings,
  settings,
  teamAdmin,
  seasonAdmin,
  chat,
}
