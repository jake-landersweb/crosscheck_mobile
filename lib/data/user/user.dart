// ignore_for_file: file_names, must_be_immutable

import 'package:crosscheck_sports/data/user/notif_alert.dart';
import 'package:equatable/equatable.dart';

import 'root.dart';

class User extends Equatable {
  late String email;
  String? firstName;
  String? lastName;
  late String nickname;
  late String phone;
  late String created;
  late List<UserTeam> teams;
  bool? emailNotifications;
  late List<MobileNotification> mobileNotifications;
  late List<NotificationAlert> notifications;

  User({
    required this.email,
    this.firstName = "",
    this.lastName = "",
    required this.teams,
    this.emailNotifications = true,
    this.mobileNotifications = const [],
    required this.phone,
    required this.nickname,
    required this.created,
    required this.notifications,
  });

  // empty object
  User.empty() {
    email = "";
    firstName = "";
    lastName = "";
    teams = [];
    emailNotifications = true;
    mobileNotifications = [];
    phone = "";
    nickname = "";
    created = "";
    notifications = [];
  }

  // for creating a copy
  User clone() => User(
        email: email,
        firstName: firstName,
        lastName: lastName,
        teams: teams,
        emailNotifications: emailNotifications,
        mobileNotifications: [for (var i in mobileNotifications) i.clone()],
        phone: phone,
        nickname: nickname,
        created: created,
        notifications: notifications,
      );

  // converting from json
  User.fromJson(dynamic json) {
    email = json['email'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    teams = UserTeam.fromJson(json['teams']);
    emailNotifications = json['emailNotifications'] ?? true;
    mobileNotifications = [];
    for (var i in json['mobileNotifications']) {
      mobileNotifications.add(MobileNotification.fromJson(i));
    }
    phone = json['phone'] ?? "";
    nickname = json['nickname'] ?? "";
    created = json['created'] ?? "";
    notifications = [];
    for (var i in json['notifications'] ?? []) {
      notifications.add(NotificationAlert.fromJson(i));
    }
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'teams': teams,
      'emailNotifications': emailNotifications,
      "mobileNotifications":
          mobileNotifications.map((v) => v.toJson()).toList(),
      "phone": phone,
      "nickname": nickname,
      "notifications": notifications.map((v) => v.toJson()).toList(),
    };
  }

  String getName() {
    if (firstName?.isNotEmpty ?? false) {
      if (lastName?.isNotEmpty ?? false) {
        return "${firstName!} ${lastName!.substring(0, 1)}.";
      } else {
        return firstName!;
      }
    } else {
      return email;
    }
  }

  List<MobileNotification> getMobileNotifications(String? teamId) {
    return mobileNotifications
        .where((element) => element.teamId == teamId)
        .toList();
  }

  DateTime getCreatedDate() {
    return DateTime.parse(created);
  }

  int getNumMonthsOfAccount() {
    return DateTime.now().difference(getCreatedDate()).inDays;
  }

  // values to compare
  @override
  List<Object> get props => [email];
}
