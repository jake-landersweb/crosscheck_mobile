// ignore_for_file: avoid_print

import 'dart:developer';
import 'dart:io';

import 'package:crosscheck_sports/crosscheck_engine.dart';
import 'package:crosscheck_sports/data/batch_tus.dart';
import 'package:crosscheck_sports/data/season/poll.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

const double appVersionMajor = 4.3;
const int appVersionMinor = 8;

class DataModel extends ChangeNotifier {
  // for holding passed teamId in memory for custom team apps
  TeamArguments? teamArgs;
  FirebaseMessaging? firebaseMessaging;
  String loadText = "";
  bool customAppTeamFan = false;
  DeepLink? deepLink;
  List<Season>? allSeasons;
  bool showPollBadge = false;
  bool showUnreadBadge = false;
  bool isScaled = false;
  // client for api requests
  Client client = Client(client: http.Client());
  bool showUpdate = false;
  bool showMaintenance = false;
  bool showSplash = true;
  bool forceSchedule = false;
  late SharedPreferences prefs;
  Color color = CustomColors.fromHex("7bc5d6");
  bool hasMoreUpcomingEvents = true;
  bool hasMorePreviousEvents = false;
  int upcomingEventsStartIndex = 0;
  int previousEventsStartIndex = 0;
  bool isFetchingEvents = false;
  String currentScheduleTitle = "Upcoming";

  User? user;
  int tusRetryCounter = 0;
  TeamUserSeasons? tus;
  Season? currentSeason;
  List<SeasonUser>? seasonUsers;
  List<Event>? upcomingEvents;
  List<Event>? previousEvents;
  bool isFetchingRestEvents = false;
  SeasonUser? currentSeasonUser;
  int scheduleIndex = 2;
  List<Poll>? polls;

  // when user needs to leave the app without full refresh for a while
  bool blockRefresh = false;

  // code for handling the indicator queue
  List<IndicatorItem> indicators = [];
  IndicatorItem? currentIndicator;
  final double animationTime = 0.8;

  bool noTeam = false;
  bool noSeason = false;

  void setChatBadge(bool val) {
    showUnreadBadge = val;
    notifyListeners();
  }

  void setPollBadge(bool val) {
    showPollBadge = val;
    notifyListeners();
  }

  void setIsScaled(bool val) {
    isScaled = val;
    notifyListeners();
  }

  void toggleScheduleTitle() {
    currentScheduleTitle =
        currentScheduleTitle == "Upcoming" ? "Previous" : "Upcoming";
    notifyListeners();
  }

