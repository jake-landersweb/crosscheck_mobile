import 'package:flutter/material.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;

class RosterLoading extends StatefulWidget {
  const RosterLoading({Key? key}) : super(key: key);

  @override
  _RosterLoadingState createState() => _RosterLoadingState();
}

class _RosterLoadingState extends State<RosterLoading>
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
    return cv.LoadingWrapper(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: cv.NativeList(
          padding: EdgeInsets.zero,
          itemPadding: EdgeInsets.zero,
          children: [
            for (int i = 0; i < 25; i++)
              Container(
                color: CustomColors.cellColor(context),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: RosterLoadingCell(size: 50),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class RosterLoadingCell extends StatelessWidget {
  const RosterLoadingCell({
    Key? key,
    required this.size,
  }) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            cv.Circle(size, CustomColors.textColor(context).withOpacity(0.2)),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: CustomColors.textColor(context).withOpacity(0.2),
                height: 10,
              ),
              const SizedBox(height: 3),
              Container(
                color: CustomColors.textColor(context).withOpacity(0.2),
                height: 10,
                width: MediaQuery.of(context).size.width / 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
