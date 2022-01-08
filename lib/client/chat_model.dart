import 'package:amplify_flutter/amplify.dart';
import 'package:flutter/material.dart';
import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';
import 'package:graphql/client.dart';
import 'package:amplify_api/amplify_api.dart';
import '../amplifyconfiguration.dart' as config;
import 'dart:convert';

class ChatModel extends ChangeNotifier {
  Room? room;
  List<Message> messages = [];
  String? nextToken;
  bool moreMessages = true;
  late String name;
  late String email;
  int subRetryCounter = 0;

  bool isFetchingMessages = false;

  late GraphQLClient client;

  GraphQLSubscriptionOperation<String>? operation;

  ChatModel(Team team, Season season, DataModel dmodel, this.name, this.email) {
    // set the name to use as the sender
    final httpLink = HttpLink(
        'https://ouetza3cm5brrohopg2z4utwj4.appsync-api.us-west-2.amazonaws.com/graphql',
        defaultHeaders: {
          "x-api-key": "da2-qckx2gmrbbabrgife56ym557mi",
        });
    Link link = httpLink;

    client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );

    // init room and chat
    init(team.teamId, season.seasonId, dmodel);
  }

  void init(String teamId, String seasonId, DataModel dmodel) async {
    // fetch the room
    await roomSetUp(teamId, seasonId);
    if (room == null) {
      print("There was an error setting up the room");
      dmodel.setError("There was an error setting up chat", true);
      return;
    }
    print("Successfully set up chat room with roomId: ${room!.roomId}");
    // get the most recent messages
    await getMessages(room!.roomId);
    // set up the link to fetch new messages
    amplifySetUp(room!.roomId);
  }

  Future<void> roomSetUp(String teamId, String seasonId) async {
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
        "id": teamId,
        "sortKey": seasonId,
      },
    );
    // send the request
    final QueryResult result = await client.query(options);

    // check for exception
    if (result.hasException) {
      print("Failed to set up room: ${result.exception.toString()}");
      return;
    }
    try {
      // bind to data
      room = Room.fromJson(result.data?['getRoom']);
    } catch (error) {
      print("There was an error: $error");
    }
  }

  void amplifySetUp(String roomId) async {
    // set up amplify if it has not been configured
    if (!Amplify.isConfigured) {
      Amplify.addPlugin(AmplifyAPI());

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
          }
        }
      ''';

      operation = Amplify.API.subscribe(
        request: GraphQLRequest<String>(
          document: qstring,
          variables: {
            "roomId": roomId,
          },
        ),
        onData: (event) {
          print("Subscription event data recieved: ${event.data}");
          dynamic json = jsonDecode(event.data);
          try {
            Message recievedMessage = Message.fromJson(json['onCreateMessage']);
            if (recievedMessage.sender != name) {
              // add to message list if not sent from this sender
              messages.insert(0, recievedMessage);
              notifyListeners();
              print("updated view");
            } else {
              print("Recieved message successful, but sent from this device");
            }
          } catch (error) {
            print("There was an issue decoding the response: $error");
          }
        },
        onEstablished: () {
          print("Subscription established");
        },
        onError: (error) {
          print("Subscription failed with error: $error");
          // incrament a retry up to three times
          if (subRetryCounter < 3) {
            retrySubSCription();
          }
        },
        onDone: () {
          print("Subscription has been closed successfully");
        },
      );
    } on ApiException catch (error) {
      print("Failed to establish subscription: $error");
      // incrament a retry up to three times
      if (subRetryCounter < 3) {
        retrySubSCription();
      }
    }
  }

  Future<void> getMessages(String roomId) async {
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
      final QueryResult result = await client.query(options);
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

  Future<bool> sendMessage(String roomId, String msg) async {
    Message message = Message.empty();
    message.roomId = roomId;
    message.message = msg;
    message.sender = name;
    message.email = email;

    const String qstring = r'''
        mutation sendMessage($input: CreateMessageInput!) {
      createMessage(input: $input) {
        created
        message
        messageId
        roomId
        sender
        email
      }
    }''';

    final MutationOptions options =
        MutationOptions(document: gql(qstring), variables: <String, dynamic>{
      "input": message.toJson(),
    });

    final QueryResult result = await client.mutate(options);

    if (result.hasException) {
      print(
          "There was an issue fetching messages: ${result.exception.toString()}");
      return false;
    }

    if (result.data == null) {
      return false;
    } else if (result.data!['createMessage'] == null) {
      return false;
    } else {
      Message responseMessage = Message.fromJson(result.data!['createMessage']);
      messages.insert(0, responseMessage);
      print("Successfully sent message");
      notifyListeners();
      return true;
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
}
