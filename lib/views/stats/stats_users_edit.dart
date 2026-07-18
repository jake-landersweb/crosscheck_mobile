import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/components/layer/header_bar.dart';
import 'package:crosscheck_sports/components/layer/action_button.dart';
import 'package:crosscheck_sports/components/layer/field.dart';
import 'package:crosscheck_sports/components/core/cell_list.dart';
import 'package:crosscheck_sports/components/layer/wide_button.dart';

class StatsUsersEdit extends StatefulWidget {
  const StatsUsersEdit({
    super.key,
    required this.team,
    required this.userStats,
    required this.completion,
  });
  final Team team;
  final List<UserStat> userStats;
  final Future<void> Function(List<UserStat>) completion;

  @override
  _StatsUsersEditState createState() => _StatsUsersEditState();
}

class _StatsUsersEditState extends State<StatsUsersEdit> {
  late List<UserStat> newList;
  bool isLoading = false;
  String _filterText = "";

  @override
  void initState() {
    newList = [for (var i in widget.userStats) i.clone()];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        HeaderBar(
          title: "Edit Stats",
          isLarge: true,
          backgroundColor: CustomColors.backgroundColor(context),
          leading: XCActionButton.back(),
          child: _body(context, dmodel),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: _confirm(context, dmodel),
          ),
        ),
      ],
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    return Column(
      children: [
        XCCellList<Widget>(
          horizontalPadding: 0,
          childPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            XCField(
              value: _filterText,
              labelText: "Search ...",
              onChanged: (value) {
                setState(() {
                  _filterText = value;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        for (var i in _filterList())
          Column(
            children: [
              StatUserEditCell(
                team: widget.team,
                key: ValueKey(i.email),
                userStat: i,
                color: dmodel.color,
              ),
              const SizedBox(height: 16),
            ],
          ),
      ],
    );
  }

  List<UserStat> _filterList() {
    if (_filterText.isNotEmpty) {
      return newList
          .where((element) =>
              (element.email.contains(_filterText)) ||
              (element.firstName?.contains(_filterText) ?? false) ||
              (element.lastName?.contains(_filterText) ?? false))
          .toList();
    } else {
      return newList;
    }
  }

  Widget _confirm(BuildContext context, DataModel dmodel) {
    return XCWideButton.primary(
      title: "Confirm",
      color: dmodel.color,
      isLoading: isLoading,
      onTap: () {
        // send mutated list
        _waitForCompletion(context);
      },
    );
  }

  Future<void> _waitForCompletion(BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    await widget.completion(newList);
    setState(() {
      isLoading = false;
    });
  }
}
