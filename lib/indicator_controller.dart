import 'package:crosscheck_sports/client/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'custom_views/root.dart' as cv;

class IndicatorController extends StatefulWidget {
  const IndicatorController({Key? key}) : super(key: key);

  @override
  State<IndicatorController> createState() => _IndicatorControllerState();
}

class _IndicatorControllerState extends State<IndicatorController> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.indicators.isNotEmpty) {
      while (true) {
        dmodel.currentIndicator = dmodel.indicators.first.clone();
        return StatusBar(
          key: ValueKey(dmodel.currentIndicator!.id),
          backgroundColor: dmodel.currentIndicator!.getColor(context),
          opacity: dmodel.currentIndicator!.getOpacity(),
          duration: dmodel.currentIndicator!.duration,
          animationTime: dmodel.animationTime * 1000,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dmodel.currentIndicator!.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: dmodel.currentIndicator!.getTextColor(context),
                    ),
                  ),
                ),
                Icon(
                  dmodel.currentIndicator!.getIcon(),
                  color: dmodel.currentIndicator!.getTextColor(context),
                )
              ],
            ),
          ),
          completion: () {
            dmodel.indicators.removeAt(0);
            dmodel.currentIndicator = null;
          },
        );
      }
    } else {
      return Container();
    }
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({
    Key? key,
    required this.backgroundColor,
    required this.opacity,
    required this.child,
    required this.completion,
    required this.duration,
    required this.animationTime,
  }) : super(key: key);

  final Color backgroundColor;
  final double opacity;
  final Widget child;
  final VoidCallback completion;
  final double duration;
  final double animationTime;

  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> position;

  @override
  void initState() {
    print("INIT");
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    position = Tween<Offset>(begin: const Offset(0.0, 200), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Sprung.overDamped));

    controller.forward();

    _close();
  }

  @override
  void dispose() {
    print("DISPOSE!");
    controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        controller.reverse();
      });
    } else {
      print("NOT MOUNTED");
    }
    await Future.delayed(const Duration(milliseconds: 800));
    widget.completion();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
        child: SlideTransition(
          position: position,
          child: cv.GlassContainer(
            borderRadius: BorderRadius.circular(25),
            opacity: widget.opacity,
            backgroundColor: widget.backgroundColor,
            height: 50,
            width: MediaQuery.of(context).size.width - 10,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
