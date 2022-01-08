import 'package:equatable/equatable.dart';
import 'package:pnflutter/extras/global_funcs.dart';
import 'package:uuid/uuid.dart';

class Message extends Equatable {
  late String roomId;
  late String messageId;
  late String message;
  late String sender;
  late String email;
  late String created;

  Message({
    required this.roomId,
    required this.messageId,
    required this.message,
    required this.sender,
    required this.email,
    required this.created,
  });

  Message clone() => Message(
        roomId: roomId,
        messageId: messageId,
        message: message,
        sender: sender,
        email: email,
        created: created,
      );

  Message.empty() {
    roomId = "";
    messageId = "${DateTime.now().toUtc()}-${Uuid().v4()}";
    message = "";
    sender = "";
    email = "";
    created = dateToString(DateTime.now().toUtc());
  }

  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "messageId": messageId,
      "message": message,
      "sender": sender,
      "email": email,
      "created": created,
    };
  }

  Message.fromJson(dynamic json) {
    roomId = json['roomId'];
    messageId = json['messageId'];
    message = json['message'];
    sender = json['sender'];
    email = json['email'];
    created = json['created'];
  }

  @override
  List<Object?> get props => [roomId, messageId];
}
