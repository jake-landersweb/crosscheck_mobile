// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';
import '../extras/root.dart';

extension UserCalls on DataModel {
  Future<void> getUser(String email, Function(User) completion) async {
    print('fetching user');
    var response = await client.fetch('/users/$email');

    if (response == null) {
      addIndicator(IndicatorItem.error("There was an error fetching the user"));
    } else if (response['status'] == 200) {
      completion(User.fromJson(response['body']));
    } else {
      print(response['status']);
      addIndicator(IndicatorItem.error("There was an error fetching the user"));
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
      String email, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response =
        await client.put("/users/$email/update", headers, jsonEncode(body));

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue updaing your user record"));
    } else if (response['status'] == 200) {
      addIndicator(IndicatorItem.success("Successfully updated user record"));
      completion();
    } else {
      print(response['message']);
      addIndicator(
          IndicatorItem.error("There was an issue updaing your user record"));
    }
  }

  Future<void> updateUserNotifications(String email, Map<String, dynamic> body,
      Function(User) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/users/$email/updateNotifications", headers, jsonEncode(body));

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an issue updaing your user record"));
    } else if (response['status'] == 200) {
      addIndicator(IndicatorItem.success("Successfully updated preferences"));
      completion(User.fromJson(response['body']));
    } else {
      print(response['message']);
      addIndicator(
          IndicatorItem.error("There was an issue updaing your user record"));
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
}