  // constructor init
  DataModel({this.teamArgs}) {
    if (teamArgs != null) {
      print("passed teamId = ${teamArgs!.teamId}");
    }
    init();
  }
  init() async {
    // log initial information
    await FirebaseAnalytics.instance.logEvent(name: "access_data", parameters: {
      "platform": Platform.isIOS
          ? "ios"
          : Platform.isAndroid
              ? "android"
              : "other",
      "version": "$appVersionMajor.$appVersionMinor",
    });
    // reset all values for when app is reloaded from background
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
    upcomingEventsStartIndex = 0;
    previousEventsStartIndex = 0;
    currentScheduleTitle = "Upcoming";
    setLoadText("");
    print("init");

    // // observe for deep links
    // observeDeepLinks();

    setLoadText("");
    // check the version
    await getVersion(appVersionMajor, appVersionMinor.toDouble(),
        (update, maintenance) {
      if (update) {
        showUpdate = true;
        print("app was told to update from api");
      }
      if (maintenance) {
        showMaintenance = true;
        print("app was told to show maintenance from api");
      }
    }, () {
      showMaintenance = true;
    });

    if (showUpdate || showMaintenance) {
      notifyListeners();
      return;
    }

    // intialize firebase notifications
    firebaseMessaging = FirebaseMessaging.instance;

    // check for links if restarted without one
    if (deepLink == null) {
      // see if there is an initial deep link
      var link = await FirebaseDynamicLinks.instance.getInitialLink();
      print("[LINKS] link from init: $link");
      deepLink = await handleDeepLink(link);

      // see if there is an initial notification
      var notif = await FirebaseMessaging.instance.getInitialMessage();
      print("[NOTIFS] notif from init: $notif");
      deepLink = await handleNotification(notif);
    }

    // load chached data
    prefs = await SharedPreferences.getInstance();

    // logout();

    // prefs.setString("email", "jakerlanders@gmail.com");
    // prefs.remove("email");

    var cont = false;

    setLoadText("Fetching user information ...");
    if (prefs.containsKey("email") &&
        prefs.containsKey("teamId") &&
        prefs.containsKey("seasonId") &&
        deepLink == null) {
      // run a fast login when the user has all three pieces of information
      // and there is no deep link
      showSplash = false;
      forceSchedule = true;
      notifyListeners();
      BatchTUS? batchTUS = await getBatchTUS(
        prefs.getString("email")!,
        prefs.getString("teamId")!,
        prefs.getString("seasonId")!,
      );
      if (batchTUS != null) {
        // successfully got information, populate all fields
        user = batchTUS.user;
        tus = TeamUserSeasons(
          team: batchTUS.team,
          user: batchTUS.teamUser,
          seasons: batchTUS.seasons,
        );
        if (tus!.team.color != "") {
          color = CustomColors.fromHex(tus!.team.color);
        }
        forceSchedule = false;
        setCurrentSeason(tus!.seasons.first);
        await clearNotificationBadges(prefs.getString("email")!);
      } else {
        // let fallback method try
        print("batchTUS failed, trying traditional method");
        // prefs.remove("seasonId");
        cont = true;
      }
    } else {
      print("does not have required information cached for batchTUS");
      cont = true;
    }

    if (cont) {
      if (prefs.containsKey('email')) {
        // run through basic user information

        await getUser(prefs.getString("email")!, (user) {
          setUser(user);
        }, onError: () {
          // user account may be corrupted, go to login
          prefs.remove("email");
          showSplash = false;
          notifyListeners();
        });
      } else {
        if (teamArgs != null) {
          print("user is a fan, taking them to the main dashboard");
          // still need to get team information, do basic get and fill in the gaps
          await teamGet(teamArgs!.teamId, (p0) {
            TeamUserSeasons tus = TeamUserSeasons(
              team: p0,
              seasons: [],
              user: SeasonUserTeamFields.empty(),
            );
            setTUS(tus);
          });
          customAppTeamFan = true;
          showSplash = false;
          noTeam = true;
          noSeason = true;
          notifyListeners();
        } else {
          print("user does not have saved email, going to login");
          showSplash = false;
          notifyListeners();
        }
      }
    }
  }

  void setUser(User user, {bool? showLogin}) async {
    // try {

    this.user = user;
    // remove the badge
    await clearNotificationBadges(user.email);

    // log user
    await FirebaseAnalytics.instance.setUserId(id: user.email);

    showSplash = false;
    notifyListeners();
    prefs.setString("email", user.email);
    // if (showLogin ?? true) {
    //   addIndicator(IndicatorItem.success("Logged in as ${user.email}"));
    // }
    print("set user");
    // get the user tus

    setLoadText("Checking for team information ...");
    // check if team app
    if (teamArgs != null) {
      // make sure user is a part of the team
      if (!user.teams.any((element) => element.teamId == teamArgs!.teamId)) {
        addIndicator(IndicatorItem.error("You are not a member of this team."));
        this.user = null;
        prefs.remove("email");
        noTeam = true;
        noSeason = true;
        showSplash = false;
        notifyListeners();
        return;
      } else {
        log("On this team, continuing to TUS");
      }

      // get the tus
      await teamUserSeasonsGet(teamArgs!.teamId, user.email, (tus) {
        setTUS(tus);
        return;
      }, onError: () {
        // error with this team user combo, set error and go to login
        addIndicator(
            IndicatorItem.error("There was an issue with the team and user"));
        this.user = null;
        prefs.remove("email");
        noTeam = true;
        noSeason = true;
        showSplash = false;
        notifyListeners();
      });
      return;
    }

    Future<void> normalPathWay() async {
      if (prefs.containsKey("teamId")) {
        print("user has team id, using that to get tus");
        // get the tus
        await teamUserSeasonsGet(prefs.getString("teamId")!, user.email, (tus) {
          setTUS(tus);
          return;
        }, onError: () {
          // remove preference value then retry with saved team list
          prefs.remove("teamId");
          setUser(user, showLogin: false);
        });
      } else {
        // check the user list for a team
        if (user.teams.isNotEmpty) {
          print("getting tus with first team in team list");
          // fetch tus with first team
          await teamUserSeasonsGet(
              user.teams[tusRetryCounter].teamId, user.email, (tus) {
            setTUS(tus);
            return;
          }, onError: () {
            print(
                "error getting the teams, if there is another team in the user's list, increment and try it. If not, invalidate data.");
            tusRetryCounter += 1;
            if (user.teams.length > tusRetryCounter) {
              print(
                  "Attempting to get team with teamId: ${user.teams[tusRetryCounter].teamId}");
              setUser(user, showLogin: false);
            } else {
              print("no valid teams were found, invalidating data");
              prefs.remove("teamId");
              prefs.remove("seasonId");
              // noTeam = true;
              noSeason = true;
              noTeam = true;
              showSplash = false;
              notifyListeners();
            }
          });
        } else {
          // user has no teams
          print("user has no valid teams");
          noTeam = true;
          noSeason = true;
          showSplash = false;
          notifyListeners();
        }
      }
    }

    // for default app
    if (deepLink != null && deepLink!.args.isNotEmpty) {
      // use the deep link teamId
      await teamUserSeasonsGet(deepLink!.args[0], user.email, (tus) {
        setTUS(tus);
        return;
      }, onError: () async {
        print(
            "[DEEP LINK] There was an issue getting team user seasons with deep link");
        // remove the deep link and try again
        deepLink = null;
        await normalPathWay();
      });
    } else {
      await normalPathWay();
    }
  }

