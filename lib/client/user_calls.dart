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

  void login(String email, String password, Function(User) completion) async {
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
      setError("There was an error logging in", true);
    }
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
