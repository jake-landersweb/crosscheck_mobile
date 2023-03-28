import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:video_compress/video_compress.dart';
import 'root.dart';
import '../data/root.dart';
import 'package:graphql/client.dart';
import 'package:amplify_api/amplify_api.dart';
import '../amplifyconfiguration.dart' as config;
import 'dart:convert';
import 'env.dart' as env;
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class ChatModel extends ChangeNotifier {
  Room? room;
  List<Message> messages = [];
  String? nextToken;
  bool moreMessages = true;
  late String name;
  late String email;
  int subRetryCounter = 0;

  bool isFetchingMessages = false;

  GraphQLClient? client;

  StreamSubscription<GraphQLResponse<dynamic>>? operation;

  late String seasonId;

  XFile? selectedImage;
  XFile? selectedVideo;

  ChatModel(Team team, Season season, DataModel dmodel, this.name, this.email) {
    seasonId = "";

    // init room and chat
    init(team.teamId, season.seasonId, dmodel);
  }

  void init(String teamId, String seasonId, DataModel dmodel) async {
    // invalidate data
    client = null;
    room = null;
    messages = [];
    nextToken = null;
    moreMessages = true;
    subRetryCounter = 0;
    selectedImage = null;
    selectedVideo = null;
    isFetchingMessages = false;
    if (operation != null) {
      await operation!.cancel();
      operation = null;
    }
    // set the name to use as the sender
    final httpLink = HttpLink(env.GRAPH, defaultHeaders: {
      "x-api-key": env.GRAPH_API_KEY,
    });

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: httpLink,
    );
    this.seasonId = seasonId;
    // fetch the room
    room = await roomSetUp(teamId, seasonId);
    if (room == null) {
      print("There was an error setting up the room");
      dmodel.addIndicator(
        IndicatorItem.error("There was an error setting up chat"),
      );
      return;
    }
    print(
        "Successfully set up chat room with roomId: ${room!.roomId} seasonId: $seasonId");
    // get the most recent messages
    await getMessages(room!.roomId, isInit: true);
    // set up the link to fetch new messages
    amplifySetUp(room!.roomId);
  }

  Future<Room?> roomSetUp(String tid, String sid) async {
    print("Setting up room ...");
    // compose query
    const String qstring = r'''
        query getRoom($id: String!, $sortKey: String!) {
          getRoom(id: $id, sortKey: $sortKey) {
            created
            id
            roomId
            sortKey
            title
          }
        }
      ''';
    // create passed params
    final QueryOptions options = QueryOptions(
      document: gql(qstring),
      variables: <String, dynamic>{
        "id": tid,
        "sortKey": sid,
      },
    );

    // send the request
    final QueryResult result = await client!.query(options);

    // check for exception
    if (result.hasException) {
      print("Failed to set up room: ${result.exception.toString()}");
      return null;
    }
    try {
      // bind to data
      return Room.fromJson(result.data?['getRoom']);
    } catch (error) {
      print("There was an error: $error");
      return null;
    }
  }

  void amplifySetUp(String roomId) async {
    // set up amplify if it has not been configured
    if (!Amplify.isConfigured) {
      await Amplify.addPlugin(AmplifyAPI());
      try {
        await Amplify.configure(config.amplifyconfig);
      } on AmplifyAlreadyConfiguredException {
        print(
            "Tried to reconfigure Amplify; this can occur when your app restarts on Android.");
      }
    }

    // set up AWS AMPLIFY subscription connection to fetch new messages
    try {
      const String qstring = r'''
        subscription watchMessages($roomId: String!) {
          onCreateMessage(roomId: $roomId) {
            created
            message
            messageId
            roomId
            sender
            email
            img
            video
          }
        }
      ''';

      var test = Amplify.API.subscribe(
        GraphQLRequest(
          document: qstring,
          variables: {
            "roomId": roomId,
          },
        ),
        onEstablished: () {
          print("established");
        },
      );

      operation = test.listen((event) async {
        print("Subscription event data recieved: ${event.data}");
        dynamic json = jsonDecode(event.data);
        try {
          Message recievedMessage = Message.fromJson(json['onCreateMessage']);
          messages.insert(0, recievedMessage);
          notifyListeners();

          // save message as last viewed
          var prefs = await SharedPreferences.getInstance();
          prefs.setString("$seasonId#lastMessageId", recievedMessage.messageId);
        } catch (error) {
          print("There was an issue decoding the response: $error");
        }
      }, onError: (Object e) {
        print("Subscription failed with error: $e");
        // incrament a retry up to three times
        if (subRetryCounter < 3) {
          retrySubSCription();
        }
      });
    } on ApiException catch (error) {
      print("Failed to establish subscription: $error");
      // incrament a retry up to three times
      if (subRetryCounter < 3) {
        retrySubSCription();
      }
    }
  }

  Future<void> getMessages(String roomId, {bool isInit = false}) async {
    if (moreMessages) {
      isFetchingMessages = true;
      notifyListeners();
      print("Getting messages ...");
      const String qstring =
          r'''query getMessages($roomId: String!, $limit: Int! $nextToken: String!) {
        listMessages(roomId:$roomId, limit: $limit, nextToken: $nextToken) {
          items {
            created
            message
            messageId
            roomId
            sender
            email
            img
            video
          }
          nextToken
        }
      }''';
      final QueryOptions options = QueryOptions(
        document: gql(qstring),
        variables: <String, dynamic>{
          "roomId": roomId,
          "limit": 20,
          "nextToken": nextToken ?? "",
        },
      );
      final QueryResult result = await client!.query(options);
      // print(result.data?['listMessages']['items'].toString());

      if (result.hasException) {
        print(result.exception.toString());
        return;
      }

      List<Message> msgs = [];
      for (var i in result.data!['listMessages']['items']) {
        msgs.add(Message.fromJson(i));
      }
      // add the messages to beginning of list in reverse order
      messages.addAll(msgs);

      if (isInit) {
        // save last viewed message
        var prefs = await SharedPreferences.getInstance();
        if (msgs.isEmpty) {
          prefs.setString("$seasonId#lastMessageId", "empty");
        } else {
          prefs.setString("$seasonId#lastMessageId", msgs.first.messageId);
        }
      }

      if (result.data!['listMessages']['nextToken'] == null) {
        moreMessages = false;
      } else {
        nextToken = result.data!['listMessages']['nextToken'];
      }
      print("Successfully fetched messages");
      isFetchingMessages = false;
      notifyListeners();
    } else {
      print("There are no more messages to fetch");
    }
  }

  Future<Message?> sendMessage(String roomId, String msg) async {
    Message message = Message.empty();
    message.roomId = roomId;
    message.message = msg;
    message.sender = name;
    message.email = email;

    String? imgFilename;
    String? videoFilename;

    // handle image if it was passed
    if (selectedImage != null) {
      // compress the image in an isolate
      File file = File(selectedImage!.path);
      print(file.lengthSync());
      void compressIsolate(CompressParam param) {
        param.file.writeAsBytesSync(
          img.encodeJpg(
            img.decodeImage(param.file.readAsBytesSync())!,
            quality: 50,
          ),
        );
        param.sendPort.send(param.file);
      }

      var receivePort = ReceivePort();
      Isolate.spawn(compressIsolate, CompressParam(file, receivePort.sendPort));
      File compressed = await receivePort.first as File;
      print(compressed.lengthSync());

      // create a name
      imgFilename = "${const Uuid().v4()}.jpg";

      Map<String, dynamic> presignedUrlBody = {
        "filename": imgFilename,
        "tags": ["chat"]
      };

      // get a presigned upload url
      Client restclient = Client(client: http.Client());
      var presignedUrlResponse = await restclient.post(
        "/images/uploadImage/${room!.roomId}",
        {'Content-Type': 'application/json'},
        jsonEncode(presignedUrlBody),
      );

      if (presignedUrlResponse == null) {
        return null;
      }

      if (presignedUrlResponse['status'] != 200) {
        print(presignedUrlResponse);
        return null;
      }

      // compose the upload request
      var postUri = Uri.parse(presignedUrlResponse['body']['url']);
      // set request type
      http.MultipartRequest request = http.MultipartRequest("POST", postUri);
      // add the compressed file
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('file', compressed.path);
      request.files.add(multipartFile);

      // add all fields returned by presigned url request
      request.fields['AWSAccessKeyId'] =
          presignedUrlResponse['body']['fields']['AWSAccessKeyId'];
      request.fields['x-amz-security-token'] =
          presignedUrlResponse['body']['fields']['x-amz-security-token'];
      request.fields['policy'] =
          presignedUrlResponse['body']['fields']['policy'];
      request.fields['signature'] =
          presignedUrlResponse['body']['fields']['signature'];
      request.fields['key'] = imgFilename;

      // send the upload request
      http.StreamedResponse uploadResponse = await request.send();

      if (uploadResponse.statusCode != 204) {
        print(uploadResponse);
        return null;
      }
    }

    if (selectedVideo != null) {
      // compress the video in an isolate
      // Future<void> videoCompressIsolate(VideoCompressParam param) async {
      //   MediaInfo? mediaInfo = await VideoCompress.compressVideo(
      //     param.path,
      //     quality: VideoQuality.DefaultQuality,
      //     deleteOrigin: false, // It's false by default
      //   );
      //   param.sendPort.send(mediaInfo!.file);
      // }

      // var receivePort = ReceivePort();
      // await Isolate.spawn(
      //   videoCompressIsolate,
      //   VideoCompressParam(selectedVideo!.path, receivePort.sendPort),
      // );
      // File compressed = await receivePort.first as File;
      MediaInfo? mediaInfo = await VideoCompress.compressVideo(
        selectedVideo!.path,
        quality: VideoQuality.DefaultQuality,
        deleteOrigin: false, // It's false by default
      );

      print("COMPRESSED LENGTH = ${mediaInfo!.file!.lengthSync() / 1000000}mb");

      // create a name
      videoFilename = "${const Uuid().v4()}.mp4";

      Map<String, dynamic> presignedUrlBody = {
        "filename": videoFilename,
        "tags": ["chat"],
      };

      // get a presigned upload url
      Client restclient = Client(client: http.Client());
      var presignedUrlResponse = await restclient.post(
        "/images/uploadImage/${room!.roomId}",
        {'Content-Type': 'application/json'},
        jsonEncode(presignedUrlBody),
      );

      if (presignedUrlResponse == null) {
        return null;
      }

      print("PRE RESPONSE = $presignedUrlResponse");

      if (presignedUrlResponse['status'] != 200) {
        print(presignedUrlResponse);
        return null;
      }

      // compose the upload request
      var postUri = Uri.parse(presignedUrlResponse['body']['url']);
      // set request type
      http.MultipartRequest request = http.MultipartRequest("POST", postUri);
      // add the compressed file
      http.MultipartFile multipartFile =
          await http.MultipartFile.fromPath('file', mediaInfo.file!.path);
      request.files.add(multipartFile);

      // add all fields returned by presigned url request
      request.headers['Content-Type'] = 'video/mp4';
      request.fields['AWSAccessKeyId'] =
          presignedUrlResponse['body']['fields']['AWSAccessKeyId'];
      request.fields['x-amz-security-token'] =
          presignedUrlResponse['body']['fields']['x-amz-security-token'];
      request.fields['policy'] =
          presignedUrlResponse['body']['fields']['policy'];
      request.fields['signature'] =
          presignedUrlResponse['body']['fields']['signature'];
      request.fields['key'] = videoFilename;

      // send the upload request
      http.StreamedResponse uploadResponse = await request.send();

      if (uploadResponse.statusCode != 204) {
        print(uploadResponse);
        return null;
      }
    }

    const String qstring = r'''
        mutation sendMessage($input: CreateMessageInput!) {
      createMessage(input: $input) {
        message
        messageId
        created
        roomId
        sender
        email
        img
        video
      }
    }''';

    message.img = imgFilename;
    message.video = videoFilename;
    Map<String, dynamic> input = message.toJson();

    print("INPUT = $input");

    final MutationOptions options =
        MutationOptions(document: gql(qstring), variables: <String, dynamic>{
      "input": input,
    });

    final QueryResult result = await client!.mutate(options);

    if (result.hasException) {
      print(
          "There was an issue fetching messages: ${result.exception.toString()}");
      return null;
    }

    if (result.data == null) {
      return null;
    } else if (result.data!['createMessage'] == null) {
      return null;
    } else {
      await FirebaseAnalytics.instance.logEvent(
        name: "sent_chat",
        parameters: {"platform": "mobile"},
      );
      print("Successfully sent message");
      selectedImage = null;
      selectedVideo = null;
      notifyListeners();
      return message;
    }
  }

  Future<void> retrySubSCription() async {
    subRetryCounter++;
    await Future.delayed(const Duration(seconds: 5));
    amplifySetUp(room!.roomId);
  }

  @override
  void dispose() {
    print("closing subscription connection");
    if (operation != null) {
      operation!.cancel();
    }
    room = null;
    messages = [];
    super.dispose();
  }

  bool hasAsset() {
    return selectedImage != null || selectedVideo != null;
  }
}

class CompressParam {
  final File file;
  final SendPort sendPort;
  CompressParam(this.file, this.sendPort);
}

class VideoCompressParam {
  final String path;
  final SendPort sendPort;
  VideoCompressParam(this.path, this.sendPort);
}
