import 'package:equatable/equatable.dart';

import 'root.dart';
import '../../extras/root.dart';

class SeasonUser extends Equatable {
  late String email;
  SeasonUserUserFields? userFields;
  SeasonUserTeamFields? teamFields;
  SeasonUserSeasonFields? seasonFields;
  SeasonUserEventFields? eventFields;
  SUPollFields? pollFields;

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
    if (user.pollFields != null) {
      pollFields = user.pollFields!.clone();
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
    if (json['pollFields'] != null) {
      pollFields = SUPollFields.fromJson(json['pollFields']);
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
    data['pollFields'] = pollFields;
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
    if (user.pollFields != null) {
      pollFields = user.pollFields!.clone();
    }
  }

  // for team user name
  String name(bool showNicknames) {
    if (showNicknames) {
      if (userFields?.nickname.isNotEmpty() ?? false) {
        return userFields!.nickname!;
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
      } else if ((seasonFields?.seasonUserType ?? 1) > 1) {
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

List<SeasonUser> sortSeasonUsers(List<SeasonUser> users,
    {required bool showNicknames}) {
  users.sort((a, b) {
    String sort1 = a.email;
    String sort2 = b.email;
    if (a.userFields == null) {
      return -1;
    }
    if (b.userFields == null) {
      return 1;
    }
    if ((a.userFields!.nickname?.isNotEmpty ?? false) && showNicknames) {
      sort1 = a.userFields!.nickname!;
    } else if (a.userFields!.firstName?.isNotEmpty ?? false) {
      sort1 = a.userFields!.firstName!;
    }
    if ((b.userFields!.nickname?.isNotEmpty ?? false) && showNicknames) {
      sort2 = b.userFields!.nickname!;
    } else if (b.userFields?.firstName?.isNotEmpty ?? false) {
      sort2 = b.userFields!.firstName!;
    }
    return sort1.compareTo(sort2);
  });
  return users;
}
