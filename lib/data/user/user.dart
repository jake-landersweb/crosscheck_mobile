// ignore_for_file: file_names, must_be_immutable

import 'package:equatable/equatable.dart';

import 'root.dart';

class User extends Equatable {
  late String email;
  String? firstName;
  String? lastName;
  late List<UserTeam> teams;
  bool? emailNotifications;
  bool? mobileAppNotifications;
  String? mobileDeviceToken;

  User({
    required this.email,
    this.firstName = "",
    this.lastName = "",
    required this.teams,
    this.emailNotifications = true,
    this.mobileAppNotifications = false,
    this.mobileDeviceToken = "",
  });

  // empty object
  User.empty() {
    email = "";
    firstName = "";
    lastName = "";
    teams = [];
    emailNotifications = true;
    mobileAppNotifications = false;
    mobileDeviceToken = "";
  }

  // for creating a copy
  User.of(User user) {
    email = user.email;
    firstName = user.firstName;
    lastName = user.lastName;
    teams = user.teams;
    emailNotifications = user.emailNotifications;
    mobileAppNotifications = user.mobileAppNotifications;
    mobileDeviceToken = user.mobileDeviceToken;
  }

  // converting from json
  static User fromJson(dynamic json) {
    User user = User(
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        teams: UserTeam.fromJson(json['teams']),
        emailNotifications: json['emailNotifications'] ?? true,
        mobileAppNotifications: json['mobileAppNotifications'] ?? false,
        mobileDeviceToken: json['mobileDeviceToken'] ?? "");
    return user;
  }

  // converting to json
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'teams': teams,
      'emailNotifications': emailNotifications,
      "mobileAppNotifications": mobileAppNotifications,
      "mobileDeviceToken": mobileDeviceToken,
    };
  }

  // values to compare
  @override
  List<Object> get props => [email];
}
