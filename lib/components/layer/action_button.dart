// ignore_for_file: must_be_immutable

import 'package:crosscheck_sports/components/adaptive/icon/adaptive_icon.dart';
import 'package:crosscheck_sports/components/adaptive/icon/adaptive_icons.dart';
import 'package:crosscheck_sports/components/core/animated_container.dart';
import 'package:crosscheck_sports/style/root.dart';
import 'package:flutter/material.dart';

enum _InternalType { icon, text, cancel, save, add, edit }

class XCActionButton extends StatelessWidget {
  late void Function()? onTap;
  String? title;
  AdaptiveIcon? icon;
  String? label;
  double? size;
  Color? backgroundColor;
  Color? foregroundColor;
  bool? isLoading;
  bool? isSuccess;
  bool disabled = false;

  late bool _prominent;
  late _InternalType _type;

  XCActionButton.icon({
    super.key,
    required this.onTap,
    required this.icon,
    this.label,
    this.size = XCThemeData.listItemHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading,
    bool? prominent,
  }) {
    _type = _InternalType.icon;
    _prominent = prominent ?? false;
  }

  XCActionButton.text({
    super.key,
    required this.onTap,
    required this.title,
    this.label,
    this.size = XCThemeData.listItemHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.isLoading,
    this.disabled = false,
    bool? prominent,
  }) {
    _type = _InternalType.text;
    _prominent = prominent ?? false;
  }

  /// CUSTOM IMPLEMENTAIONS

  XCActionButton.cancel({
    super.key,
    this.onTap,
    this.size = XCThemeData.listItemHeight,
    this.isLoading,
  }) {
    label = "WNACTION_BUTTON_CANCEL";
    _type = _InternalType.cancel;
    _prominent = false;
    icon = AdaptiveIcons.close;
  }

  XCActionButton.back({
    super.key,
    this.onTap,
    this.size = XCThemeData.listItemHeight,
    this.isLoading,
  }) {
    label = "WNACTION_BUTTON_BACK";
    _type = _InternalType.cancel;
    _prominent = false;
    icon = AdaptiveIcons.chevronLeft;
  }

  XCActionButton.save({
    super.key,
    required this.onTap,
    this.size = XCThemeData.listItemHeight,
    this.isLoading,
    this.isSuccess,
    this.disabled = false,
  }) {
    label = "WNACTION_BUTTON_SAVE";
    _type = _InternalType.save;
    _prominent = true;
  }

  XCActionButton.add({
    super.key,
    required this.onTap,
    this.size = XCThemeData.listItemHeight,
    this.isLoading,
  }) {
    label = "WNACTION_BUTTON_ADD";
    _type = _InternalType.add;
    _prominent = false;
    icon = AdaptiveIcons.add;
  }

  XCActionButton.edit({
    super.key,
    required this.onTap,
    this.size = XCThemeData.listItemHeight,
    this.isLoading,
  }) {
    label = "WNACTION_BUTTON_ADD";
    _type = _InternalType.edit;
    _prominent = false;
  }

  void _onTap(BuildContext context) {
    if (disabled) {
      return;
    }

    switch (_type) {
      case _InternalType.cancel:
        if (onTap != null) {
          onTap!();
        } else {
          Navigator.of(context).pop();
        }
        break;
      default:
        onTap!();
        break;
    }
  }

  String? _resolvedTitle(BuildContext context) {
    if (title != null) return title;
    return switch (_type) {
      _InternalType.save => 'Save',
      _InternalType.edit => 'Edit',
      _ => null,
    };
  }

  Color _bg(BuildContext context) {
    if (disabled) return XCTheme.of(context).border;
    if (backgroundColor != null) return backgroundColor!;
    if (_prominent) return XCTheme.of(context).primary;
    return XCTheme.of(context).cell;
  }

  Color _fg(BuildContext context) {
    if (disabled) return XCTheme.of(context).foregroundMuted;
    if (foregroundColor != null) return foregroundColor!;
    if (_prominent) return Colors.white;
    return XCTheme.of(context).foreground;
  }

  String get _childState {
    if (isSuccess == true) return 'success';
    if (isLoading == true) return 'loading';
    return 'content';
  }

  /// Wraps [child] with a subtle drop shadow matching iOS 26 liquid glass.
  Widget _withShadow(Widget child) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size! / 2),
        boxShadow: const [
          // Soft ambient shadow
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: Offset(0, 1),
          ),
          // Tighter contact shadow
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.04),
            blurRadius: 4,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedTitle(context);
    final isIconButton = resolved == null;

    // Icon buttons are circular
    if (isIconButton) {
      return _withShadow(
        XCAnimatedContainer.custom(
          customRadius: size! / 2,
          interactionScale: 1.2,
          onTap: disabled ? null : () => _onTap(context),
          color: _bg(context),
          child: SizedBox(
            key: ValueKey(_childState),
            height: size,
            width: size,
            child: Center(child: _getChild(context)),
          ),
        ),
      );
    }

    // Prominent text buttons (like save) use pill shape (fully rounded)
    if (_prominent) {
      return _withShadow(
        XCAnimatedContainer.custom(
          customRadius: size! / 2,
          onTap: disabled ? null : () => _onTap(context),
          color: _bg(context),
          child: SizedBox(
            key: ValueKey(_childState),
            height: size,
            width: isSuccess == true ? size : null,
            child: _getChild(context),
          ),
        ),
      );
    }

    // Regular text buttons use small radius
    return _withShadow(
      XCAnimatedContainer.custom(
        customRadius: size! / 2,
        onTap: disabled ? null : () => _onTap(context),
        color: _bg(context),
        child: SizedBox(
          key: ValueKey(_childState),
          height: size,
          width: isSuccess == true ? size : null,
          child: _getChild(context),
        ),
      ),
    );
  }

  Widget _getChild(BuildContext context) {
    final resolved = _resolvedTitle(context);
    final isTextButton = resolved != null;

    if (isSuccess == true) {
      return Center(
        child: Icon(AdaptiveIcons.check.icon, color: _fg(context), size: 20),
      );
    }

    if (isLoading == true) {
      final spinner = SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_fg(context)),
        ),
      );

      if (isTextButton) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(widthFactor: 1.0, child: spinner),
        );
      }

      return Center(child: spinner);
    }

    return isTextButton
        ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              widthFactor: 1.0,
              child: Text(
                resolved,
                style: XCTheme.of(context).text.small.copyWith(
                  color: _fg(context),
                  fontWeight: _prominent ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          )
        : Icon(icon!.icon, color: _fg(context), size: 20);
  }
}
