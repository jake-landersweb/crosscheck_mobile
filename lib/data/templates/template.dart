import 'package:crosscheck_sports/data/root.dart';
import 'package:flutter/material.dart';

class TemplateName {
  late String id;
  late String sortKey;
  late String title;
  late String icon;

  TemplateName({
    required this.id,
    required this.sortKey,
    required this.title,
    required this.icon,
  });

  TemplateName.empty() {
    id = "";
    sortKey = "";
    title = "";
    icon = "";
  }

  TemplateName.fromJson(dynamic json) {
    id = json['id'];
    sortKey = json['sortKey'];
    title = json['title'];
    icon = json['icon'] ?? "";
  }

  String? getIcon() {
    switch (icon) {
      case "hockey":
        return "assets/svg/hockey.svg";
      case "baseball":
        return "assets/svg/baseball.svg";
      case "football":
        return "assets/svg/football.svg";
      case "basketball":
        return "assets/svg/basketball.svg";
      case "soccer":
        return "assets/svg/soccer.svg";
      case "golf":
        return "assets/svg/golf.svg";
      default:
        return null;
    }
  }
}

class Template {
  late String id;
  late String sortKey;
  late String title;
  late String icon;
  late TemplateMeta meta;

  Template({
    required this.id,
    required this.sortKey,
    required this.title,
    required this.icon,
    required this.meta,
  });

  Template.empty() {
    id = "";
    sortKey = "";
    title = "";
    icon = "";
    meta = TemplateMeta.empty();
  }

  Template.fromJson(dynamic json) {
    id = json['id'];
    sortKey = json['sortKey'];
    title = json['title'];
    icon = json['icon'] ?? "";
    meta = TemplateMeta.fromJson(json['meta']);
  }

  String? getIcon() {
    switch (icon) {
      case "hockey":
        return "assets/svg/hockey.svg";
      case "baseball":
        return "assets/svg/baseball.svg";
      case "football":
        return "assets/svg/football.svg";
      case "basketball":
        return "assets/svg/basketball.svg";
      case "soccer":
        return "assets/svg/soccer.svg";
      default:
        return null;
    }
  }
}

class TemplateMeta {
  late TeamPositions positions;
  late List<CustomField> customFields;
  late List<CustomField> customUserFields;
  List<CustomField>? eventCustomFieldsTemplate;
  List<CustomField>? eventCustomUserFieldsTemplate;
  TeamStat? stats;

  TemplateMeta({
    required this.positions,
    required this.customFields,
    required this.customUserFields,
    this.eventCustomFieldsTemplate,
    this.eventCustomUserFieldsTemplate,
    this.stats,
  });

  TemplateMeta.empty() {
    positions = TeamPositions.empty();
    customFields = [];
    customUserFields = [];
    eventCustomFieldsTemplate = [];
    eventCustomUserFieldsTemplate = [];
    stats = TeamStat.empty();
  }

  TemplateMeta.fromJson(dynamic json) {
    positions = TeamPositions.fromJson(json['positions']);
    customFields = [];
    for (var i in json['customFields']) {
      customFields.add(CustomField.fromJson(i));
    }
    customUserFields = [];
    for (var i in json['customUserFields']) {
      customUserFields.add(CustomField.fromJson(i));
    }
    if (json['eventCustomFieldsTemplate'] != null) {
      eventCustomFieldsTemplate = [];
      for (var i in json['eventCustomFieldsTemplate']) {
        eventCustomFieldsTemplate!.add(CustomField.fromJson(i));
      }
    }
    if (json['eventCustomUserFieldsTemplate'] != null) {
      eventCustomUserFieldsTemplate = [];
      for (var i in json['eventCustomUserFieldsTemplate']) {
        eventCustomUserFieldsTemplate!.add(CustomField.fromJson(i));
      }
    }
    if (json['stats'] != null) {
      stats = TeamStat.fromJson(json['stats']);
    }
  }
}
