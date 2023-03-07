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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: _getTz().length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, i) {
              return cv.BasicButton(
                onTap: () {
                  widget.onSelect(_getTz()[i]);
                  Navigator.of(context).pop();
                },
                child: Column(
                  children: [
                    Container(
                      constraints: const BoxConstraints(minHeight: 50),
                      color: CustomColors.cellColor(context),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _getTz()[i],
                                  style: TextStyle(
                                    color: CustomColors.textColor(context),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              if (_tz == _getTz()[i])
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  color: dmodel.color,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (i < _getTz().length - 1)
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 0.5,
                            color: CustomColors.cellColor(context),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Container(
                              width: double.infinity,
                              height: 0.5,
                              color: CustomColors.textColor(context)
                                  .withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        )
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