  void setTUS(TeamUserSeasons tus) {
    // try {
    this.tus = tus;
    prefs.setString("teamId", tus.team.teamId);
    print("set tus");
    noTeam = false;
    // set the color
    if (tus.team.color != "") {
      color = CustomColors.fromHex(tus.team.color);
    }
    if (tus.seasons.isNotEmpty) {
      // see if deep seasonId works
      if (deepLink != null) {
        Season s = tus.seasons.firstWhere(
            (element) => element.seasonId == deepLink!.args[1], orElse: () {
          // default first season, there was an error
          return tus.seasons.first;
        });
        setCurrentSeason(s);
      } else if (prefs.containsKey("seasonId")) {
        // saved seasonId
        print("has saved seasonId");
        for (var i in tus.seasons) {
          if (i.seasonId == prefs.getString("seasonId")) {
            // set the current season with this item
            setCurrentSeason(i);
            return;
          }
        }
        setCurrentSeason(tus.seasons.first);
        return;
      } else {
        print("no saved seasonId");
        setCurrentSeason(tus.seasons.first);
        return;
      }
    } else {
      // there are no seasons
      print("this team has no seasons");
      noSeason = true;
      showSplash = false;
      notifyListeners();
    }
    // } catch (error) {
    //   print("There was an error: $error");
    //   prefs.remove("teamId");
    //   showSplash = true;
    //   showMaintenance = true;
    //   notifyListeners();
    // }
  }

  Future<void> setCurrentSeason(Season season,
      {bool isPrevious = false}) async {
    try {
      // wipe old event data in case of switching season
      hasMorePreviousEvents = true;
      hasMoreUpcomingEvents = true;
      upcomingEventsStartIndex = 0;
      previousEventsStartIndex = 0;
      if (isPrevious) {
        currentScheduleTitle = "Previous";
      } else {
        currentScheduleTitle = "Upcoming";
      }
      polls = null;
      upcomingEvents = null;
      previousEvents = null;
      currentSeason = season;
      noSeason = false;
      prefs.setString("seasonId", season.seasonId);
      notifyListeners();
      print("set the current season");
      // get the next events
      setLoadText("Grabbing the latest events ...");
      await getPagedEvents(tus!.team.teamId, season.seasonId, user!.email,
          upcomingEventsStartIndex, false, (events) {
        setUpcomingEvents(events);
      }, hasLoads: false);
    } catch (error) {
      print("There was an error: $error");
      prefs.remove("teamId");
      showSplash = true;
      showMaintenance = true;
      notifyListeners();
    }
  }

  void setUpcomingEvents(List<Event> events) {
    upcomingEvents = events;
    showSplash = false;
    notifyListeners();

    setLoadText("Getting the season roster ...");
    // get the season user list
    getBatchSeasonRoster(tus!.team.teamId, currentSeason!.seasonId,
        (seasonUsers) {
      setSeasonUsers(seasonUsers);
    });
  }

  void setPreviousEvents(List<Event> events) {
    previousEvents = events;
    notifyListeners();
  }

