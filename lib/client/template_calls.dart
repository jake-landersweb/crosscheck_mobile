import 'dart:convert';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/indicator_item.dart';
import 'package:crosscheck_sports/data/templates/template.dart';
import 'package:flutter/material.dart';

extension TemplateCalls on DataModel {
  Future<void> getxCheckTemplateNames(
      bool team, bool season, Function(List<TemplateName>) completion,
      {VoidCallback? onError}) async {
    print('fetching templates');

    Map<String, String> headers = {'Content-Type': 'application/json'};

    var body = {
      "team": team,
      "season": season,
    };

    var response =
        await client.put('/templateNames', headers, jsonEncode(body));

    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an error getting the templates"));
      onError == null ? null : onError();
      return;
    } else if (response['status'] == 200) {
      print("successfully found templates");
      List<TemplateName> names = [];
      for (var i in response['body']) {
        names.add(TemplateName.fromJson(i));
      }
      completion(names);
    } else {
      print(response['status']);
      addIndicator(
          IndicatorItem.error("There was an error getting the templates"));
      onError == null ? null : onError();
      return;
    }
  }

  Future<void> getxCheckTemplate(String sortKey, Function(Template) completion,
      {VoidCallback? onError}) async {
    print("getting template ...");
    var response = await client.fetch("/template/$sortKey");
    if (response == null) {
      addIndicator(
          IndicatorItem.error("There was an error getting the template"));
      onError == null ? null : onError();
      return;
    } else if (response['status'] == 200) {
      print("successfully found template");
      completion(Template.fromJson(response['body']));
    } else {
      print(response['status']);
      addIndicator(
          IndicatorItem.error("There was an error getting the template"));
      onError == null ? null : onError();
      return;
    }
  }

  Future<void> getSeasonsAsTemplateNames(
      String teamId, Function(List<TemplateName>) completion,
      {VoidCallback? onError}) async {
    print("getting team's seasons as templates ...");
    var response = await client.fetch("/teams/$teamId/seasonsAsTemplateNames");
    if (response == null) {
      addIndicator(IndicatorItem.error(
          "There was an error getting the season templates"));
      onError == null ? null : onError();
      return;
    } else if (response['status'] == 200) {
      print("successfully found templates");
      List<TemplateName> templates = [];
      for (var i in response['body']) {
        templates.add(TemplateName.fromJson(i));
      }
      completion(templates);
    } else {
      print(response['status']);
      addIndicator(IndicatorItem.error(
          "There was an error getting the season templates"));
      onError == null ? null : onError();
      return;
    }
  }

  Future<void> getSeasonAsTemplate(
      String teamId, String seasonId, Function(Template) completion,
      {VoidCallback? onError}) async {
    print("getting team's seasons as templates ...");
    var response =
        await client.fetch("/teams/$teamId/seasons/$seasonId/asTemplate");
    if (response == null) {
      addIndicator(IndicatorItem.error(
          "There was an error getting the season template"));
      onError == null ? null : onError();
      return;
    } else if (response['status'] == 200) {
      print("successfully found template");
      completion(Template.fromJson(response['body']));
    } else {
      print(response['status']);
      addIndicator(IndicatorItem.error(
          "There was an error getting the season template"));
      onError == null ? null : onError();
      return;
    }
  }
}
