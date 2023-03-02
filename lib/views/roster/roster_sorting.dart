import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/extras/root.dart';
import '../../custom_views/root.dart' as cv;
import 'dart:math' as math;
import '../components/root.dart' as comp;

class RosterSorting extends ChangeNotifier {
  late Team _team;
  Season? _season;
  bool? _isSubs;
  int? _currentSeasonStatus;
  final TextEditingController _controller = TextEditingController();

  String _currentPosition = "";
  CustomField? sortCF;
  bool _sortCFAsc = false;

  RosterSorting({
    required Team team,
    Season? season,
    bool? isActive,
  }) {
    _team = team;
    _season = season;
    if (season != null) {
      if (isActive ?? true) {
        _currentSeasonStatus = 1;
      } else {
        _currentSeasonStatus = -1;
      }
    }
  }

  List<SeasonUser> users(List<SeasonUser> users, {bool showNicknames = false}) {
    bool isSeason = _season != null;
    late List<SeasonUser> list;
    if (isSeason) {
      list = users
          .where((element) =>
              (_currentPosition.isEmpty
                  ? true
                  : _currentPosition.toLowerCase() ==
                      element.seasonFields!.pos.toLowerCase()) &&
              (element.seasonFields!.seasonUserStatus == _currentSeasonStatus))
          .toList();
      if (_isSubs != null) {
        list = list
            .where((element) => element.seasonFields!.isSub == _isSubs)
            .toList();
      }
    } else {
      list = users
          .where((element) => (_currentPosition.isEmpty
              ? true
              : _currentPosition.toLowerCase() ==
                  element.teamFields!.pos.toLowerCase()))
          .toList();
    }

    // sort by nickname, then first name, then email
    list = sortSeasonUsers(list, showNicknames: showNicknames);

    if (sortCF != null) {
      list.sort((user1, user2) {
        late String u1;
        if (isSeason) {
          u1 = user1.seasonFields!.customFields
              .firstWhere((element) => element.getTitle() == sortCF!.getTitle())
              .getValue();
        } else {
          u1 = user1.teamFields!.customFields
              .firstWhere((element) => element.getTitle() == sortCF!.getTitle())
              .getValue();
        }
        late String u2;
        if (isSeason) {
          u2 = user2.seasonFields!.customFields
              .firstWhere((element) => element.getTitle() == sortCF!.getTitle())
              .getValue();
        } else {
          u2 = user2.teamFields!.customFields
              .firstWhere((element) => element.getTitle() == sortCF!.getTitle())
              .getValue();
        }
        if (_sortCFAsc) {
          return u1.compareTo(u2);
        } else {
          return u2.compareTo(u1);
        }
      });
    }

    // add search functionality
    if (_controller.text.isNotEmpty) {
      list = list
          .where((element) =>
              element.email.contains(_controller.text) ||
              (element.userFields?.firstName?.contains(_controller.text) ??
                  false) ||
              (element.userFields?.lastName?.contains(_controller.text) ??
                  false) ||
              (element.userFields?.nickname?.contains(_controller.text) ??
                  false))
          .toList();
    }
    return list;
  }

