import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';
import 'client/root.dart';
import 'theme/root.dart';
import 'views/root.dart';
import 'custom_views/root.dart' as cv;

class TeamArguments {
  late String teamId;
  late String teamName;
  String? initPageUsers;
  String? initPageFans;
  List<Widget>? trailingItems;

  TeamArguments({
    required this.teamId,
    required this.teamName,
    this.initPageUsers,
    this.initPageFans,
    this.trailingItems,
  });
}

class CrosscheckEngine extends StatefulWidget {
  const CrosscheckEngine({
    Key? key,
    this.teamArgs,
  }) : super(key: key);
  final TeamArguments? teamArgs;

  @override
  State<CrosscheckEngine> createState() => _CrosscheckEngineState();
}

class _CrosscheckEngineState extends State<CrosscheckEngine> {
  @override
  Widget build(BuildContext context) {
    return RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => DataModel(teamArgs: widget.teamArgs),
          ),
        ],
        child: const MyApp(),
      ),
    );
  }
}

class ScrollBehaviorModified extends ScrollBehavior {
  const ScrollBehaviorModified();
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics());
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<DataModel>().observeDeepLinks();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // for dismissing keybaord when tapping on the screen
        WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      },
      child: const ScrollConfiguration(
        behavior: ScrollBehaviorModified(),
        child: Home(),
      ),
    );
  }
}

// for allowing absoute reset when needed
class RestartWidget extends StatefulWidget {
  const RestartWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}

final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return MaterialApp(
      title: 'Crosscheck Engine',
      scaffoldMessengerKey: snackbarKey,
      theme: lightTheme,
      darkTheme: darkTheme,
      highContrastTheme: lightTheme,
      highContrastDarkTheme: darkTheme,
      themeMode: dmodel.tus == null
          ? ThemeMode.system
          : (dmodel.tus!.team.isLight ? ThemeMode.light : ThemeMode.dark),
      // themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        return MaterialWithModalsPageRoute(
          settings: settings,
          builder: (context) => NotificationWrapper(
            child: AnnotatedRegion<SystemUiOverlayStyle>(
              value: dmodel.tus == null
                  ? SystemUiOverlayStyle.dark
                  : (dmodel.tus!.team.isLight
                      ? SystemUiOverlayStyle.dark
                      : SystemUiOverlayStyle.light),
              child: Index(
                child: dmodel.showSplash
                    ? dmodel.showUpdate
                        ? const Update()
                        : dmodel.showMaintenance
                            ? const Maintenance()
                            : const SplashScreen()
                    : (dmodel.user == null && !dmodel.forceSchedule)
                        ? dmodel.customAppTeamFan
                            ? Dashboard(
                                initPage: dmodel.teamArgs!.initPageFans ??
                                    "dashboard",
                              )
                            : const CreateAccount(isCreate: true)
                        : Dashboard(
                            initPage: dmodel.teamArgs == null
                                ? "dashboard"
                                : dmodel.teamArgs!.initPageUsers ?? "dashboard",
                          ),
              ),
            ),
          ),
        );
      },
      // showPerformanceOverlay: true,
      // builder: (context, child) {
      //   // so that bottom notifications are shown over all screens
      //   return child == null ? Container() : NotificationWrapper(child: child);
      // },
    );
  }
}

class Index extends StatefulWidget {
  const Index({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _IndexState createState() => _IndexState();
}

class _IndexState extends State<Index> with WidgetsBindingObserver {
  DateTime? _closedTime;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("app is resumed");

        DataModel dmodel = Provider.of<DataModel>(context, listen: false);

        if (dmodel.blockRefresh) {
          print("[BACKGROUND] Blocking refresh code");
        } else {
          // reset the notitication count
          if (dmodel.user != null) {
            dmodel.clearNotificationBadges(dmodel.user!.email);
            // check if data refreshes are needed
            // check for a deep link
            if (dmodel.deepLink != null) {
              print("[BACKGROUND] deep link found");
              // go to dashboard while data loads in
              dmodel.setScheduleIndex(0);
              SchedulerBinding.instance.addPostFrameCallback((_) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              });
              _resetData(dmodel);
            } else {
              print("[BACKGROUND] No deep link found");
              // handle normal refresh path
              if (_closedTime?.isBefore(
                      DateTime.now().subtract(const Duration(minutes: 5))) ??
                  false) {
                // hard reset
                print("[BACKGROUND] performing a hard reset");
                RestartWidget.restartApp(context);
              } else if (_closedTime?.isBefore(
                      DateTime.now().subtract(const Duration(seconds: 30))) ??
                  false) {
                // soft reset
                print("performing a soft reset");
                _resetData(dmodel);
              }
            }
          } else {
            print("[BACKGROUND] USER IS NULL");
          }
        }

        break;
      case AppLifecycleState.inactive:
        print("app is inactive");
        break;
      case AppLifecycleState.paused:
        print("app is paused");
        _closedTime = DateTime.now();
        break;
      case AppLifecycleState.detached:
        print("app is detached");
        break;
    }
  }

  Future<void> _resetData(DataModel dmodel) async {
    await dmodel.refreshData(dmodel.user!.email);
  }

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class NotificationWrapper extends StatefulWidget {
  const NotificationWrapper({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  State<NotificationWrapper> createState() => _NotificationWrapperState();
}

class _NotificationWrapperState extends State<NotificationWrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          // for showing custom messages
          if (dmodel.currentIndicator != null)
            StatusBar(
              key: ValueKey(dmodel.currentIndicator!.id),
              backgroundColor: dmodel.currentIndicator!.getColor(context),
              opacity: dmodel.currentIndicator!.getOpacity(),
              duration: dmodel.currentIndicator!.duration,
              animationTime: dmodel.animationTime * 1000,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        dmodel.currentIndicator!.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: dmodel.currentIndicator!.getTextColor(context),
                        ),
                      ),
                    ),
                    Icon(
                      dmodel.currentIndicator!.getIcon(),
                      color: dmodel.currentIndicator!.getTextColor(context),
                    )
                  ],
                ),
              ),
              completion: () {},
            ),
        ],
      ),
    );
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({
    Key? key,
    required this.backgroundColor,
    required this.opacity,
    required this.child,
    required this.completion,
    required this.duration,
    required this.animationTime,
  }) : super(key: key);

  final Color backgroundColor;
  final double opacity;
  final Widget child;
  final VoidCallback completion;
  final double duration;
  final double animationTime;

  @override
  _StatusBarState createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<Offset> position;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    position = Tween<Offset>(begin: const Offset(0.0, 200), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Sprung.overDamped));

    controller.forward();

    _close();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        controller.reverse();
      });
    } else {}
    await Future.delayed(const Duration(milliseconds: 800));
    widget.completion();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
        child: SlideTransition(
          position: position,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: CustomColors.textColor(context).withOpacity(0.3),
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: cv.GlassContainer(
              borderRadius: BorderRadius.circular(10),
              opacity: widget.opacity,
              backgroundColor: widget.backgroundColor,
              height: 50,
              blur: 10,
              width: MediaQuery.of(context).size.width - 10,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
