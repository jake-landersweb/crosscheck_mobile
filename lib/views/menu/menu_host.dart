import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:pnflutter/views/chat/season_chat.dart';
import 'package:pnflutter/views/schedule/event_edit/event_create_edit.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

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
                child: _getView(_menu.selectedPage, dmodel),
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
      color: MediaQuery.of(context).platformBrightness == Brightness.light
          ? Colors.white
          : CustomColors.darkList,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (dmodel.tus?.team.image != "" && dmodel.tus != null)
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.network(
                  dmodel.tus!.team.image,
                  width: (_size.width / _menu.sizeThreashold) - 32,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/launch/x.png",
                      width: (_size.width / _menu.sizeThreashold) - 32,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      width: (_size.width / _menu.sizeThreashold) - 32,
                      height: (_size.width / _menu.sizeThreashold) - 32,
                      child: const cv.LoadingIndicator(),
                    );
                  },
                ),
              )
            else
              Image.asset(
                "assets/launch/x.png",
                width: (_size.width / _menu.sizeThreashold) - 32,
              ),
            const SizedBox(height: 16),
            const Divider(height: 0.5),
            SizedBox(
              width:
                  (MediaQuery.of(context).size.width / _menu.sizeThreashold) -
                      16,
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                children: [
                  const SizedBox(height: 16),
                  _menuRow(context, _menuItems[0], _menu, _size),
                  const SizedBox(height: 16),
                  if (!dmodel.noSeason)
                    _menuRow(context, _menuItems[1], _menu, _size),
                  if (!dmodel.noSeason) const SizedBox(height: 16),
                  if (!dmodel.noSeason)
                    _menuRow(context, _menuItems[2], _menu, _size),
                  if (!dmodel.noSeason) const SizedBox(height: 16),
                  _menuRow(context, _menuItems[3], _menu, _size),
                  const SizedBox(height: 16),
                  if (!dmodel.noSeason)
                    _menuRow(context, _menuItems[4], _menu, _size),
                  const SizedBox(height: 16),
                  if (dmodel.tus?.user.isTeamAdmin() ?? false)
                    _menuRow(context, _menuItems[5], _menu, _size),
                  const SizedBox(height: 16),
                  if ((dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) &&
                      !dmodel.noSeason)
                    _menuRow(context, _menuItems[6], _menu, _size),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuRow(
      BuildContext context, MenuItem _item, MenuModel _menu, Size _size) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: cv.RoundedLabel(
        "",
        width: (_size.width / _menu.sizeThreashold) - 32,
        color: _menu.selectedPage == _item.page
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        textColor: _menu.selectedPage == _item.page
            ? Colors.white
            : CustomColors.textColor(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(
                _item.icon,
                color: _menu.selectedPage == _item.page
                    ? Colors.white
                    : CustomColors.textColor(context),
              ),
              const SizedBox(width: 12),
              Text(
                _item.title,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: _menu.selectedPage == _item.page
                      ? Colors.white
                      : CustomColors.textColor(context),
                ),
              ),
            ],
          ),
        ),
        onTap: () {
          // set the selected page to this items page
          setState(() {
            _menu.selectedPage = _item.page;
          });
          // close the menu
          Future.delayed(const Duration(milliseconds: 200), () {
            _menu.close();
          });
        },
      ),
    );
  }

  // for getting correct view
  Widget _getView(Pages _selection, DataModel dmodel) {
    switch (_selection) {
      case Pages.schedule:
        return const Schedule();
      case Pages.calendar:
        return Container();
      case Pages.seasonRoster:
        if (dmodel.currentSeason == null) {
          return Container();
        } else {
          return SeasonRoster(
            team: dmodel.tus!.team,
            season: dmodel.currentSeason!,
            seasonUsers: dmodel.seasonUsers,
            teamUser: dmodel.tus!.user,
            currentSeasonUser: dmodel.currentSeasonUser,
            isOnTeam: true,
          );
        }
      case Pages.seasonSettings:
        if (dmodel.currentSeason == null) {
          return Container();
        } else {
          return SeasonSelect(
              email: dmodel.user!.email,
              tus: dmodel.tus!,
              currentSeason: dmodel.currentSeason!);
        }
      case Pages.settings:
        return const Settings();
      case Pages.teamAdmin:
        if (dmodel.tus != null) {
          return TeamAdmin(
              team: dmodel.tus!.team, seasons: dmodel.tus!.seasons);
        } else {
          return Container();
        }
      case Pages.seasonAdmin:
        return SeasonAdmin(
            season: dmodel.currentSeason!, team: dmodel.tus!.team);
      case Pages.chat:
        if (dmodel.currentSeason != null && dmodel.currentSeasonUser != null) {
          return ChatHome(
            team: dmodel.tus!.team,
            season: dmodel.currentSeason!,
            user: dmodel.user!,
            seasonUser: dmodel.currentSeasonUser!,
          );
        } else {
          return Container();
        }
      default:
        return Text('Home');
    }
  }

  final List<MenuItem> _menuItems = [
    // const MenuItem(
    //   title: 'Team',
    //   icon: Icons.circle_outlined,
    //   page: Pages.team,
    // ),
    const MenuItem(
      title: 'Schedule',
      icon: Icons.event_note,
      page: Pages.schedule,
    ),
    const MenuItem(
      title: 'Roster',
      icon: Icons.people,
      page: Pages.seasonRoster,
    ),
    const MenuItem(
      title: 'Season Select',
      icon: Icons.rule,
      page: Pages.seasonSettings,
    ),
    const MenuItem(
      title: 'Chat',
      icon: Icons.chat,
      page: Pages.chat,
    ),
    const MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      page: Pages.settings,
    ),
    const MenuItem(
      title: 'Team Admin',
      icon: Icons.admin_panel_settings,
      page: Pages.teamAdmin,
    ),
    const MenuItem(
      title: 'Season Admin',
      icon: Icons.admin_panel_settings,
      page: Pages.seasonAdmin,
    ),
  ];
}
