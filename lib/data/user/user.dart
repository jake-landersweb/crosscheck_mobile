// ignore_for_file: file_names, must_be_immutable

import 'package:equatable/equatable.dart';

import 'root.dart';

class User extends Equatable {
  late String email;
  String? firstName;
  String? lastName;
  late String nickname;
  late String phone;
  late List<UserTeam> teams;
  bool? emailNotifications;
  late List<MobileNotifications> mobileNotifications;

  User({
    required this.email,
    this.firstName = "",
    this.lastName = "",
    required this.teams,
    this.emailNotifications = true,
    this.mobileNotifications = const [],
    required this.phone,
    required this.nickname,
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
  }

  // for creating a copy
  User.of(User user) {
    email = user.email;
    firstName = user.firstName;
    lastName = user.lastName;
    teams = user.teams;
    emailNotifications = user.emailNotifications;
    mobileNotifications = user.mobileNotifications;
    phone = user.phone;
    nickname = user.nickname;
  }

  // converting from json
  static User fromJson(dynamic json) {
    User user = User(
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      teams: UserTeam.fromJson(json['teams']),
      emailNotifications: json['emailNotifications'] ?? true,
      mobileNotifications:
          MobileNotifications.fromJson(json['mobileNotifications']),
      phone: json['phone'] ?? "",
      nickname: json['nickname'] ?? "",
    );
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
      "mobileNotifications":
          mobileNotifications.map((v) => v.toJson()).toList(),
      "phone": phone,
      "nickname": nickname,
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

  // values to compare
  @override
  List<Object> get props => [email];
}
