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
      setError("There was an error fetching the user", true);
    } else if (response['status'] == 200) {
      setSuccess("Logged in as ${response['body']['email']}", true);
      completion(User.fromJson(response['body']));
    } else {
      print(response['status']);
      setError("There was an error fetching the user", true);
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
      setError("There was an error logging in", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully logged in", true);
      completion(User.fromJson(response['body']));
    } else {
      print(response['message']);
      switch (response['status']) {
        case 410:
          setError("There was an issue with the request client side.", true);
          break;
        case 420:
          setError("Your email or password was incorrect", true);
          break;
        case 430:
          setError("Your email or password was incorrect", true);
          break;
        case 440:
          setError(
              "Your account is not set up yet, contact your team admin or check your email inbox",
              true);
          break;
        default:
          setError("There was an error logging in", true);
      }
    }
  }

  Future<int> createUser(String email, String firstName, String lastName,
      String password, Function(User) completion) async {
    Map<String, dynamic> body = {
      'email': email.toLowerCase(),
      'password': password,
      "firstName": firstName,
      "lastName": lastName,
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    await client.post("path", headers, jsonEncode(body)).then((response) {
      if (response == null) {
        setError("There was an unknown issue creating the user", true);
        return 400;
      } else if (response['status'] == 200) {
        setSuccess("Successfully created user", true);
        completion(User.fromJson(response['body']));
        return 200;
      } else {
        print(response['message']);
        switch (response['message']) {
          case 410:
            setError("A user with this email address already exists", true);
            return 410;
          default:
            setError("There was an unkown issue creating the user", true);
            return 400;
        }
      }
    });

    return 400;
  }

  void updateUser(
      String email, Map<String, dynamic> body, VoidCallback completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response =
        await client.put("/users/$email/update", headers, jsonEncode(body));

    if (response == null) {
      setError("There was an issue updaing your user record", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully updated user record", true);
      completion();
    } else {
      print(response['message']);
      setError("There was an issue updaing your user record", true);
    }
  }

  Future<void> updateUserNotifications(String email, Map<String, dynamic> body,
      Function(User) completion) async {
    Map<String, String> headers = {'Content-Type': 'application/json'};

    final response = await client.put(
        "/users/$email/updateNotifications", headers, jsonEncode(body));

    if (response == null) {
      setError("There was an issue updaing your user record", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully updated preferences", true);
      completion(User.fromJson(response['body']));
    } else {
      print(response['message']);
      setError("There was an issue updaing your user record", true);
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
      setError("There was an issue getting your information", true);
    } else if (response['status'] == 200) {
      setSuccess("Logged in as $email", true);
      completion(UserTUS.fromJson(response['body']));
    } else {
      print(response['message']);
      setError("There was an issue getting your information", true);
    }
  }
}
