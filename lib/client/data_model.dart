// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

class DataModel extends ChangeNotifier {
  // constructor init
  DataModel() {
    init();
  }
  init() async {
    print("init");
    // load chached data
    prefs = await SharedPreferences.getInstance();
    // logout();
    // prefs.setString("seasonId", "Sab1280d9d47a42c5a33ce6f0e379957d");
    if (prefs.containsKey('email')) {
      print("has saved email");

      // get the user
      getUser(
        prefs.getString('email')!,
        (user) {
          showSplash = false;
          notifyListeners();
          setUser(user);
        },
      );
    } else {
      loadingStatus = LoadingStatus.success;
      showSplash = false;
      notifyListeners();
    }
  }

  bool showSplash = true;

  // client for api requests
  Client client = Client(client: http.Client());

  late SharedPreferences prefs;

  LoadingStatus loadingStatus = LoadingStatus.loading;

  User? user;
  void setUser(User user) {
    prefs.setString('email', user.email);
    this.user = user;
    // check if user has a team saved
    if (prefs.containsKey('teamId')) {
      print("user has a saved team id");
      // get tus
      teamUserSeasonsGet(prefs.getString('teamId')!, user.email, (tus) {
        setTus(tus);
      });
    } else if (user.teams.isNotEmpty) {
      print("user has a team in user record, using that to get tus");
      teamUserSeasonsGet(user.teams.first.teamId, user.email, (tus) {
        setTus(tus);
      });
    } else {
      print("user is not part of any teams");
      loadingStatus = LoadingStatus.success;
      notifyListeners();
    }
  }

  TeamUserSeasons? tus;
  Color color = Colors.blue;
  void setTus(TeamUserSeasons tus) {
    prefs.setString('teamId', tus.team.teamId);
    this.tus = tus;
    // set the current season
    if (prefs.containsKey('seasonId')) {
      print('user has a saved seasonId');
      Season? season;
      for (Season i in tus.seasons) {
        if (i.seasonId == prefs.getString('seasonId')) {
          season = i;
          break;
        }
      }
      if (season != null) {
        setSeason(season);
        // set color if applicable
        if (!tus.team.color.isEmpty()) {
          color = CustomColors.fromHex(tus.team.color!);
        }
      } else {
        print("invalid season id, removing from cache and trying again...");
        prefs.remove("seasonId");
        setTus(tus);
      }
    } else if (tus.seasons.isNotEmpty) {
      print('using first season from call to set current season');
      setSeason(tus.seasons.first);
    } else {
      print("there are no seasons for this team");
      loadingStatus = LoadingStatus.success;
      notifyListeners();
    }
  }

  Season? currentSeason;
  void setSeason(Season season) {
    prefs.setString('seasonId', season.seasonId);
    currentSeason = season;

    // get schedule
    scheduleGet(tus!.team.teamId, season.seasonId, user!.email, (schedule) {
      setSchedule(schedule);
    });

    // get the season user
    setCurrentSeasonUser(tus!.user);
    seasonUserGet(tus!.team.teamId, season.seasonId, user!.email, (user) {
      setCurrentSeasonUser(user);
    });
  }

  Schedule? currentSchedule;
  void setSchedule(Schedule schedule) {
    currentSchedule = schedule;
    loadingStatus = LoadingStatus.success;
    notifyListeners();
  }

  SeasonUser? currentSeasonUser;
  void setCurrentSeasonUser(SeasonUser user) {
    currentSeasonUser = user;
    notifyListeners();
  }

  List<SeasonUser>? seasonRoster;
  void setSeasonRoster(List<SeasonUser> users) {
    seasonRoster = users;
    notifyListeners();
  }

  List<SeasonUser>? teamRoster;
  void setTeamRoster(List<SeasonUser> users) {
    teamRoster = users;
    notifyListeners();
  }

  List<CalendarEvent>? calendar;
  void setCalendar(List<CalendarEvent> calendar) {
    this.calendar = calendar;
    notifyListeners();
  }

  // for showing error popup
  String errorText = "";
  void setError(String message, bool? showMessage) {
    print(message);
    loadingStatus = LoadingStatus.error;
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
    currentSchedule = null;
  }
}