  Widget header(BuildContext context, DataModel dmodel) {
    bool isSeason = _season != null;
    return Column(
      children: [
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            cv.TextField2(
              labelText: "Search ...",
              controller: _controller,
              isLabeled: false,
              highlightColor: dmodel.color,
              onChanged: (value) {
                notifyListeners();
              },
            ),
            if (_controller.text.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: cv.BasicButton(
                  onTap: () {
                    _controller.text = "";
                    notifyListeners();
                  },
                  child: Icon(
                    Icons.cancel,
                    color: CustomColors.textColor(context).withOpacity(0.3),
                  ),
                ),
              ),
          ],
        ),
        cv.Section(
          "Filter",
          allowsCollapse: true,
          initOpen: false,
          child: Column(
            children: [
              Row(
                children: [
                  cv.BasicButton(
                    onTap: () {
                      cv.showFloatingSheet(
                          context: context,
                          builder: (context) {
                            return cv.Sheet(
                              title: "Select Position",
                              color: dmodel.color,
                              child: cv.DynamicSelector<String>(
                                selectorStyle: cv.DynamicSelectorStyle.list,
                                color: dmodel.color,
                                selections: isSeason
                                    ? _season!.positions.available
                                    : _team.positions.available,
                                onSelect: (context, item) {
                                  _currentPosition = item;
                                  notifyListeners();
                                  Navigator.of(context).pop();
                                },
                                selectedLogic: (context, item) =>
                                    item == _currentPosition,
                              ),
                            );
                          });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: CustomColors.cellColor(context),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(
                          _currentPosition.isEmpty
                              ? "Select Position"
                              : _currentPosition,
                          style: TextStyle(
                            color: CustomColors.textColor(context),
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  cv.BasicButton(
                    onTap: () {
                      _currentPosition = "";
                      notifyListeners();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: CustomColors.cellColor(context),
                          borderRadius: BorderRadius.circular(5)),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                        child: Icon(
                          Icons.close_rounded,
                          color: CustomColors.textColor(context),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // AlignedGridView.count(
              //   shrinkWrap: true,
              //   physics: const NeverScrollableScrollPhysics(),
              //   crossAxisCount: 3,
              //   mainAxisSpacing: 8,
              //   crossAxisSpacing: 8,
              //   itemCount: isSeason
              //       ? _season!.positions.available.length
              //       : _team.positions.available.length,
              //   itemBuilder: (context, index) {
              //     late String pos;
              //     if (isSeason) {
              //       pos = _season!.positions.available[index];
              //     } else {
              //       pos = _team.positions.available[index];
              //     }
              //     return _filterCell(
              //         context, dmodel, pos, _currentPosition == pos, () {
              //       if (_currentPosition == pos) {
              //         _currentPosition = "";
              //       } else {
              //         _currentPosition = pos;
              //       }
              //       notifyListeners();
              //     });
              //   },
              // ),
              if (isSeason)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    cv.SegmentedPicker(
                      titles: const ["All", "Subs", "Not Subs"],
                      selection: _isSubs,
                      selections: const [null, true, false],
                      style: comp.segmentedPickerStyle(
                        context,
                        dmodel,
                        // height: 30,
                      ),
                      onSelection: (item) {
                        _isSubs = item;
                        notifyListeners();
                      },
                    ),
                    const SizedBox(height: 16),
                    cv.SegmentedPicker(
                      titles: const ["Active", "Inactive"],
                      selection: _currentSeasonStatus,
                      selections: const [1, -1],
                      style: comp.segmentedPickerStyle(
                        context,
                        dmodel,
                        // height: 30,
                      ),
                      onSelection: (item) {
                        _currentSeasonStatus = item;
                        notifyListeners();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        cv.Section(
          "Sort",
          allowsCollapse: true,
          initOpen: false,
          child: Column(
            children: [
              // custom fields
              Column(
                children: [
                  // custom field selector
                  Row(
                    children: [
                      cv.BasicButton(
                        onTap: () {
                          cv.showFloatingSheet(
                            context: context,
                            builder: (context) {
                              return CustomFieldSelector(
                                customFields: isSeason
                                    ? _season!.customUserFields
                                    : _team.customUserFields,
                                initialSelection: sortCF,
                                onSelect: (item) {
                                  if (sortCF == item) {
                                    sortCF = null;
                                  } else {
                                    sortCF = item;
                                  }
                                  notifyListeners();
                                },
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: dmodel.color.withOpacity(0.3),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              sortCF == null
                                  ? "Select Custom Field"
                                  : sortCF!.getTitle(),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: dmodel.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (sortCF != null && sortCF?.getType() == "I")
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: sortCF == null
                                ? Container()
                                : cv.BasicButton(
                                    onTap: () {
                                      _sortCFAsc = !_sortCFAsc;
                                      notifyListeners();
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: CustomColors.textColor(context)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 4, 8, 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              _sortCFAsc ? "Asc" : "Desc",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 16,
                                                color: CustomColors.textColor(
                                                    context),
                                              ),
                                            ),
                                            Transform.rotate(
                                              angle: _sortCFAsc
                                                  ? math.pi / -2
                                                  : math.pi / 2,
                                              child: Icon(
                                                Icons.chevron_right_outlined,
                                                color: CustomColors.textColor(
                                                    context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        )
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterCell(BuildContext context, DataModel dmodel, String val,
      bool selected, VoidCallback onTap) {
    return cv.BasicButton(
      onTap: () => onTap(),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: dmodel.color.withOpacity(0.3),
          border: Border.all(
            color: selected ? dmodel.color : Colors.transparent,
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Text(
              val,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: dmodel.color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
