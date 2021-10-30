import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import 'package:provider/provider.dart';
import '../../client/root.dart';

class UserCell extends StatelessWidget {
  const UserCell({
    Key? key,
    required this.user,
    this.isClickable,
  }) : super(key: key);
  final SeasonUser user;
  final bool? isClickable;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Row(
      children: [
        UserAvatar(user: user),
        const SizedBox(width: 16),
        Expanded(
          child: Row(
            children: [
              if (dmodel.user!.email == user.email)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: cv.Circle(
                    7,
                    CustomColors.textColor(context),
                  ),
                ),
              Expanded(
                child: Text(
                  user.name(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: CustomColors.textColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
        // const Spacer(),
        if (isClickable ?? false)
          Icon(Icons.chevron_right,
              color: CustomColors.textColor(context).withOpacity(0.5)),
      ],
    );
  }
}

class UserCellLoading extends StatefulWidget {
  const UserCellLoading({
    Key? key,
    this.hasTrailing = false,
  }) : super(key: key);
  final bool hasTrailing;

  @override
  State<UserCellLoading> createState() => _UserCellLoadingState();
}

class _UserCellLoadingState extends State<UserCellLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 0.3, end: 1.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: _animation.value,
        child: Row(
          children: [
            _avatar(context),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                height: 10,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
              ),
            ),
            if (widget.hasTrailing)
              Container(
                height: 20,
                width: 100,
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.3),
              ),
          ],
        ),
      ),
    );
  }

  Widget _avatar(BuildContext context) {
    return cv.Circle(
      60,
      Theme.of(context).brightness == Brightness.light
          ? Colors.black.withOpacity(0.3)
          : Colors.white.withOpacity(0.3),
    );
  }
}

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    Key? key,
    required this.user,
    this.diameter = 60,
    this.fontSize = 30,
  }) : super(key: key);

  final SeasonUser user;
  final double diameter;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        cv.Circle(diameter, CustomColors.random(user.email)),
        Text(
          user.name()[0].toUpperCase(),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
