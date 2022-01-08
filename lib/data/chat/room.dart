import 'package:equatable/equatable.dart';

class Room extends Equatable {
  late String id;
  late String sortKey;
  late String roomId;
  late String title;
  late String created;

  Room({
    required this.id,
    required this.sortKey,
    required this.roomId,
    required this.title,
    required this.created,
  });

  Room clone() => Room(
        id: id,
        sortKey: sortKey,
        roomId: roomId,
        title: title,
        created: created,
      );

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sortKey": sortKey,
      "title": title,
    };
  }

  Room.fromJson(dynamic json) {
    id = json['id'];
    sortKey = json['sortKey'];
    roomId = json['roomId'];
    title = json['title'];
    created = json['created'];
  }

  @override
  List<Object?> get props => [id, sortKey, roomId];
}
