import 'dart:io';

import 'package:crosscheck_sports/style/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A platform-adaptive confirmation dialog.
///
/// On iOS, uses [CupertinoAlertDialog] for native styling.
/// On Android and other platforms, uses a Material [AlertDialog].
///
/// Returns `true` if the user confirmed, `false` if cancelled.
class AdaptiveConfirmDialog {
  /// Shows a confirmation dialog and returns whether the user confirmed.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) async {
    final resolvedConfirm = confirmLabel ?? 'Confirm';
    final resolvedCancel = cancelLabel ?? 'Cancel';

    if (Platform.isIOS) {
      return await _showIos(
        context,
        title: title,
        message: message,
        confirmLabel: resolvedConfirm,
        cancelLabel: resolvedCancel,
        isDestructive: isDestructive,
      );
    }

    return await _showMaterial(
      context,
      title: title,
      message: message,
      confirmLabel: resolvedConfirm,
      cancelLabel: resolvedCancel,
      isDestructive: isDestructive,
    );
  }

  static Future<bool> _showIos(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required bool isDestructive,
  }) async {
    final result = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: isDestructive,
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  static Future<bool> _showMaterial(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String cancelLabel,
    required bool isDestructive,
  }) async {
    final theme = XCTheme.of(context);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.cell,
        title: Text(title, style: theme.text.label),
        content: Text(message, style: theme.text.body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelLabel,
              style: theme.text.small.copyWith(color: theme.foregroundMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmLabel,
              style: theme.text.small.copyWith(
                color: isDestructive ? theme.error : theme.primary,
              ),
            ),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
