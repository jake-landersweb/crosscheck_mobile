import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/global_funcs.dart';
import 'package:intl/intl.dart';
import 'package:crosscheck_sports/extras/root.dart';

class Message extends Model {
  late String roomId;
  late String messageId;
  late String message;
  late String sender;
  late String email;
  late String created;
  String? img;
  String? video;
  String? presignedImgUrl;
  String? presignedVideoUrl;

  Message({
    required this.roomId,
    required this.messageId,
    required this.message,
    required this.sender,
    required this.email,
    required this.created,
    this.img,
    this.video,
  });

  Message clone() => Message(
        roomId: roomId,
        messageId: messageId,
        message: message,
        sender: sender,
        email: email,
        created: created,
        img: img,
        video: video,
      );

  Message.empty() {
    roomId = "";
    messageId = "";
    message = "";
    sender = "";
    email = "";
    created = "";
    img = "";
    video = "";
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      "roomId": roomId,
      "message": message,
      "sender": sender,
      "email": email,
      "img": img,
      "video": video,
    };
  }

  Message.fromJson(dynamic json) {
    roomId = json['roomId'];
    messageId = json['messageId'];
    message = json['message'];
    sender = json['sender'];
    email = json['email'];
    created = json['created'];
    img = json['img'];
    video = json['video'];
  }

  DateTime getDateTime() {
    return DateTime.parse(created).toLocal();
  }

  String getDynamicDate() {
    DateTime date = getDateTime();
    DateTime now = DateTime.now();

    // get seconds between the two dates
    int secondsOffset =
        (now.millisecondsSinceEpoch - date.millisecondsSinceEpoch) ~/ 1000;

    if (secondsOffset < 60) {
      return "Just now";
    }
    int minOffset = secondsOffset ~/ 60;
    if (minOffset < 60) {
      return "$minOffset min ago";
    }
    int hourOffset = minOffset ~/ 60;
    if (hourOffset < 24) {
      return "$hourOffset hr ago";
    }
    int dayOffset = hourOffset ~/ 24;
    if (dayOffset < 365) {
      return "$dayOffset days ago";
    }
    return "> 1 year ago";
  }

  String getTime() {
    return DateFormat.jm().format(getDateTime());
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

  String videoImageName() {
    if (video == null) {
      return "";
    }
    return "${video!.split(".")[0]}.jpg";
  }

  void setPresignedImgUrl(String url) {
    presignedImgUrl = url;
  }

  void setPresignedVideoUrl(String url) {
    presignedVideoUrl = url;
  }

  Future<bool> getPresignedImgUrl(DataModel dmodel) async {
    if (img != null) {
      var url = await dmodel.getMessagePresignedUrl(img!);
      if (url.isNotEmpty()) {
        setPresignedImgUrl(url!);
        return true;
      } else {
        return false;
      }
    } else {
      print("Message: $messageId does not have an image.");
      return false;
    }
  }

  Future<bool> getPresignedVideoUrl(DataModel dmodel) async {
    if (video != null) {
      var url = await dmodel.getMessagePresignedUrl(video!);
      if (url.isNotEmpty()) {
        setPresignedVideoUrl(url!);
        return true;
      } else {
        return false;
      }
    } else {
      print("Message: $messageId does not have an image.");
      return false;
    }
  }

  // @override
  // List<Object?> get props => [roomId, messageId];
}
