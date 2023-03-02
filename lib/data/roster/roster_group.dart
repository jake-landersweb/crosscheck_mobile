import 'dart:convert';

import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';

class RosterGroup {
  late String seasonId;
  late String sortKey;
  late String title;
  late List<String> ids;
  late String created;
  late String icon;
  late String color;
  late String description;

  RosterGroup({
    required this.seasonId,
    required this.title,
    required this.sortKey,
    required this.ids,
    required this.created,
    required this.icon,
    required this.color,
    required this.description,
  });

  RosterGroup.fromJson(dynamic json) {
    try {
      seasonId = json['seasonId'];
      sortKey = json['sortKey'];
      title = json['title'];
      ids = [];
      created = json['created'];
      icon = json['icon'] ?? "";
      description = json['description'] ?? "";
      if (icon.isEmpty) {
        icon = "earth";
      }
      color = json['color'] ?? "";
      if (color.isEmpty) {
        color = "b4b4b4";
      }
      for (var i in json['ids']) {
        ids.add(i);
      }
    } catch (error) {
      debugPrint("There was an error serializing json, $error");
      seasonId = "";
      sortKey = "";
      title = "Error fetching this group";
      ids = [];
      created = "";
      icon = "";
      color = "";
      description = "";
    }
  }

  void update(RosterGroup rg) {
    title = rg.title;
    description = rg.description;
    ids = rg.ids;
    color = rg.color;
    icon = rg.icon;
  }

  Map<String, dynamic> toMap() {
    return {
      "title": title,
      "ids": ids,
      "icon": icon,
      "color": color,
      "description": description,
    };
  }

  dynamic toJson() {
    return jsonEncode(toMap());
  }

  Widget getIcon(double size) {
    return Icon(
      rosterGroupIconMap[icon] ?? RGDEFAULTICON,
      color: CustomColors.fromHex(
        color.isEmpty ? RGDEFAULTCOLOR : color,
      ),
      size: size,
    );
  }
}

final Map<String, IconData> rosterGroupIconMap = {
  "earth": Icons.public_rounded,
  "sun": Icons.wb_sunny_rounded,
  "water": Icons.water_drop_rounded,
  "leaf": Icons.eco_rounded,
  "gem": Icons.diamond_rounded,
  "forest": Icons.forest_rounded,
  "rocket": Icons.rocket_rounded,
  "honeycomb": Icons.hive_rounded,
};

const RGDEFAULTICON = Icons.public_rounded;
const RGDEFAULTCOLOR = "b4b4b4";
