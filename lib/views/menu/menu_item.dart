import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'root.dart';

// class MenuObject {
//   final String title;
//   final IconData icon;
//   final Pages page;

//   const MenuObject({
//     required this.title,
//     required this.icon,
//     required this.page,
//   });
// }

class MenuObject {
  final String id;
  final int sortOrder;
  final String title;
  final IconData icon;
  final Widget Function(BuildContext context) child;
  final bool Function() showLogic;
  final MenuObjectType type;
  final bool? hasBottomPadding;

  const MenuObject({
    required this.id,
    required this.sortOrder,
    required this.title,
    required this.icon,
    required this.child,
    required this.showLogic,
    required this.type,
    this.hasBottomPadding,
  });
}

enum MenuObjectType { view, spacer, divider }
