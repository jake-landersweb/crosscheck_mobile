// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';

import 'root.dart';
import '../data/root.dart';

extension UserCalls on DataModel {
  void getUser(String email, Function(User) completion) async {
    print('fetching user');
    loadingStatus = LoadingStatus.loading;
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
    loadingStatus = LoadingStatus.loading;

    Map<String, dynamic> body = {
      'email': email.toLowerCase(),
      'password': password,
    };

    Map<String, String> headers = {'Content-Type': 'application/json'};

    var response = await client.put("/loginUser", headers, jsonEncode(body));

    if (response == null) {
      setError("There was an error logging in", true);
    } else if (response['status'] == 200) {
      setSuccess("Successfully logged in", true);
      completion(User.fromJson(response['body']));
    } else {
      print(response['message']);
      switch (response['status']) {
        case 440:
          setError("Your email or password was incorrect", true);
          break;
        case 420:
          setError("Your email or password was incorrect", true);
          break;
        case 430:
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
}