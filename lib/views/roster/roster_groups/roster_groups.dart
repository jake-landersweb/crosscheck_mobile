import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/roster/roster_group.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/components/buttons.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/roster/roster_groups/rg_cu.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;

class RosterGroups extends StatefulWidget {
  const RosterGroups({
    super.key,
    required this.team,
    required this.season,
    required this.seasonRoster,
    this.hasAppBar = true,
    this.onSelect,
    this.loadingOverride,
    this.animateOnAppear = false,
  });
  final Team team;
  final Season season;
  final List<SeasonUser> seasonRoster;
  final bool hasAppBar;
  final void Function(RosterGroup)? onSelect;
  final Widget? loadingOverride;
  final bool animateOnAppear;

  @override
  State<RosterGroups> createState() => _RosterGroupsState();
}

class _RosterGroupsState extends State<RosterGroups> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return ChangeNotifierProvider<RGModel>(
      create: (_) => RGModel(
        team: widget.team,
        season: widget.season,
        seasonRoster: widget.seasonRoster,
        dmodel: dmodel,
      ),
      // we use `builder` to obtain a new `BuildContext` that has access to the provider
      builder: (context, child) {
        // No longer throws
        return _body(context, dmodel);
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    RGModel rgmodel = Provider.of<RGModel>(context);
    if (widget.hasAppBar) {
      return Scaffold(
        body: cv.AppBar(
          title: "Roster Groups",
          itemBarPadding: const EdgeInsets.fromLTRB(8, 0, 16, 8),
          leading: [cv.BackButton(color: dmodel.color)],
          color: dmodel.color,
          onRefresh: () async => await rgmodel.getRosterGroups(dmodel),
          refreshable: true,
          trailing: [
            cv.BasicButton(
              onTap: () => _create(context, dmodel, rgmodel),
              child: Icon(
                Icons.add,
                color: dmodel.color,
              ),
            ),
          ],
          children: [_content(context, dmodel, rgmodel)],
        ),
      );
    } else {
      return _content(context, dmodel, rgmodel);
    }
  }

  Widget _content(BuildContext context, DataModel dmodel, RGModel rgmodel) {
    if (rgmodel.isLoading) {
      if (widget.loadingOverride == null) {
        return const RosterLoading();
      } else {
        return widget.loadingOverride!;
      }
    } else {
      if (rgmodel.errorText.isNotEmpty) {
        return _error(context, rgmodel);
      } else {
        if (rgmodel.rosterGroups == null) {
          return _error(context, rgmodel);
        } else {
          if (rgmodel.rosterGroups!.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  cv.NoneFound(
                    "There are no roster groups for your season.",
                    color: dmodel.color,
                  ),
                  const SizedBox(height: 16),
                  ActionButton(
                    title: "Create Roster Group",
                    color: dmodel.color,
                    horizPadding: 16,
                    onTap: () => _create(context, dmodel, rgmodel),
                  ),
                ],
              ),
            );
          } else {
            if (widget.hasAppBar) {
              return _rgList(context, dmodel, rgmodel);
            } else {
              return SingleChildScrollView(
                child: _rgList(context, dmodel, rgmodel),
              );
            }
          }
        }
      }
    }
  }

  Widget _rgList(BuildContext context, DataModel dmodel, RGModel rgmodel) {
    return cv.ListView<RosterGroup>(
      horizontalPadding: 0,
      children: rgmodel.rosterGroups!
        ..sort((a, b) => a.created.compareTo(b.created)),
      childBuilder: ((context, item) {
        return _rosterGroupCell(context, item);
      }),
      isAnimated: widget.animateOnAppear,
      animateOpen: widget.animateOnAppear,
      onChildTap: (context, item) {
        if (widget.onSelect == null) {
          cv.Navigate(
            context,
            ListenableProvider.value(
              value: rgmodel,
              child: RGView(
                team: widget.team,
                season: widget.season,
                rosterGroup: item,
                seasonUsers: widget.seasonRoster,
              ),
            ),
          );
        } else {
          widget.onSelect!(item);
        }
      },
    );
  }

  Widget _rosterGroupCell(BuildContext context, RosterGroup rg) {
    return Row(
      children: [
        rg.getIcon(40),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rg.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: CustomColors.textColor(context),
                ),
              ),
              if (rg.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Text(
                    rg.description,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: CustomColors.textColor(context).withOpacity(0.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: CustomColors.textColor(context).withOpacity(0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 2),
            child: Text(
              "${rg.ids.length} User${rg.ids.length > 1 ? "s" : ""}",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: CustomColors.textColor(context).withOpacity(0.5),
              ),
            ),
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          color: CustomColors.textColor(context).withOpacity(0.5),
        ),
      ],
    );
  }

  Widget _error(BuildContext context, RGModel rgmodel) {
    return Center(
      child: Text(
        rgmodel.errorText,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _create(BuildContext context, DataModel dmodel, RGModel rgmodel) {
    cv.cupertinoSheet(
        context: context,
        builder: (context) {
          return ListenableProvider.value(
            value: rgmodel,
            child: const RGCU(),
          );
        });
  }
}
