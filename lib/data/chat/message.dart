import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:equatable/equatable.dart';
import 'package:pnflutter/extras/global_funcs.dart';
import 'package:uuid/uuid.dart';

class Message extends Model {
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
    messageId = "";
    message = "";
    sender = "";
    email = "";
    created = "";
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "message": message,
      "sender": sender,
      "email": email,
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
  String getId() {
    return roomId;
  }

  @override
  ModelType<Model> getInstanceType() {
    // TODO: implement getInstanceType
    throw UnimplementedError();
  }

  // @override
  // List<Object?> get props => [roomId, messageId];
}
