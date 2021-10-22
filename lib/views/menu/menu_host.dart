import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

import 'root.dart';
import '../../custom_views/root.dart' as cv;
import '../../extras/root.dart';
import '../../client/root.dart';
import '../root.dart';

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
          duration: _animate
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
                child: cv.AppBar(
                  title: _getTitle(_menu.selectedPage, dmodel),
                  refreshable: _isRefreshable(_menu.selectedPage),
                  onRefresh: () => _refreshAction(_menu.selectedPage, dmodel),
                  isLarge: true,
                  leading: _menuButton(context, _menu, _size),
                  children: [
                    _getView(_menu.selectedPage, dmodel),
                  ],
                ),
              ),
            ),
            // when the gesture starts
            onHorizontalDragStart: (value) {
              // turn off animation so dragging feels natural
              _animate = false;
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
                _animate = true;
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

  Widget _menuButton(BuildContext context, MenuModel _menu, Size _size) {
    return cv.BasicButton(
      child: Icon(_menu.isOpen ? Icons.close : Icons.menu,
          color: Theme.of(context).colorScheme.primary),
      // actionn of the button
      onTap: () {
        // allow for animation
        _animate = true;
        // toggle menu
        if (_menu.isOpen) {
          _menu.close();
        } else {
          _menu.open(_size);
        }
      },
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
            if (dmodel.tus?.team.teamStyle.image != null &&
                dmodel.tus?.team.teamStyle.image != "")
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Image.network(
                  dmodel.tus!.team.teamStyle.image!,
                  width: (_size.width / _menu.sizeThreashold) - 32,
                  errorBuilder: (context, error, stackTrace) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Image.asset(
                        "assets/launch/x.png",
                        width: (_size.width / _menu.sizeThreashold) - 32,
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    }
                    return SizedBox(
                      width: (_size.width / _menu.sizeThreashold) - 32,
                      height: (_size.width / _menu.sizeThreashold) - 32,
                      child: cv.LoadingIndicator(),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Image.asset(
                  "assets/launch/x.png",
                  width: (_size.width / _menu.sizeThreashold) - 32,
                ),
              ),
            const SizedBox(height: 16),
            const Divider(height: 0.5),
            const SizedBox(height: 16),
            _menuRow(context, _menuItems[0], _menu, _size),
            // const SizedBox(height: 16),
            // Divider(
            //     color: CustomColors.textColor(context).withOpacity(0.2),
            //     indent: 0,
            //     endIndent: 0,
            //     height: 0.5),
            const SizedBox(height: 16),
            _menuRow(context, _menuItems[1], _menu, _size),
            const SizedBox(height: 16),
            _menuRow(context, _menuItems[2], _menu, _size),
            const SizedBox(height: 16),
            _menuRow(context, _menuItems[3], _menu, _size),
            const SizedBox(height: 16),
            _menuRow(context, _menuItems[4], _menu, _size),
            // const SizedBox(height: 16),
            // _menuRow(context, _menuItems[5], _menu, _size),
          ],
        ),
      ),
    );
  }

  // Widget menu2(BuildContext context, MenuModel _menu, Size _size) {
  //   return Scaffold(
  //     body: Stack(
  //       children: [
  //         Column(
  //           // these two containers are to account for safe area spill over of the selected color
  //           children: [
  //             // for first menu item
  //             Container(
  //               color: _menu.selectedPage == Pages.team
  //                   ? _selectedColor
  //                   : _unselectedColor,
  //               child: SizedBox(
  //                   height: _size.height / 2,
  //                   width: _size.width / _menu.sizeThreashold),
  //             ),
  //             // for last menu item
  //             Container(
  //               color: _menu.selectedPage == Pages.settings
  //                   ? _selectedColor
  //                   : _unselectedColor,
  //               child: SizedBox(
  //                   height: _size.height / 2,
  //                   width: _size.width / _menu.sizeThreashold),
  //             ),
  //           ],
  //         ),
  //         // menu itself
  //         ListView.builder(
  //           // disable scroll
  //           physics: const NeverScrollableScrollPhysics(),
  //           itemCount: _menuItems.length,
  //           itemBuilder: (context, _index) {
  //             return Column(
  //               children: [
  //                 menuRow(_menuItems[_index], _menu, _size),
  //                 // dividers for the views
  //                 if (_index != _menuItems.length - 1)
  //                   // my own custom divider that i like more
  //                   const SizedBox(
  //                     height: 1,
  //                     width: double.infinity,
  //                     child: ColoredBox(
  //                       color: Color.fromRGBO(10, 10, 10, 1),
  //                     ),
  //                   ),
  //               ],
  //             );
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // menu row widget
  // Widget menuRow(MenuItem _item, MenuModel _menu, Size _size) {
  //   return Row(
  //     children: [
  //       // entire view is a button
  //       cv.BasicButton(
  //         onTap: () {
  //           // set the selected page to this items page
  //           setState(() {
  //             _menu.selectedPage = _item.page;
  //           });
  //           // close the menu
  //           Future.delayed(const Duration(milliseconds: 200), () {
  //             _menu.close();
  //           });
  //         },
  //         // styling for the button
  //         child: Container(
  //           color: _menu.selectedPage == _item.page
  //               ? _selectedColor
  //               : _unselectedColor,
  //           height: _size.width / 3,
  //           width: _size.width / _menu.sizeThreashold,
  //           // center the entire view
  //           child: Center(
  //             // column so icon is on top of text
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 // icon
  //                 Padding(
  //                   padding: const EdgeInsets.only(bottom: 10),
  //                   child: Icon(_item.icon, color: Colors.white, size: 30),
  //                 ),
  //                 // title
  //                 Text(
  //                   _item.title,
  //                   textAlign: TextAlign.center,
  //                   style: const TextStyle(
  //                       color: Colors.white,
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //       // spacer so view is on left side of screen
  //       const Spacer(),
  //     ],
  //   );
  // }

  Widget _menuRow(
      BuildContext context, MenuItem _item, MenuModel _menu, Size _size) {
    return cv.BasicButton(
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
      child: Align(
        alignment: AlignmentDirectional.topStart,
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Material(
            color: _menu.selectedPage == _item.page
                ? Theme.of(context).colorScheme.primary
                : Colors.transparent,
            shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(30)),
            child: SizedBox(
              width: (_size.width / _menu.sizeThreashold) - 32,
              child: Padding(
                padding: const EdgeInsets.all(12),
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
            ),
          ),
        ),
      ),
    );
  }

  // for getting correct view
  Widget _getView(Pages _selection, DataModel dmodel) {
    switch (_selection) {
      case Pages.team:
        if (dmodel.tus == null) {
          return Container();
        } else {
          return Team(teamId: dmodel.tus!.team.teamId);
        }
      case Pages.schedule:
        return const Schedule();
      case Pages.calendar:
        if (dmodel.tus == null) {
          return Container();
        } else {
          return Calendar(
              teamId: dmodel.tus!.team.teamId,
              seasonId: dmodel.currentSeason!.seasonId,
              email: dmodel.user!.email);
        }
      case Pages.seasonRoster:
        if (dmodel.currentSeason == null) {
          return Container();
        } else {
          return const SeasonRoster();
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
      default:
        return Text('Home');
    }
  }

  // for getting title
  String _getTitle(Pages _selection, DataModel dmodel) {
    switch (_selection) {
      case Pages.team:
        if (dmodel.tus == null) {
          return 'Team';
        } else {
          return dmodel.tus!.team.title;
        }
      case Pages.schedule:
        return 'Schedule';
      case Pages.calendar:
        return 'Calendar';
      case Pages.seasonRoster:
        return 'Roster';
      case Pages.seasonSettings:
        return 'Season Select';
      case Pages.settings:
        return 'Settings';
      default:
        return 'Home';
    }
  }

  // for checking if the view is refreshable or not
  bool _isRefreshable(Pages _selection) {
    switch (_selection) {
      case Pages.team:
        return false;
      case Pages.schedule:
        return true;
      case Pages.calendar:
        return true;
      case Pages.seasonRoster:
        return true;
      case Pages.seasonSettings:
        return false;
      case Pages.settings:
        return false;
      default:
        return false;
    }
  }

  // for checking if the view is refreshable or not
  Future<void> _refreshAction(Pages _selection, DataModel dmodel) async {
    switch (_selection) {
      case Pages.schedule:
        if (dmodel.currentSeason != null) {
          await dmodel.scheduleGet(dmodel.tus!.team.teamId,
              dmodel.currentSeason!.seasonId, dmodel.user!.email, (schedule) {
            dmodel.setSchedule(schedule);
            // invalidate old data
            dmodel.seasonUsers = null;
            // dmodel.teamRoster = null;
          });
        }
        break;
      case Pages.calendar:
        if (dmodel.currentSeason != null) {
          await dmodel.scheduleGet(dmodel.tus!.team.teamId,
              dmodel.currentSeason!.seasonId, dmodel.user!.email, (schedule) {
            dmodel.setSchedule(schedule);
            // invalidate old data
            dmodel.seasonUsers = null;
            // dmodel.teamRoster = null;
          });
        }
        break;
      case Pages.seasonRoster:
        if (dmodel.currentSeason != null) {
          await dmodel.getSeasonRoster(
              dmodel.tus!.team.teamId, dmodel.currentSeason!.seasonId, (users) {
            dmodel.setSeasonUsers(users);
          });
        }
        break;
      default:
        print("error");
        break;
    }
  }

  bool _animate = false;

  final List<MenuItem> _menuItems = [
    // const MenuItem(
    //   title: 'Team',
    //   icon: Icons.circle_outlined,
    //   page: Pages.team,
    // ),
    const MenuItem(
      title: 'Schedule',
      icon: Icons.list,
      page: Pages.schedule,
    ),
    const MenuItem(
      title: 'Calendar',
      icon: Icons.calendar_today,
      page: Pages.calendar,
    ),
    const MenuItem(
      title: 'Roster',
      icon: Icons.person,
      page: Pages.seasonRoster,
    ),
    const MenuItem(
      title: 'Season Select',
      icon: Icons.fact_check,
      page: Pages.seasonSettings,
    ),
    const MenuItem(
      title: 'Settings',
      icon: Icons.settings,
      page: Pages.settings,
    ),
  ];
}