  Future<void> getMoreEvents(
      String teamId, String seasonId, String email, bool isPrevious) async {
    getPagedEvents(
        teamId,
        seasonId,
        email,
        isPrevious ? previousEventsStartIndex : upcomingEventsStartIndex,
        isPrevious, (events) {
      if (isPrevious) {
        previousEvents?.addAll(events);
        previousEvents = previousEvents!.distinctBy((e) => e.eventId).toList();
      } else {
        upcomingEvents?.addAll(events);
        upcomingEvents = upcomingEvents!.distinctBy((e) => e.eventId).toList();
      }
    });
    notifyListeners();
  }

  void setPolls(List<Poll> polls) async {
    this.polls = polls;
    notifyListeners();
  }

  Future<void> reloadHomePage(
      String teamId, String seasonId, String email, bool getPrevious) async {
    // get the first 5 events
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
    upcomingEventsStartIndex = 0;
    previousEventsStartIndex = 0;
    currentScheduleTitle = "Upcoming";
    await getPagedEvents(
        teamId, seasonId, email, upcomingEventsStartIndex, false, (events) {
      setUpcomingEvents(events);
    });
    previousEvents = null;
    notifyListeners();
  }

  Future<void> refreshData(String email) async {
    if (deepLink != null) {
      // refresh the entire app
      upcomingEvents = null;
      previousEvents = null;
      currentScheduleTitle = "Upcoming";
      notifyListeners();
      await getUser(email, (p0) => setUser(p0));
    } else {
      // perform casual refresh
      if (currentSeason != null) {
        //
        await reloadHomePage(
          tus!.team.teamId,
          currentSeason!.seasonId,
          email,
          false,
        );
        // refresh the season user list
        await getBatchSeasonRoster(
          tus!.team.teamId,
          currentSeason!.seasonId,
          (p0) => setSeasonUsers(p0),
        );
      } else {
        await getUser(email, (p0) => setUser(p0));
      }
    }
    // upcomingEvents = null;
    // previousEvents = null;
    // currentScheduleTitle = "Upcoming";
    // notifyListeners();
    // await getUser(email, (p0) => setUser(p0));
    // if (currentSeason != null) {
    //   await reloadHomePage(
    //     tus!.team.teamId,
    //     currentSeason!.seasonId,
    //     email,
    //     false,
    //   );
    //   // refresh the season user list
    //   await getSeasonRoster(
    //     tus!.team.teamId,
    //     currentSeason!.seasonId,
    //     (p0) => setSeasonUsers(p0),
    //   );
    // } else {
    //   await getUser(email, (p0) => setUser(p0));
    // }
    // notifyListeners();
  }

  void setSeasonUsers(List<SeasonUser> seasonUsers) async {
    this.seasonUsers = seasonUsers;
    notifyListeners();
    print("set season users");
    for (var i in seasonUsers) {
      if (i.email == user!.email) {
        currentSeasonUser = i;
        getBarNotifications(
          tus!.team.teamId,
          currentSeason!.seasonId,
          i.email,
        );
        print("set current season user");
        notifyListeners();
        break;
      }
    }
    if (prefs.containsKey("${currentSeason!.seasonId}#lastMessageId")) {
      // get unread message count
      int? umsgcnt = await getUnreadMessageCount(
        tus!.team.teamId,
        currentSeason!.seasonId,
        prefs
            .getString("${currentSeason!.seasonId}#lastMessageId")!
            .split("#")
            .last,
      );
      if (umsgcnt != null && umsgcnt > 0) {
        showUnreadBadge = true;
        notifyListeners();
      }
    } else {
      showUnreadBadge = true;
      notifyListeners();
    }
  }

  Future<void> getBarNotifications(
      String teamId, String seasonId, String email) async {
    // get the chat notification badge
    late String lastMessageId;
    var tmp = prefs.getString("$seasonId#lastMessageId");
    if (tmp == null) {
      lastMessageId = "nil";
    } else {
      lastMessageId = tmp.split("#").last;
    }
    int? umsgcnt = await getUnreadMessageCount(
      tus!.team.teamId,
      currentSeason!.seasonId,
      lastMessageId,
    );
    if (umsgcnt != null && umsgcnt > 0) {
      showUnreadBadge = true;
      notifyListeners();
    }

    // get poll notification badge
    await getUnansweredPollCount(teamId, seasonId, email, (p0) {
      if (p0 > 0) {
        showPollBadge = true;
      }
      notifyListeners();
    });
  }

