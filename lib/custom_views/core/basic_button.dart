import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

///
/// Used for convenintly wrapping a child in the correct
/// button type based on the platform
class BasicButton extends StatelessWidget {
  const BasicButton({
    Key? key,
    required this.onTap,
    required this.child,
  });

  final VoidCallback? onTap;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: Colors.transparent,
      disabledColor: Colors.transparent,
      padding: const EdgeInsets.all(0),
      minSize: 0,
      onPressed: onTap,
      child: child,
    );
  }
}
