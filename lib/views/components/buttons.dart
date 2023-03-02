import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import '../../custom_views/root.dart' as cv;

class _ButtonBase extends StatelessWidget {
  const _ButtonBase({
    Key? key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.textColor,
    this.isLoading,
    this.horizPadding = 0,
  }) : super(key: key);
  final String title;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color textColor;
  final bool? isLoading;
  final double horizPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizPadding),
      child: cv.BasicButton(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10),
          ),
          height: 50,
          width: double.infinity,
          child: Center(
            child: isLoading ?? false
                ? cv.LoadingIndicator(color: textColor)
                : Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  const ActionButton({
    super.key,
    required this.title,
    required this.color,
    required this.onTap,
    this.isLoading,
    this.horizPadding = 0,
  });
  final String title;
  final Color color;
  final VoidCallback onTap;
  final bool? isLoading;
  final double horizPadding;

  @override
  Widget build(BuildContext context) {
    return _ButtonBase(
      title: title,
      onTap: onTap,
      backgroundColor: color.withOpacity(0.3),
      textColor: color,
      isLoading: isLoading,
      horizPadding: horizPadding,
    );
  }
}

class SubActionButton extends StatelessWidget {
  const SubActionButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading,
    this.backgroundColor,
    this.horizPadding = 0,
  });
  final String title;
  final VoidCallback onTap;
  final bool? isLoading;
  final Color? backgroundColor;
  final double horizPadding;

  @override
  Widget build(BuildContext context) {
    return _ButtonBase(
      title: title,
      onTap: onTap,
      isLoading: isLoading,
      backgroundColor: backgroundColor ?? CustomColors.cellColor(context),
      textColor: CustomColors.textColor(context),
      horizPadding: horizPadding,
    );
  }
}

class DestructionButton extends StatelessWidget {
  const DestructionButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading,
    this.horizPadding = 0,
  });
  final String title;
  final VoidCallback onTap;
  final bool? isLoading;
  final double horizPadding;

  @override
  Widget build(BuildContext context) {
    return _ButtonBase(
      title: title,
      onTap: onTap,
      backgroundColor: Colors.red.withOpacity(0.3),
      textColor: Colors.white,
      isLoading: isLoading,
      horizPadding: horizPadding,
    );
  }
}
