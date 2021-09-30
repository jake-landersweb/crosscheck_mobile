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
              Text(
                user.seasonName(),
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: CustomColors.textColor(context)),
              ),
              if (dmodel.user!.email == user.email)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: cv.Circle(7, CustomColors.textColor(context)),
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

class UserCellLoading extends StatelessWidget {
  const UserCellLoading({
    Key? key,
    this.hasTrailing = false,
  }) : super(key: key);
  final bool hasTrailing;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
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
          if (hasTrailing)
            Container(
              height: 20,
              width: 100,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.black.withOpacity(0.3)
                  : Colors.white.withOpacity(0.3),
            ),
        ],
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
          user.seasonName()[0].toUpperCase(),
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
