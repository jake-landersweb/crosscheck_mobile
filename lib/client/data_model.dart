// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

double appVersion = 1.3;

class DataModel extends ChangeNotifier {
  // constructor init
  DataModel() {
    init();
  }
  init() async {
    print("init");

    // check the version
    double currentVersion = await getVersion();
    if (currentVersion > appVersion) {
      print("app version is lower than api version");
      showUpdate = true;
      notifyListeners();
      return;
    }

    // load chached data
    prefs = await SharedPreferences.getInstance();

    // prefs.setString("email", "me@jakelanders.com");
    // prefs.remove("teamId");
    // prefs.remove("seasonId");
    // prefs.remove("teamId");

    if (prefs.containsKey('email')) {
      // check if there is a teamId and seasonId to use faster call,
      // or else just use basic pathway to get that information

      // TODO -- fix this call to use the faster new method. for now, using basic pathway
      // use basic pathway
      await getUser(prefs.getString("email")!, (user) {
        setUser(user);
      });
    } else {
      print("user does not have saved email, going to login");
      showSplash = false;
      notifyListeners();
    }
  }

  // client for api requests
  Client client = Client(client: http.Client());
  bool showUpdate = false;
  bool showSplash = true;
  late SharedPreferences prefs;

  Color color = CustomColors.fromHex("00a1ff");
  Color accentColor = CustomColors.fromHex("00a1ff");

  bool hasMoreUpcomingEvents = true;
  bool hasMorePreviousEvents = false;
  int upcomingEventsStartIndex = 0;
  int previousEventsStartIndex = 0;

  bool isFetchingEvents = false;

  User? user;
  void setUser(User user) async {
    this.user = user;
    showSplash = false;
    notifyListeners();
    prefs.setString("email", user.email);
    setSuccess("Logged in as ${user.email}", true);
    print("set user");
    // get the user tus
    if (prefs.containsKey("teamId")) {
      print("user has team id, using that to get tus");
      // get the tus
      await teamUserSeasonsGet(prefs.getString("teamId")!, user.email, (tus) {
        setTUS(tus);
        return;
      });
    } else {
      // check the user list for a team
      if (user.teams.isNotEmpty) {
        print("getting tus with first team in team list");
        // fetch tus with first team
        await teamUserSeasonsGet(user.teams.first.teamId, user.email, (tus) {
          setTUS(tus);
          return;
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

  TeamUserSeasons? tus;
  void setTUS(TeamUserSeasons tus) {
    this.tus = tus;
    prefs.setString("teamId", tus.team.teamId);
    print("set tus");
    noTeam = false;
    // set the color
    if (tus.team.color != "") {
      color = CustomColors.fromHex(tus.team.color);
    }
    if (tus.seasons.isNotEmpty) {
      // check for saved seasonId
      if (prefs.containsKey("seasonId")) {
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
  }

  Season? currentSeason;
  void setCurrentSeason(Season season) {
    currentSeason = season;
    prefs.setString("seasonId", season.seasonId);
    notifyListeners();
    print("set the current season");
    // get the next events
    getPagedEvents(tus!.team.teamId, season.seasonId, user!.email,
        upcomingEventsStartIndex, false, (events) {
      setUpcomingEvents(events);
    }, hasLoads: false);
  }

  bool noTeam = false;
  bool noSeason = false;

  List<Event>? upcomingEvents;
  void setUpcomingEvents(List<Event> events) {
    upcomingEvents = events;
    showSplash = false;
    notifyListeners();

    // get the season user list
    getSeasonRoster(tus!.team.teamId, currentSeason!.seasonId, (seasonUsers) {
      setSeasonUsers(seasonUsers);
    });
  }

  List<Event>? previousEvents;
  void setPreviousEvents(List<Event> events) {
    previousEvents = events;
    notifyListeners();
  }

  bool isFetchingRestEvents = false;

  Future<void> getMoreEvents(
      String teamId, String seasonId, String email, bool isPrevious) async {
    getPagedEvents(
        teamId,
        seasonId,
        email,
        isPrevious ? previousEventsStartIndex : upcomingEventsStartIndex,
        isPrevious, (events) {
      if (isPrevious) {
        setPreviousEvents(events);
      } else {
        setUpcomingEvents(events);
      }
    });
    notifyListeners();
  }

  Future<void> reloadHomePage(
      String teamId, String seasonId, String email, bool getPrevious) async {
    // get the first 5 events
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
    upcomingEventsStartIndex = 0;
    previousEventsStartIndex = 0;
    await getPagedEvents(
        teamId, seasonId, email, upcomingEventsStartIndex, false, (events) {
      setUpcomingEvents(events);
    });
    if (previousEvents != null && getPrevious) {
      await getPagedEvents(
          teamId, seasonId, email, previousEventsStartIndex, true, (events) {
        setPreviousEvents(events);
      });
    }
  }

  List<SeasonUser>? seasonUsers;
  void setSeasonUsers(List<SeasonUser> seasonUsers) {
    this.seasonUsers = seasonUsers;
    notifyListeners();
    print("set season users");
    for (var i in seasonUsers) {
      if (i.email == user!.email) {
        currentSeasonUser = i;
        print("set current season user");
        notifyListeners();
        return;
      }
    }
  }

  SeasonUser? currentSeasonUser;

  // for showing error popup
  String errorText = "";
  void setError(String message, bool? showMessage) {
    print(message);
    if (showMessage ?? true) {
      errorText = message;
      notifyListeners();
    }
  }

  // for showing success message popup
  String successText = "";
  void setSuccess(String message, bool? showMessage) {
    print(message);
    if (showMessage ?? true) {
      successText = message;
      notifyListeners();
    }
  }

  void logout() {
    prefs.remove('email');
    prefs.remove('teamId');
    prefs.remove('seasonId');
    user = null;
    tus = null;
    currentSeason = null;
    currentSeasonUser = null;
    seasonUsers = null;
    upcomingEvents = null;
    previousEvents = null;
    previousEventsStartIndex = 0;
    upcomingEventsStartIndex = 0;
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
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
}

const double cellHeight = 45;
