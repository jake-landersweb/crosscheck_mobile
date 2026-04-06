import 'package:crosscheck_sports/components/adaptive/icon/adaptive_icon.dart';
import 'package:crosscheck_sports/components/adaptive/tab_bar/adaptive_tab_bar.dart';
import 'package:crosscheck_sports/components/adaptive/tab_bar/tab_bar_insets.dart';
import 'package:crosscheck_sports/components/adaptive/tab_bar/tab_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:provider/provider.dart';
import '../root.dart';

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  _MainHomeState createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  late int _selectedIndex;
  double _tabBarHeight = 0;

  @override
  void initState() {
    super.initState();
    final dmodel = context.read<DataModel>();
    _selectedIndex = dmodel.scheduleIndex;
    // Listen to external index changes (e.g. deep links, notifications)
    dmodel.addListener(_syncFromModel);
  }

  @override
  void dispose() {
    context.read<DataModel>().removeListener(_syncFromModel);
    super.dispose();
  }

  void _syncFromModel() {
    final dmodel = context.read<DataModel>();
    if (dmodel.scheduleIndex != _selectedIndex) {
      setState(() {
        _selectedIndex = dmodel.scheduleIndex;
      });
    }
  }

  void _onTabSelected(int idx) {
    debugPrint('[MainHome] _onTabSelected idx=$idx');
    final dmodel = context.read<DataModel>();
    // Handle badge clearing
    if (idx == 2 && dmodel.showUnreadBadge == true) {
      dmodel.setChatBadge(false);
    } else if (idx == 0 && dmodel.showPollBadge) {
      dmodel.setPollBadge(false);
    }
    // Update local state first (fast, no full tree rebuild)
    setState(() {
      _selectedIndex = idx;
    });
    // Sync to model without triggering notifyListeners rebuild here
    dmodel.scheduleIndex = idx;
  }

  @override
  Widget build(BuildContext context) {
    final dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Content pages kept alive via IndexedStack
          Positioned.fill(
            child: TabBarInsets(
              height: _tabBarHeight,
              child: _buildPages(context, dmodel),
            ),
          ),
          // Tab bar as floating overlay (matches Envoyr pattern)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (dmodel.currentSeason?.seasonStatus == 2 &&
                    ((dmodel.currentSeasonUser?.isSeasonAdmin() ?? false) ||
                        (dmodel.tus?.user.isTeamAdmin() ?? false)))
                  Container(
                    width: double.infinity,
                    color: Colors.red.withValues(alpha: 0.3),
                    child: const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Center(
                        child: Text(
                            "Future seasons are not visible to your users."),
                      ),
                    ),
                  ),
                AdaptiveTabBar(
                  selectedIndex: _selectedIndex,
                  onTabSelected: _onTabSelected,
                  onHeightChanged: (height) {
                    if (height != _tabBarHeight) {
                      setState(() {
                        _tabBarHeight = height;
                      });
                    }
                  },
                  items: [
                    AdaptiveTabBarItem(
                      label: "Season",
                      icon: const AdaptiveIcon(
                        icon: Icons.home_rounded,
                        sfSymbol: 'house.fill',
                      ),
                      badge:
                          (!dmodel.noSeason && dmodel.showPollBadge) ? '' : null,
                    ),
                    const AdaptiveTabBarItem(
                      label: "Schedule",
                      icon: AdaptiveIcon(
                        icon: Icons.calendar_month_rounded,
                        sfSymbol: 'calendar',
                      ),
                    ),
                    AdaptiveTabBarItem(
                      label: "Chat",
                      icon: const AdaptiveIcon(
                        icon: Icons.forum_rounded,
                        sfSymbol: 'bubble.left.and.bubble.right.fill',
                      ),
                      badge: (!dmodel.noSeason && dmodel.showUnreadBadge)
                          ? ''
                          : null,
                    ),
                    const AdaptiveTabBarItem(
                      label: "Account",
                      icon: AdaptiveIcon(
                        icon: Icons.account_circle_rounded,
                        sfSymbol: 'person.crop.circle.fill',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPages(BuildContext context, DataModel dmodel) {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        // Tab 0: Season
        dmodel.tus != null
            ? SeasonPage(
                team: dmodel.tus!.team,
                teamUser: dmodel.tus!.user,
              )
            : Container(),
        // Tab 1: Schedule
        const Schedule(),
        // Tab 2: Chat
        dmodel.currentSeason != null
            ? ChatHome(
                team: dmodel.tus!.team,
                user: dmodel.user!,
              )
            : Container(),
        // Tab 3: Settings
        dmodel.user != null ? Settings(user: dmodel.user!) : Container(),
      ],
    );
  }
}
