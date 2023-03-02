import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'root.dart' as cv;

class TimezoneSelector extends StatefulWidget {
  const TimezoneSelector({
    super.key,
    this.initTimezone = "US/Pacific",
    required this.onSelect,
  });
  final String initTimezone;
  final Function(String) onSelect;

  @override
  State<TimezoneSelector> createState() => _TimezoneSelectorState();
}

class _TimezoneSelectorState extends State<TimezoneSelector> {
  late String _tz;
  String _searchText = "";
  late List<String> _timezones;

  @override
  void initState() {
    _timezones = tz.timeZoneDatabase.locations.keys.toList();
    _tz = widget.initTimezone;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
      title: "Select Timezone",
      leading: [cv.CancelButton(color: dmodel.color)],
      children: [
        cv.TextField2(
          value: _searchText,
          labelText: "Search",
          icon: Icon(
            Icons.search,
            color: dmodel.color,
          ),
          highlightColor: dmodel.color,
          onChanged: (p0) {
            setState(() {
              _searchText = p0;
            });
          },
        ),
        const SizedBox(height: 16),
        cv.ListView<String>(
          children: _getTz(),
          horizontalPadding: 0,
          onChildTap: (context, item) {
            widget.onSelect(item);
            Navigator.of(context).pop();
          },
          childBuilder: (context, item) {
            return Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: CustomColors.textColor(context),
                    ),
                  ),
                ),
                if (_tz == item)
                  Icon(
                    Icons.check_circle_outline_rounded,
                    color: dmodel.color,
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  List<String> _getTz() {
    if (_searchText.isEmpty) {
      return _timezones;
    } else {
      return _timezones
          .where((element) =>
              element.toLowerCase().contains(_searchText.toLowerCase()))
          .toList();
    }
  }
}
