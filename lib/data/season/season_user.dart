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

  void updateEventFields() {
    // TODO - implement
  }

  // for team user name
  String teamName() {
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

  // for painting the correct seasonName
  String seasonName() {
    if (seasonFields == null) {
      return teamName();
    } else if (seasonFields!.nickName.isEmpty()) {
      return teamName();
    } else {
      return seasonFields!.nickName!;
    }
  }

  // checking if admin on a season or team owner
  bool isSeasonAdmin() {
    if ((teamFields?.teamUserType ?? 1) > 2) {
      return true;
    } else if ((seasonFields!.seasonUserType ?? 1) > 1) {
      return true;
    } else {
      return false;
    }
  }

  // for checking if user is a team admin
  bool isTeamAdmin() {
    if ((teamFields?.teamUserType ?? 1) > 2) {
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
        default:
          return "Innactive";
      }
    }
  }

  String seasonUserType() {
    if (seasonFields == null) {
      return "";
    } else {
      switch (seasonFields!.seasonUserType) {
        case 1:
          return "Player";
        case 2:
          return "Manager";
        case 0:
          return "Recruit";
        default:
          return "Innactive";
      }
    }
  }

  String seasonUserStatus() {
    if (seasonFields == null) {
      return "";
    } else {
      switch (seasonFields!.userStatus) {
        case 1:
          return "Active";
        case -1:
          return "Innactive";
        default:
          return "Unknown";
      }
    }
  }

  // values to compare
  @override
  List<Object> get props => [email];
}
