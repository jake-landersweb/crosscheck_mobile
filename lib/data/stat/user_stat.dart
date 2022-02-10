import 'package:equatable/equatable.dart';
import 'package:pnflutter/data/root.dart';

class UserStat extends Equatable {
  late String id;
  late String sortKey;
  late String email;
  late List<StatObject> stats;
  String? seasonId;
  String? eventId;
  String? firstName;
  String? lastName;
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
  }

  String getName() {
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

  @override
  List<Object?> get props => [id, sortKey, email];
}
