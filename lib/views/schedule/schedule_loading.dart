import 'package:crosscheck_sports/client/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../extras/root.dart';
import 'dart:math' as math;
import '../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;

class ScheduleLoading extends StatefulWidget {
  const ScheduleLoading({
    Key? key,
    this.includeHeader = true,
  }) : super(key: key);
  final bool includeHeader;

  @override
  _ScheduleLoadingState createState() => _ScheduleLoadingState();
}

class _ScheduleLoadingState extends State<ScheduleLoading> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.LoadingWrapper(
      child: Column(
        children: [
          // if (widget.includeHeader)
          //   Column(
          //     children: [
          //       // _header(context),
          //       const SizedBox(height: 16),
          //       cv.SegmentedPicker(
          //         titles: const ["Upcoming", "Previous"],
          //         style: comp.segmentedPickerStyle(context, dmodel),
          //         onSelection: (selection) {},
          //         selection: "Upcoming",
          //       ),
          //     ],
          //   ),
          // const SizedBox(height: 16),
          _month(context),
          const SizedBox(height: 16),
          for (var i = 0; i < 5; i++)
            Column(
              children: [_cell(context), const SizedBox(height: 16)],
            ),
        ],
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        // season title
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              " ",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: CustomColors.textColor(context),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: _cellColor(context),
                borderRadius: BorderRadius.circular(5),
              ),
              height: 20,
              width: MediaQuery.of(context).size.width / 2.5,
            ),
          ],
        ),
        const SizedBox(width: 4),
        // icon to show this is clickable
        Transform.rotate(
          angle: math.pi * 1.5,
          child: Icon(Icons.chevron_left,
              color: CustomColors.textColor(context).withOpacity(0.7)),
        ),
      ],
    );
  }

  Widget _month(BuildContext context) {
    return Row(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              "",
              style: TextStyle(
                  color: CustomColors.textColor(context).withOpacity(0.5),
                  fontSize: 25,
                  fontWeight: FontWeight.w700),
            ),
            Container(
              decoration: BoxDecoration(
                color: _cellColor(context),
                borderRadius: BorderRadius.circular(5),
              ),
              height: 18,
              width: MediaQuery.of(context).size.width / 3,
            ),
          ],
        ),
      ],
    );
  }

  Widget _cell(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 15,
          child: Align(
            alignment: Alignment.topLeft,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      "",
                      style: TextStyle(
                        color: CustomColors.textColor(context).withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: _cellColor(context),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 8,
                      width: 14,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Stack(
                  alignment: AlignmentDirectional.center,
                  children: [
                    cv.Circle(35, Colors.transparent),
                    cv.Circle(30, _cellColor(context)),
                  ],
                )
              ],
            ),
          ),
        ),
        Expanded(
          flex: 85,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: CustomColors.cellColor(context),
            ),
            height: 120,
            width: double.infinity,
          ),
        ),
      ],
    );
  }

  Color _cellColor(BuildContext context) {
    return CustomColors.textColor(context).withOpacity(0.2);
  }
}
