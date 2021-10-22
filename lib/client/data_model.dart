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

    prefs.setString("email", "me@jakelanders.com");
    // prefs.remove("teamId");
    // prefs.remove("seasonId");
    // prefs.remove("teamId");

    if (prefs.containsKey('email')) {
      // check if there is a teamId and seasonId to use faster call,
      // or else just use basic pathway to get that information
      if (prefs.containsKey("teamId") && prefs.containsKey("seasonId")) {
        // get tus with fast call
        print("attempting to getall info with fast call");
        await getUserTUS(prefs.getString("email")!, prefs.getString("teamId"),
            prefs.getString("seasonId"), (utus) {
          if (utus.tus != null && utus.schedule != null) {
            print("successfully got fast data");
            // successfully found all information
            user = utus.user;
            tus = utus.tus!;
            // set the color
            if (tus!.team.teamStyle.color != null) {
              color = CustomColors.fromHex(tus!.team.teamStyle.color!);
            }
            Season? tempSeason;
            for (var i in utus.tus!.seasons) {
              if (i.seasonId == prefs.getString("seasonId")) {
                tempSeason = i;
                break;
              }
            }
            if (tempSeason != null) {
              currentSeason = tempSeason;
              setSchedule(utus.schedule!);
              notifyListeners();
            } else {
              // there was an issue with the season data, reget all data (this will not happen often)
              setUser(utus.user);
            }
          } else {
            print(utus.schedule);
            // there was some issues getting the data, use basic pathway
            setUser(utus.user);
          }
        });
      } else {
        // use basic pathway
        await getUser(prefs.getString("email")!, (user) {
          setUser(user);
        });
      }
    } else {
      print("user does not have saved email, going to login");
    }
    showSplash = false;
    notifyListeners();
  }

  // client for api requests
  Client client = Client(client: http.Client());
  bool showUpdate = false;
  bool showSplash = true;
  late SharedPreferences prefs;

  Color color = Colors.blue;

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
        print("user has no saved teams");
        noTeam = true;
        noSeason = true;
        notifyListeners();
      }
    }
  }

  TeamUserSeasons? tus;
  void setTUS(TeamUserSeasons tus) {
    this.tus = tus;
    prefs.setString("teamId", tus.team.teamId);
    print("set tus");
    // set the color
    if (tus.team.teamStyle.color != null) {
      color = CustomColors.fromHex(tus.team.teamStyle.color!);
    }
    if (tus.seasons.isNotEmpty) {
      // check for saved seasonId
      if (prefs.containsKey("seasonId")) {
        for (var i in tus.seasons) {
          if (i.seasonId == prefs.getString("seasonId")) {
            // set the current season with this item
            setCurrentSeason(i);
            break;
          }
        }
      } else {
        setCurrentSeason(tus.seasons.first);
        return;
      }
    } else {
      // there are no seasons
      print("this team has no seasons");
      noSeason = true;
      notifyListeners();
    }
  }

  Season? currentSeason;
  void setCurrentSeason(Season season) {
    currentSeason = season;
    prefs.setString("seasonId", season.seasonId);
    notifyListeners();
    print("set the current season");
    // get the schedule with this season
    scheduleGet(tus!.team.teamId, season.seasonId, user!.email, (schedule) {
      setSchedule(schedule);
    });
  }

  bool noTeam = false;
  bool noSeason = false;

  Schedule? schedule;
  void setSchedule(Schedule schedule) {
    this.schedule = schedule;
    print("set schedule");
    notifyListeners();
    // get the season users
    getSeasonRoster(tus!.team.teamId, currentSeason!.seasonId, (seasonUsers) {
      setSeasonUsers(seasonUsers);
    });
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
  }
}