  Future<void> addIndicator(IndicatorItem item) async {
    final SnackBar snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            item.getIcon(),
            color: item.type == IndicatorItemType.error
                ? Colors.red[300]
                : Colors.green[300],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(item.title),
          )
        ],
      ),
      margin: const EdgeInsets.all(8),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
    snackbarKey.currentState?.showSnackBar(snackBar);
    // indicators.add(item);
    // if (indicators.length < 2) {
    //   do {
    //     currentIndicator = indicators[0].clone();
    //     notifyListeners();
    //     var duration =
    //         ((currentIndicator!.duration + (animationTime)) * 1000).toInt();
    //     await Future.delayed(Duration(milliseconds: duration));
    //     log(currentIndicator!.title);
    //     currentIndicator = null;
    //     notifyListeners();
    //     indicators.removeAt(0);
    //   } while (indicators.isNotEmpty);
    // }
  }

  Future<void> logout() async {
    // remove this devices notification token from the user's list
    if (user != null) {
      String token = await getNotificationToken();
      if (token.isNotEmpty) {
        // remove from list and update
        await updateUser(
          user!.email,
          {
            "mobileNotifications": [
              for (var i in user!.mobileNotifications)
                if (i.token != token) i.toJson()
            ]
          },
          () {},
          sendMessages: false,
        );
      }
      await FirebaseAnalytics.instance.logEvent(
        name: "logout",
        parameters: {"platform": "mobile"},
      );
    }
    prefs.remove('email');
    prefs.remove('teamId');
    prefs.remove('seasonId');
    user = null;
    tus = null;
    color = CustomColors.fromHex("7bc5d6");
    currentSeason = null;
    currentSeasonUser = null;
    seasonUsers = null;
    upcomingEvents = null;
    previousEvents = null;
    polls = null;
    previousEventsStartIndex = 0;
    upcomingEventsStartIndex = 0;
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
    currentScheduleTitle = "Upcoming";
    scheduleIndex = 2;
    noSeason = true;
    noTeam = true;
    notifyListeners();
  }

  Future<void> getPagedEvents(
    String teamId,
    String seasonId,
    String email,
    int startIndex,
    bool isPrevious,
    Function(List<Event>) completion, {
    bool hasLoads = true,
  }) async {
    if (hasLoads) {
      isFetchingEvents = true;
      notifyListeners();
    }
    await getPagedEventsHelper(teamId, seasonId, email, startIndex, isPrevious,
        (events) => completion(events));
    if (hasLoads) {
      isFetchingEvents = false;
      notifyListeners();
    }
  }

  Future<String> getNotificationToken() async {
    // await Firebase.initializeApp();
    firebaseMessaging = FirebaseMessaging.instance;
    if (firebaseMessaging != null) {
      NotificationSettings settings =
          await firebaseMessaging!.requestPermission(
        alert: true,
        badge: true,
        provisional: false,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        var token = await firebaseMessaging!.getToken();
        if (token != null) {
          log("successfully got notification token");
          return token;
        } else {
          log("there was an issue with firebase notification request");
          return "";
        }
      } else {
        log("the user did not authorize notifications");
        return "";
      }
    } else {
      log("firebase is null");
      return "";
    }
  }

  Future<void> clearNotificationBadges(String email) async {
    var token = await getNotificationToken();
    if (token != "") {
      // get device info
      Map<String, dynamic> body = await getDeviceInfo();
      body['token'] = token;
      if (teamArgs != null) {
        body['teamId'] = teamArgs!.teamId;
      }
      await updateUserNotifications(email, body, (p0) {
        // update user preferences
        log("successfully removed badges from app");
        FlutterAppBadger.updateBadgeCount(0);
        if (user != null) {
          user!.mobileNotifications = p0.mobileNotifications;
        }
        notifyListeners();
      });
    } else {
      log("There was an issue getting the notification token");
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    Map<String, dynamic> body = {};
    if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      body['deviceType'] = "ios";
      body['deviceName'] = iosInfo.name ?? "";
      body['deviceVersion'] = iosInfo.systemVersion ?? "";
    } else {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      body['deviceType'] = "android";
      body['deviceName'] = androidInfo.model;
      body['deviceVersion'] = androidInfo.version.release;
    }
    body['badge'] = 0;
    return body;
  }

  void setLoadText(String val) {
    print("[LOAD TEXT] $val");
  }

  // running in background as observer to detect the app being opened with any deep links
  void observeDeepLinks() {
    // listen for notifications
    FirebaseMessaging.onMessageOpenedApp.listen(((event) async {
      var deepLink = await handleNotification(event);
      if (deepLink != null) {
        this.deepLink = deepLink;
        print("[NOTIFICATIONS] from background: $deepLink");
      }
    }));
    // listen for deep links
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
      var deepLink = await handleDeepLink(dynamicLinkData);
      if (deepLink != null) {
        this.deepLink = deepLink;
        print("[DEEP LINK] from background: $deepLink");
      }
    }).onError((error) {
      // Handle errors
      print("[DEEP LINKS] [ERROR] handling background deep link: $error");
    });
  }

  void setScheduleIndex(int index) async {
    scheduleIndex = index;
    notifyListeners();
    // log page view in analytics
    String name = "";
    switch (index) {
      case 0:
        name = "schedule";
        break;
      case 1:
        name = "chat";
        break;
      case 2:
        name = "stats";
        break;
      case 3:
        name = "season_roster";
        break;
      default:
        name = "unknown";
        break;
    }
    FirebaseAnalytics.instance.setCurrentScreen(screenName: name);
  }

  bool updateEventData(Event newEvent) {
    if (upcomingEvents == null) {
      print("The upcoming events list is null");
      return false;
    } else {
      for (int i = 0; i < upcomingEvents!.length; i++) {
        if (upcomingEvents![i].eventId == newEvent.eventId) {
          // check if new date is now in past
          if (newEvent.eventDate().compareTo(DateTime.now()) == -1) {
            // remove upcoming event
            upcomingEvents!.removeAt(i);
            // make sure list is not null
            if (previousEvents != null) {
              // add updated event to previous
              previousEvents!.add(newEvent);
              // sort previous events on date
              previousEvents!.sort((a, b) => b.eDate.compareTo(a.eDate));
            }
          } else {
            // set upcoming event
            upcomingEvents![i] = newEvent;
          }
          notifyListeners();
          return true;
        }
      }
    }
    if (previousEvents == null) {
      print("The previous events list is null");
      return false;
    } else {
      for (int i = 0; i < previousEvents!.length; i++) {
        if (previousEvents![i].eventId == newEvent.eventId) {
          // check if new date is now in future
          if (newEvent.eventDate().compareTo(DateTime.now()) == 1) {
            // remove previous event
            previousEvents!.removeAt(i);
            // add updated event to upcoming
            upcomingEvents!.add(newEvent);
            // sort upcoming events on date
            upcomingEvents!.sort((a, b) => a.eDate.compareTo(b.eDate));
          } else {
            // set previous event
            previousEvents![i] = newEvent;
          }
          notifyListeners();
          return true;
        }
      }
    }
    return false;
  }
}

