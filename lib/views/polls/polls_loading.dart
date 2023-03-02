import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:crosscheck_sports/views/polls/root.dart';
import 'package:flutter/material.dart';
import '../../extras/root.dart';
import '../../data/root.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;

class PollsLoading extends StatelessWidget {
  const PollsLoading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return cv.LoadingWrapper(
      child: Column(
        children: [
          for (var i = 0; i < 10; i++)
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: CustomColors.cellColor(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  width: double.infinity,
                  height: 150,
                ),
                const SizedBox(height: 16),
              ],
            ),
        ],
      ),
    );
  }
}
