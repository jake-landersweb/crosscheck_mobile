import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Used for convenintly wrapping a child in the correct
/// button type based on the platform
class BasicButton extends StatelessWidget {
  const BasicButton({
    super.key,
    required this.onTap,
    required this.child,
    this.active = true,
  });

  final VoidCallback? onTap;
  final Widget child;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return active
        ? CupertinoButton(
            color: Colors.transparent,
            disabledColor: Colors.transparent,
            padding: const EdgeInsets.all(0),
            onPressed: onTap,
            minimumSize: Size(0, 0),
            child: child,
          )
        : child;
  }
}