const double cellHeight = 45;

Future<DeepLink?> handleDeepLink(PendingDynamicLinkData? data) async {
  if (data == null) {
    return null;
  } else {
    final queryParams = data.link.queryParameters;
    print("[DEEP LINK] link: ${data.link}");
    if (queryParams.containsKey("params") && queryParams.containsKey("type")) {
      print("[DEEP LINK] query params : $queryParams");
      String type = queryParams['type']!;
      List<String> args = queryParams['params']!.split(",");
      try {
        DeepLink deepLink = DeepLink(type: type, args: args);
        FirebaseAnalytics.instance.logEvent(name: "deep_link");
        return deepLink;
      } catch (error, stacktrace) {
        print(
            "[DEEP LINK] there was an issue converting deep link into solid type: $error $stacktrace");
        return null;
      }
    } else {
      print("[DEEP LINK] does not contain query params or type: $queryParams");
      return null;
    }
  }
}

Future<DeepLink?> handleNotification(RemoteMessage? message) async {
  if (message == null) {
    print("[NOTIFICATIONS] there was no message sent");
    return null;
  } else {
    final queryParams = message.data;
    if (queryParams.containsKey("params") && queryParams.containsKey("type")) {
      print("[NOTIFICATIONS] query params : $queryParams");
      String type = queryParams['type']!;
      List<String> args = queryParams['params']!.split(",");
      try {
        DeepLink deepLink = DeepLink(type: type, args: args);
        FirebaseAnalytics.instance.logEvent(name: "deep_notif");
        return deepLink;
      } catch (error, stacktrace) {
        print(
            "[NOTIFICATIONS] there was an issue converting deep link into solid type: $error $stacktrace");
        return null;
      }
    } else {
      print(
          "[NOTIFICATIONS] does not contain query params or type: $queryParams");
      return null;
    }
  }
}

void logCurrentScreen(String currentScreen) async {
  await FirebaseAnalytics.instance.setCurrentScreen(screenName: currentScreen);
}
