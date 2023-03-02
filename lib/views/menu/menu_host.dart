import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:crosscheck_sports/views/chat/season_chat.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'package:uuid/uuid.dart';

import 'root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import '../../client/root.dart';
import '../root.dart';
import '../../data/season/root.dart';

class MenuHost extends StatefulWidget {
  @override
  _MenuHostState createState() => _MenuHostState();
}

class _MenuHostState extends State<MenuHost> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    var _menu = Provider.of<MenuModel>(context);
    var _size = MediaQuery.of(context).size;
    return Stack(
      // make sure everything plays nice
      alignment: Alignment.center,
      children: [
        // menu
        menu(context, _menu, _size),
        // allow view to be in a container that can animate its relative position
        AnimatedPositioned(
          duration: _menu.animate
              ? const Duration(milliseconds: 800)
              : const Duration(milliseconds: 0),
          // custom curve
          curve: Sprung.overDamped,
          // offset to the right direction
          right: _menu.offset,
          width: _size.width,
          height: _size.height,
          // let entire view track gestures
          child: GestureDetector(
            // absorb pointer so the view cannot be interacted with when the view is open
            child: AbsorbPointer(
              absorbing: _menu.isOpen ? true : false,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    left: BorderSide(
                        color: _menu.offset < 0
                            ? CustomColors.textColor(context).withOpacity(0.2)
                            : Colors.transparent,
                        width: 0.5),
                  ),
                ),
                // keep view out of top safe area
                child: _getPage(dmodel, _menu),
              ),
            ),
            // when the gesture starts
            onHorizontalDragStart: (value) {
              // turn off animation so dragging feels natural
              _menu.animate = false;
              // detext if a pan drag
              if (value.globalPosition.dx < 50) {
                _menu.isPan = true;
              } else {
                _menu.isPan = false;
              }
              // get starting location for jitterless drag
              _menu.dragStart = value.localPosition.dx;
              // update the state
              setState(() {});
            },
            // while drag is occuring
            onHorizontalDragUpdate: (value) {
              if (_menu.isOpen) {
                // if the menu is being dragged left but not past the screen edge
                if ((value.localPosition.dx - _menu.dragStart) < 0 &&
                    (value.localPosition.dx - _menu.dragStart) >=
                        -_size.width / _menu.sizeThreashold) {
                  // set the offset to follow the users finger
                  setState(() {
                    _menu.offset = (_menu.cachedOffset -
                        (value.localPosition.dx - _menu.dragStart));
                  });
                }
                // if menu is closed, let the user open it
                // if swipe is going right but not greater than 1/3 of screen width
              } else if ((value.globalPosition.dx - _menu.dragStart) <=
                      _size.width / _menu.sizeThreashold &&
                  value.globalPosition.dx - _menu.dragStart > 0 &&
                  _menu.isPan) {
                setState(() {
                  _menu.offset = -value.globalPosition.dx + _menu.dragStart;
                });
              }
            },
            // on drag end
            onHorizontalDragEnd: (value) {
              // allow menu movement to animate
              setState(() {
                _menu.animate = true;
              });
              // if menu was open or closed enough / velocity was high enough open / close it
              if (_menu.isOpen) {
                if (_menu.offset > -_size.width / (_menu.sizeThreashold * 2) ||
                    (value.primaryVelocity ?? 0) < -700) {
                  _menu.close();
                } else {
                  _menu.open(_size);
                }
              } else {
                if (_menu.offset < -_size.width / (_menu.sizeThreashold * 2) ||
                    (value.primaryVelocity ?? 0) > 700) {
                  _menu.open(_size);
                } else {
                  _menu.close();
                }
              }
            },
            // when the menu is open, let the user tap the screen to close it
            onTap: () {
              if (_menu.isOpen) {
                _menu.close();
              }
            },
          ),
        ),
      ],
    );
  }

  Widget menu(BuildContext context, MenuModel _menu, Size _size) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Container(
      color: Theme.of(context).brightness == Brightness.light
          ? Colors.white
          : CustomColors.darkList,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TeamLogo(
                url: dmodel.tus?.team.image ?? "",
                size:
                    (_size.width / _menu.sizeThreashold) - 32 > _size.height / 2
                        ? _size.height / 3
                        : (_size.width / _menu.sizeThreashold) - 32,
                color: dmodel.color,
              ),
            ),
            const SizedBox(height: 16),
            // the glue that holds the whole menu together
            Container(width: double.infinity),
            SizedBox(
              width:
                  (MediaQuery.of(context).size.width / _menu.sizeThreashold) -
                      16,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  for (var i in getMenuItems(dmodel))
                    _menuRowWrapper(context, i, _menu, _size),
                  // feedback button
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: cv.BasicButton(
                      onTap: () {
                        cv.showFloatingSheet(
                          context: context,
                          builder: (context) {
                            return Suggestions(email: dmodel.user!.email);
                          },
                        );
                      },
                      child: Container(
                        width: (_size.width / _menu.sizeThreashold) - 32,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color:
                              CustomColors.textColor(context).withOpacity(0.1),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Row(
                            children: [
                              Icon(Icons.chat_outlined,
                                  color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 12),
                              Text(
                                "Feedback",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 20,
                                  color: CustomColors.textColor(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuRowWrapper(
      BuildContext context, MenuObject item, MenuModel menu, Size size) {
    switch (item.type) {
      case MenuObjectType.view:
        if (item.showLogic()) {
          return Column(
            children: [
              _menuRow(context, item, menu, size),
              if (item.hasBottomPadding ?? true) const SizedBox(height: 16),
            ],
          );
        } else {
          return Container();
        }
      case MenuObjectType.spacer:
        return const SizedBox(height: 16);
      case MenuObjectType.divider:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Divider(
            thickness: 0.5,
            indent: 16,
            endIndent: 0,
            height: 0.5,
          ),
        );
    }
  }

  Widget _menuRow(
      BuildContext context, MenuObject _item, MenuModel _menu, Size _size) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: cv.BasicButton(
        onTap: () {
          setState(() {
            _menu.selectedPage = _item.id;
          });
          // close the menu
          Future.delayed(const Duration(milliseconds: 200), () {
            _menu.close();
          });
        },
        child: Container(
          width: (_size.width / _menu.sizeThreashold) - 32,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: _menu.selectedPage == _item.id
                ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                : Colors.transparent,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Row(
              children: [
                Icon(
                  _item.icon,
                  color: _menu.selectedPage == _item.id
                      ? Theme.of(context).colorScheme.primary
                      : CustomColors.textColor(context),
                ),
                const SizedBox(width: 12),
                Text(
                  _item.title,
                  style: TextStyle(
                    fontWeight: _menu.selectedPage == _item.id
                        ? FontWeight.w700
                        : FontWeight.w500,
                    fontSize: 20,
                    color: _menu.selectedPage == _item.id
                        ? Theme.of(context).colorScheme.primary
                        : CustomColors.textColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // for getting the view
  Widget _getPage(DataModel dmodel, MenuModel menu) {
    try {
      MenuObject obj = getMenuItems(dmodel)
          .firstWhere((element) => element.id == menu.selectedPage);
      return obj.child(context);
    } catch (error) {
      log("Error finding the page");
      print(error);
      return Container();
    }
  }

  // list of all views and logic on whether to show those views
  List<MenuObject> getMenuItems(DataModel dmodel) {
    List<MenuObject> items = [];
    if (dmodel.teamArgs != null && dmodel.teamArgs!.menuObjects != null) {
      items.addAll(dmodel.teamArgs!.menuObjects!);
    }
    items.addAll([
      MenuObject(
        id: "dashboard",
        sortOrder: 1,
        title: 'Dashboard',
        icon: Icons.event_note_rounded,
        child: (context) => const MainHome(),
        showLogic: () => !dmodel.customAppTeamFan,
        type: MenuObjectType.view,
      ),
      MenuObject(
        id: "seasonInfo",
        sortOrder: 2,
        title: 'Season Page',
        icon: Icons.lightbulb_outline,
        child: (context) => dmodel.currentSeason == null
            ? Container()
            : SeasonHome(
                season: dmodel.currentSeason!,
                team: dmodel.tus!.team,
                teamUser: dmodel.tus!.user,
                seasonUser: dmodel.currentSeasonUser,
              ),
        showLogic: () => !dmodel.noSeason,
        type: MenuObjectType.view,
      ),
      MenuObject(
        id: "teamInfo",
        sortOrder: 3,
        title: 'Team Page',
        icon: Icons.group_outlined,
        child: (context) => dmodel.tus == null
            ? Container()
            : TeamPage(
                team: dmodel.tus!.team,
                seasons: dmodel.tus!.seasons,
                teamUser: dmodel.tus!.user,
              ),
        showLogic: () => !dmodel.noTeam,
        type: MenuObjectType.view,
      ),
      MenuObject(
        id: "settings",
        sortOrder: 4,
        title: 'Your Profile',
        icon: Icons.settings_outlined,
        child: (context) => Settings(user: dmodel.user!),
        showLogic: () => true,
        type: MenuObjectType.view,
      ),
    ]);
    return items;
  }
}
