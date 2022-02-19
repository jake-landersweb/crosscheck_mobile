// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';
import 'package:graphql/client.dart';

const double appVersion = 2.0;

class DataModel extends ChangeNotifier {
  // constructor init
  DataModel() {
    init();
  }
  init() async {
    // return;
    // reset all values for when app is reloaded from background
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
    upcomingEventsStartIndex = 0;
    previousEventsStartIndex = 0;
    currentScheduleTitle = "Upcoming";
    print("init");

    // check the version
    await getVersion((version, hasMaintenence) {
      if (version > appVersion) {
        print("app version is lower than api version");
        showUpdate = true;
        notifyListeners();
      }
      if (hasMaintenence) {
        showMaintenance = true;
        notifyListeners();
      }
      print("app versions match and no maintenance found");
    });

    if (showUpdate || showMaintenance) {
      return;
    }

    // load chached data
    prefs = await SharedPreferences.getInstance();

    // logout();

    if (prefs.containsKey('email')) {
      // check if there is a teamId and seasonId to use faster call,
      // or else just use basic pathway to get that information

      // TODO -- fix this call to use the faster new method. for now, using basic pathway
      // use basic pathway
      try {
        await getUser(prefs.getString("email")!, (user) {
          setUser(user);
        });
      } catch (error) {
        print("There was an error: $error");
        prefs.remove("teamId");
        showSplash = true;
        showMaintenance = true;
        notifyListeners();
      }
    } else {
      print("user does not have saved email, going to login");
      showSplash = false;
      notifyListeners();
    }
  }

  // client for api requests
  Client client = Client(client: http.Client());
  bool showUpdate = false;
  bool showMaintenance = false;
  bool showSplash = true;
  late SharedPreferences prefs;

  Color color = CustomColors.fromHex("7bc5d6");

  bool hasMoreUpcomingEvents = true;
  bool hasMorePreviousEvents = false;
  int upcomingEventsStartIndex = 0;
  int previousEventsStartIndex = 0;

  bool isFetchingEvents = false;

  String currentScheduleTitle = "Upcoming";

  User? user;
  void setUser(User user) async {
    // try {
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
    // } catch (error) {
    //   print("There was an error: $error");
    //   prefs.remove("teamId");
    //   showSplash = true;
    //   showMaintenance = true;
    //   notifyListeners();
    // }
  }

  TeamUserSeasons? tus;
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
    // } catch (error) {
    //   print("There was an error: $error");
    //   prefs.remove("teamId");
    //   showSplash = true;
    //   showMaintenance = true;
    //   notifyListeners();
    // }
  }

  Season? currentSeason;
  void setCurrentSeason(Season season) {
    try {
      // wipe old event data in case of switching season
      hasMorePreviousEvents = true;
      hasMoreUpcomingEvents = true;
      upcomingEventsStartIndex = 0;
      previousEventsStartIndex = 0;
      currentScheduleTitle = "Upcoming";
      upcomingEvents = null;
      previousEvents = null;
      currentSeason = season;
      noSeason = false;
      prefs.setString("seasonId", season.seasonId);
      notifyListeners();
      print("set the current season");
      // get the next events
      getPagedEvents(tus!.team.teamId, season.seasonId, user!.email,
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

  bool noTeam = false;
  bool noSeason = false;

  List<Event>? upcomingEvents;
  void setUpcomingEvents(List<Event> events) {
    upcomingEvents = events;
    showSplash = false;
    notifyListeners();

    print(events.map((e) => e.eTitle));

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
        previousEvents?.addAll(events);
      } else {
        upcomingEvents?.addAll(events);
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
    currentScheduleTitle = "Upcoming";
    await getPagedEvents(
        teamId, seasonId, email, upcomingEventsStartIndex, false, (events) {
      setUpcomingEvents(events);
    });
    previousEvents = null;
    notifyListeners();
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
  Future<void> setError(String message, bool? showMessage) async {
    print(message);
    if (showMessage ?? true) {
      errorText = message;
      notifyListeners();
    }
  }

  // for showing success message popup
  String successText = "";
  Future<void> setSuccess(String message, bool? showMessage) async {
    print(message);
    if (showMessage ?? true) {
      print("SHOW!");
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
    color = CustomColors.fromHex("7bc5d6");
    currentSeason = null;
    currentSeasonUser = null;
    seasonUsers = null;
    upcomingEvents = null;
    previousEvents = null;
    previousEventsStartIndex = 0;
    upcomingEventsStartIndex = 0;
    hasMorePreviousEvents = true;
    hasMoreUpcomingEvents = true;
    currentScheduleTitle = "Upcoming";
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
