import 'package:equatable/equatable.dart';

import 'root.dart';
import '../../extras/root.dart';

class SeasonUser extends Equatable {
  late String email;
  SeasonUserUserFields? userFields;
  SeasonUserTeamFields? teamFields;
  SeasonUserSeasonFields? seasonFields;
  SeasonUserEventFields? eventFields;

  SeasonUser({
    required this.email,
    this.userFields,
    this.teamFields,
    this.seasonFields,
    this.eventFields,
  });

  // empty object
  SeasonUser.empty() {
    email = "";
    userFields = SeasonUserUserFields.empty();
    teamFields = SeasonUserTeamFields.empty();
    seasonFields = SeasonUserSeasonFields.empty();
    eventFields = SeasonUserEventFields.empty();
  }

  // for creating a copy
  SeasonUser.of(SeasonUser user) {
    email = user.email;
    if (user.userFields != null) {
      userFields = SeasonUserUserFields.of(user.userFields!);
    }
    if (user.teamFields != null) {
      teamFields = SeasonUserTeamFields.of(user.teamFields!);
    }
    if (user.seasonFields != null) {
      seasonFields = SeasonUserSeasonFields.of(user.seasonFields!);
    }
    if (user.eventFields != null) {
      eventFields = SeasonUserEventFields.of(user.eventFields!);
    }
  }

  SeasonUser.fromTeamUser(String email, SeasonUserTeamFields teamUser) {
    email = email;
    teamFields = SeasonUserTeamFields.of(teamUser);
  }

  // json to object
  SeasonUser.fromJson(dynamic json) {
    email = json['email'];
    if (json['userFields'] != null) {
      userFields = SeasonUserUserFields.fromJson(json['userFields']);
    }
    if (json['teamFields'] != null) {
      teamFields = SeasonUserTeamFields.fromJson(json['teamFields']);
    }
    if (json['seasonFields'] != null) {
      seasonFields = SeasonUserSeasonFields.fromJson(json['seasonFields']);
    }
    if (json['eventFields'] != null) {
      eventFields = SeasonUserEventFields.fromJson(json['eventFields']);
    }
  }

  // object to json
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['userFields'] = userFields;
    data['teamFields'] = teamFields;
    data['seasonFields'] = seasonFields;
    data['eventFields'] = eventFields;
    return data;
  }

  void updateEventFields(SeasonUserEventFields fields) {
    eventFields = SeasonUserEventFields.of(fields);
  }

  // for creating a copy
  void set(SeasonUser user) {
    email = user.email;
    if (user.userFields != null) {
      userFields = SeasonUserUserFields.of(user.userFields!);
    }
    if (user.teamFields != null) {
      teamFields = SeasonUserTeamFields.of(user.teamFields!);
    }
    if (user.seasonFields != null) {
      seasonFields = SeasonUserSeasonFields.of(user.seasonFields!);
    }
    if (user.eventFields != null) {
      eventFields = SeasonUserEventFields.of(user.eventFields!);
    }
  }

  // for team user name
  String name(bool showNicknames) {
    if (showNicknames) {
      if (teamFields?.nickname != "") {
        return teamFields!.nickname;
      } else {
        if (userFields == null) {
          return email;
        } else if (userFields!.firstName.isEmpty()) {
          return email;
        } else if (userFields!.lastName.isEmpty()) {
          return userFields!.firstName!;
        } else {
          return "${userFields!.firstName} ${userFields!.lastName}";
        }
      }
    } else {
      if (userFields == null) {
        return email;
      } else if (userFields!.firstName.isEmpty()) {
        return email;
      } else if (userFields!.lastName.isEmpty()) {
        return userFields!.firstName!;
      } else {
        return "${userFields!.firstName} ${userFields!.lastName}";
      }
    }
  }

  // checking if admin on a season or team owner
  bool isSeasonAdmin() {
    if (seasonFields?.isManager ?? false) {
      return true;
    } else {
      if (isTeamAdmin()) {
        return true;
      } else if ((seasonFields!.seasonUserType ?? 1) > 1) {
        return true;
      } else {
        return false;
      }
    }
  }

  // for checking if user is a team admin
  bool isTeamAdmin() {
    if ((teamFields?.teamUserType ?? 1) > 1) {
      return true;
    } else {
      return false;
    }
  }

  String teamUserType() {
    if (teamFields == null) {
      return "";
    } else {
      switch (teamFields!.teamUserType) {
        case 1:
          return "Player";
        case 2:
          return "Admin";
        case 3:
          return "Owner";
        case 0:
          return "Recruit";
        case -1:
          return "Inactive";
        default:
          return "Unknown";
      }
    }
  }

  String seasonUserStatus(int status) {
    switch (status) {
      case 1:
        return "Active";
      case -1:
        return "Inactive";
      default:
        return "Unknown";
    }
  }

  String getPosition(int status) {
    switch (status) {
      case 0:
        return "Forward";
      case 1:
        return "Defense";
      case 2:
        return "Goalie";
      default:
        return "Unknown";
    }
  }

  String getTeamUserNote() {
    if (teamFields?.teamUserNote == null) {
      return "";
    } else {
      return teamFields!.teamUserNote!;
    }
  }

  bool isPlayingSeason() {
    if (seasonFields?.isPlaying == null) {
      return false;
    } else {
      return seasonFields!.isPlaying;
    }
  }

  @override
  String toString() {
    Map<String, dynamic> body = {
      "email": email,
      "userFields": userFields?.toJson(),
      "teamFields": teamFields?.toJson(),
      "seasonFields": seasonFields?.toJson(),
      "eventFields": eventFields?.toJson(),
    };
    return body.toString();
  }

  // values to compare
  @override
  List<Object> get props => [email];
}
