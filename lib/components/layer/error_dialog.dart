import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Shows a platform-appropriate error dialog.
///
/// On iOS/macOS uses CupertinoAlertDialog, on other platforms uses AlertDialog.
Future<void> showErrorDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? dismissText,
}) {
  final resolvedDismissText = dismissText ?? 'OK';
  if (Platform.isIOS || Platform.isMacOS) {
    return showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(),
            child: Text(resolvedDismissText),
          ),
        ],
      ),
    );
  }

  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(resolvedDismissText),
        ),
      ],
    ),
  );
}

