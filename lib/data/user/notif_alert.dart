import 'package:uuid/uuid.dart';

class NotificationAlert {
  late String id;
  late String title;
  late String body;
  late String type;
  late String params;
  String? image;
  String? teamId;

  NotificationAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.params,
    this.image,
    this.teamId,
  });

  NotificationAlert clone() => NotificationAlert(
        id: id,
        title: title,
        body: body,
        type: type,
        params: params,
        image: image,
        teamId: teamId,
      );

  NotificationAlert.fromJson(dynamic json) {
    id = const Uuid().v4();
    title = json['title'];
    body = json['body'];
    type = json['type'];
    params = json['params'];
    image = json['image'];
    teamId = json['teamId'];
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "body": body,
      "type": type,
      "params": params,
      "image": image,
      "teamId": teamId,
    };
  }
}
