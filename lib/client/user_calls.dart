// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:crosscheck_sports/data/batch_tus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension UserCalls on DataModel {
  Future<void> getUser(String email, Function(User) completion,
      {VoidCallback? onError, bool showErrors = true}) async {
    print('fetching user');
    var response = await client.fetch('/users/$email');

    if (response == null) {
      if (showErrors) {
        addIndicator(
            IndicatorItem.error("There was an error fetching the user"));
      }
      onError == null ? null : onError();
      return;
    } else if (response['status'] == 200) {
      try {
        completion(User.fromJson(response['body']));
      } catch (error) {
        print(error);
        if (showErrors) {
          addIndicator(
              IndicatorItem.error("There was an error fetching the user"));
        }
        onError == null ? null : onError();
      }
    } else {
      print(response['status']);
      if (showErrors) {
        addIndicator(
            IndicatorItem.error("There was an error fetching the user"));
      }
      onError == null ? null : onError();
      return;
    }
  }

  Future<void> login(
      String email, String password, Function(User) completion) async {
    print("logging in...");

    Map<String, dynamic> body = {
      'password': password,
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response =
        await client.put("/users/$email/login", headers, jsonEncode(body));

    if (response == null) {
      addIndicator(IndicatorItem.error("There was an error logging in"));
    } else if (response['status'] == 200) {
      addIndicator(IndicatorItem.success("Successfully logged in"));
      try {
        completion(User.fromJson(response['body']));
      } catch (error) {
        addIndicator(IndicatorItem.error(
            "There was an issue with your data. Contact Support"));
      }
    } else {
      print(response['message']);
      switch (response['status']) {
        case 410:
          addIndicator(IndicatorItem.error(
              "There was an issue with the request client side."));
          break;
        case 420:
          addIndicator(
              IndicatorItem.error("Your email or password was incorrect"));
          break;
        case 430:
          addIndicator(
              IndicatorItem.error("Your email or password was incorrect"));
          break;
        case 440:
          addIndicator(IndicatorItem.error(
              "Your account is not set up yet, contact your team admin or check your email inbox"));
          break;
        default:
          addIndicator(IndicatorItem.error("There was an error logging in"));
      }
    }
  }

  Future<void> createUser(
      Map<String, dynamic> body, Function(User) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client
        .post("/createUser", headers, jsonEncode(body))
        .then((response) {
      if (response == null) {
        addIndicator(IndicatorItem.error(
            "There was an unknown issue creating the user"));
      } else if (response['status'] == 200) {
        addIndicator(IndicatorItem.success("Successfully created user"));
        completion(User.fromJson(response['body']));
      } else {
        print(response['message']);
        switch (response['status']) {
          case 311:
            addIndicator(IndicatorItem.error(response['message']));
            break;
          default:
            addIndicator(IndicatorItem.error(
                "There was an unkown issue creating the user"));
        }
      }
    });
  }

  Future<void> updateUser(
      String email, Map<String, dynamic> body, VoidCallback completion,
      {bool sendMessages = true}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response =
        await client.put("/users/$email/update", headers, jsonEncode(body));

    if (response == null) {
      if (sendMessages) {
        addIndicator(
            IndicatorItem.error("There was an issue updaing your user record"));
      }
    } else if (response['status'] == 200) {
      if (sendMessages) {
        addIndicator(IndicatorItem.success("Successfully updated user record"));
      }
      completion();
    } else {
      print(response['message']);
      if (sendMessages) {
        addIndicator(
            IndicatorItem.error("There was an issue updaing your user record"));
      }
    }
  }

  Future<void> updateUserNotifications(String email, Map<String, dynamic> body,
      Function(User) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/users/$email/updateNotifications", headers, jsonEncode(body));

    if (response == null) {
      print("There was an issue updating the user notifications");
    } else if (response['status'] == 200) {
      print("Successfully updated preferences");
      completion(User.fromJson(response['body']));
    } else {
      print(response['message']);
      print("There was an issue updating the user notifications");
    }
  }

  Future<void> getUserTUS(String email, String? teamId, String? seasonId,
      Function(UserTUS) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    dynamic response;

    print("Getting auto tus");

    if (teamId != null) {
      // send as put
      Map<String, dynamic> body = {'teamId': teamId};
      if (seasonId != null) {
        body['seasonId'] = seasonId;
        body['date'] = dateToString(DateTime.now());
      }
      response =
          await client.put("/users/$email/tus", headers, jsonEncode(body));
    } else {
      response = await client.fetch("/users/$email/tus");
    }
    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue getting your information"));
    } else if (response['status'] == 200) {
      completion(UserTUS.fromJson(response['body']));
    } else {
      print(response['message']);
      addIndicator(
          IndicatorItem.error("There was an issue getting your information"));
    }
  }

  Future<void> sendPasswordResetCode(
      String email, VoidCallback completion, VoidCallback onError) async {
    print('sending user reset code');
    var response = await client.fetch('/users/$email/generatePassResetCode');

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an error sending the reset code"));
      onError();
    } else if (response['status'] == 200) {
      addIndicator(IndicatorItem.success(
          "If this email adress exists, a reset code will be sent"));
      completion();
    } else {
      print(response);
      onError();
    }
  }

  Future<void> resetPassword(String email, Map<String, dynamic> body,
      VoidCallback completion, VoidCallback onError) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/users/$email/updatePassword", headers, jsonEncode(body));

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an error updating your password"));
      onError();
    } else if (response['status'] == 200) {
      addIndicator(IndicatorItem.success("Successfully updated your password"));
      completion();
    } else {
      print(response);
      addIndicator(
          IndicatorItem.error("There was an error updating your password"));
      onError();
    }
  }

  Future<void> sendFeedback(
      String email, Map<String, dynamic> body, VoidCallback completion,
      {VoidCallback? onError}) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/users/$email/sendFeedback", headers, jsonEncode(body));

    if (response == null) {
      addIndicator(IndicatorItem.error(
          "There was an error sending the feedback message"));
      onError == null ? null : onError();
    } else if (response['status'] == 200) {
      addIndicator(
          IndicatorItem.success("Successfully sent your feedback, thank you!"));
      completion();
    } else {
      print(response);
      addIndicator(IndicatorItem.error(
          "There was an error sending the feedback message"));
      onError == null ? null : onError();
    }
  }

  Future<void> deleteAccount(
      String email, VoidCallback completion, VoidCallback onError) async {
    var response = await client.delete('/users/$email/delete');

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue sending the request"));
      onError();
    } else if (response['status'] == 200) {
      print("successfully sent account deletion request");
      completion();
    } else {
      addIndicator(
          IndicatorItem.error("There was an issue sending the request"));
      print(response);
      onError();
    }
  }

  Future<BatchTUS?> getBatchTUS(
      String email, String teamId, String seasonId) async {
    try {
      Map<String, String> headers = {'Content-Type': 'application/json'};
      Map<String, String> body = {
        "email": email,
        "teamId": teamId,
        "seasonId": seasonId,
      };

      var response = await client.put("/batchTUS", headers, jsonEncode(body));
      if (response == null) {
        print("there was a fatal error getting the batchTUS");
        return null;
      } else if (response['status'] == 200) {
        print("successfully got batchTUS");
        BatchTUS b = BatchTUS.fromJson(response['body']);
        return b;
      } else {
        print("there was an error getting the batchTUS: $response");
        return null;
      }
    } catch (error, stacktrace) {
      print("ERROR with getBatchTUS: $error $stacktrace");
      return null;
    }
  }

  Future<int?> getUnreadMessageCount(
      String teamId, String seasonId, String lastMessageId) async {
    var response = await client.fetch(
        "/teams/$teamId/seasons/$seasonId/getUnreadMessageCount/$lastMessageId");

    if (response == null) {
      print("There was a fatal error getting the unread message count");
      return null;
    } else if (response['status'] == 200) {
      print("successfully got unread message count");
      return response['body'];
    } else {
      print("there was an error getting the unread message count $response");
      return null;
    }
  }
}
