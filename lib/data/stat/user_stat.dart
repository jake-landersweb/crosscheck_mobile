import 'package:equatable/equatable.dart';
import 'package:crosscheck_sports/data/root.dart';
import '../../extras/root.dart';

class UserStat extends Equatable {
  late String id;
  late String sortKey;
  late String email;
  late List<StatObject> stats;
  String? seasonId;
  String? eventId;
  String? firstName;
  String? lastName;
  String? nickname;
  String? title;

  UserStat({
    required this.id,
    required this.sortKey,
    required this.email,
    required this.stats,
    this.seasonId,
    this.eventId,
    this.firstName,
    this.lastName,
    this.title,
    this.nickname,
  });

  UserStat clone() => UserStat(
        id: id,
        sortKey: sortKey,
        email: email,
        stats: [for (var i in stats) i.clone()],
        seasonId: seasonId,
        eventId: eventId,
        firstName: firstName,
        lastName: lastName,
        title: title,
        nickname: nickname,
      );

  UserStat.fromJson(dynamic json) {
    id = json['id'];
    sortKey = json['sortKey'];
    email = json['email'];
    stats = [];
    for (var i in json['stats']) {
      stats.add(StatObject.fromJson(i));
    }
    seasonId = json['seasonId'];
    eventId = json['eventId'];
    firstName = json['firstName'];
    lastName = json['lastName'];
    title = json['title'];
    nickname = json['nickname'];
  }

  String getName(Team team) {
    if (team.showNicknames && nickname.isNotEmpty()) {
      return nickname!;
    } else {
      if (firstName?.isNotEmpty ?? false) {
        if (lastName?.isNotEmpty ?? false) {
          return "$firstName $lastName";
        } else {
          return firstName!;
        }
      } else {
        return email;
      }
    }
  }

  @override
  List<Object?> get props => [id, sortKey, email];
}
