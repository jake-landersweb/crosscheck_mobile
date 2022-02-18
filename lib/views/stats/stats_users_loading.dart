import 'package:pnflutter/data/root.dart';
import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../custom_views/root.dart' as cv;

class StatsUsersLoading extends StatefulWidget {
  const StatsUsersLoading({Key? key}) : super(key: key);

  @override
  _StatsUsersLoadingState createState() => _StatsUsersLoadingState();
}

class _StatsUsersLoadingState extends State<StatsUsersLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
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
    return Opacity(
      opacity: _animation.value,
      child: Column(
        children: [
          // header for all stats
          _header(context),
          const SizedBox(height: 8),
          // actual stat list
          for (int i = 0; i < 20; i++)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CustomColors.cellColor(context),
                  ),
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // avatar
                            cv.Circle(
                                50,
                                CustomColors.textColor(context)
                                    .withOpacity(0.2)),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    color: CustomColors.textColor(context)
                                        .withOpacity(0.2),
                                    height: 10,
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                      color: CustomColors.textColor(context)
                                          .withOpacity(0.2),
                                      height: 10,
                                      width: MediaQuery.of(context).size.width /
                                          3),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Transform.rotate(
                                angle: math.pi * 1.5,
                                child: Icon(Icons.chevron_left,
                                    color: CustomColors.textColor(context)
                                        .withOpacity(0.2)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            )
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3,
      crossAxisCount: 2,
      children: [
        for (var i = 0; i < 4; i++)
          Container(
            decoration: BoxDecoration(
              color: CustomColors.cellColor(context),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
      ],
    );
  }
}
