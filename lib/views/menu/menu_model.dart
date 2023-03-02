import 'package:flutter/material.dart';

class MenuModel extends ChangeNotifier {
  double offset = 0;
  double cachedOffset = 0;
  double dragStart = 0;
  bool isPan = false;
  bool isOpen = false;

  bool animate = false;

  String initPage = "dashboard";
  late String selectedPage;

  MenuModel() {
    selectedPage = initPage;
  }

  void setPage(String page) {
    selectedPage = page;
    notifyListeners();
  }

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
    selectedPage = initPage;
    notifyListeners();
    print(selectedPage);
  }
}
