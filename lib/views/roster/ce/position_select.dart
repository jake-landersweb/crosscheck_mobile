import 'package:flutter/material.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/extras/root.dart';
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
      child: Column(
        children: [
          const SizedBox(height: 16),
          for (var i in widget.positions)
            Column(
              children: [
                _cell(context, dmodel, i),
                const SizedBox(height: 8),
              ],
            ),
        ],
      ),
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
