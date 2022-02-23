import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

import 'client/root.dart';
import 'theme/root.dart';
import 'views/root.dart';
import 'extras/root.dart';
import 'views/root.dart';
import 'extras/root.dart';
import 'custom_views/root.dart' as cv;

void main() {
  runApp(
    RestartWidget(
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => DataModel()),
          ChangeNotifierProvider(create: (context) => MenuModel())
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // for dismissing keybaord when tapping on the screen
        if (WidgetsBinding.instance != null) {
          WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
        }
      },
      child: const Home(),
    );
  }
}

// for allowing absoute reset when needed
class RestartWidget extends StatefulWidget {
  const RestartWidget({
    Key? key,
    required this.child,
  });

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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return MaterialApp(
      title: 'Puck Norris Flutter',
      theme: lightTheme,
      darkTheme: darkTheme,
      highContrastTheme: lightTheme,
      highContrastDarkTheme: darkTheme,
      debugShowCheckedModeBanner: false,
      home: dmodel.showSplash
          ? dmodel.showUpdate
              ? const Update()
              : dmodel.showMaintenance
                  ? const Maintenance()
                  : const SplashScreen()
          : dmodel.user == null
              ? const Login(
                  isCreate: true,
                )
              : const Dashboard(),
      builder: (context, child) {
        return Index(
          child: child!,
        );
      },
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
        print("app in resumed");
        // reload the data if app was in background for over 30 seconds
        if (_closedTime?.isBefore(
                DateTime.now().subtract(const Duration(seconds: 30))) ??
            false) {
          print("resetting");
          // _resetData(context.read<DataModel>());
          RestartWidget.restartApp(context);
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

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _content(context),
    );
  }

  Widget _content(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          // for showing custom messages
          if (dmodel.currentIndicator != null)
            // if (dmodel.successText != "")
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
          // if (dmodel.errorText != "")
          //   StatusBar(
          //     backgroundColor: Colors.red,
          //     opacity: 0.7,
          //     child: Padding(
          //       padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //       child: Row(
          //         children: [
          //           Expanded(
          //             child: Text(dmodel.errorText,
          //                 textAlign: TextAlign.center,
          //                 style: const TextStyle(
          //                   color: Colors.white,
          //                 )),
          //           ),
          //           const Icon(
          //             Icons.priority_high,
          //             color: Colors.white,
          //           ),
          //         ],
          //       ),
          //     ),
          //     completion: () {
          //       setState(() {
          //         dmodel.errorText = "";
          //       });
          //     },
          //   ),
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
    print("INIT");
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
    print("DISPOSE!");
    controller.dispose();
    super.dispose();
  }

  Future<void> _close() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        controller.reverse();
      });
    } else {
      print("NOT MOUNTED");
    }
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
          child: cv.GlassContainer(
            borderRadius: BorderRadius.circular(25),
            opacity: widget.opacity,
            backgroundColor: widget.backgroundColor,
            height: 50,
            width: MediaQuery.of(context).size.width - 10,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
