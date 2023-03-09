import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';
import '../../../custom_views/root.dart' as cv;
import 'root.dart';

class PositionSelect extends StatefulWidget {
  const PositionSelect({
    Key? key,
    required this.positions,
    required this.selection,
    required this.onSelect,
  }) : super(key: key);
  final List<String> positions;
  final String selection;
  final Function(String) onSelect;

  @override
  _PositionSelectState createState() => _PositionSelectState();
}

class _PositionSelectState extends State<PositionSelect> {
  late String _internalTracker;

  @override
  void initState() {
    _internalTracker = widget.selection;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.Sheet(
      title: "Select Position",
      color: dmodel.color,
      icon: Icons.remove,
      child: cv.DynamicSelector<String>(
        selectorStyle: cv.DynamicSelectorStyle.list,
        selections: widget.positions,
        dismissOnTap: true,
        titleBuilder: (context, item) {
          return item.capitalize();
        },
        selectedLogic: (context, item) {
          return item == _internalTracker;
        },
        onSelect: ((context, item) {
          setState(() {
            widget.onSelect(item.toLowerCase());
          });
          _internalTracker = item.toLowerCase();
        }),
        color: dmodel.color,
      ),
      // child: Column(
      //   children: [
      //     const SizedBox(height: 16),
      //     for (var i in widget.positions)
      //       Column(
      //         children: [
      //           _cell(context, dmodel, i),
      //           const SizedBox(height: 8),
      //         ],
      //       ),
      //   ],
      // ),
    );
  }

  Widget _cell(BuildContext context, DataModel dmodel, String val) {
    return cv.RoundedLabel(
      val,
      color: _internalTracker == val ? dmodel.color : Colors.transparent,
      textColor: _internalTracker == val
          ? Colors.white
          : CustomColors.textColor(context),
      onTap: () {
        setState(() {
          widget.onSelect(val);
          _internalTracker = val;
        });
      },
    );
  }
}
