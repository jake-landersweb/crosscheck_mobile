import 'package:flutter/material.dart';

import 'root.dart';

class MenuItem {
  final String title;
  final IconData icon;
  final Pages page;

  const MenuItem({
    required this.title,
    required this.icon,
    required this.page,
  });
}
