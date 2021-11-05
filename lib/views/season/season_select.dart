import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:provider/provider.dart';

import '../../client/root.dart';
import '../../custom_views/root.dart' as cv;
import '../../data/root.dart';

class SeasonSelect extends StatefulWidget {
  const SeasonSelect({
    Key? key,
    required this.email,
    required this.tus,
    required this.currentSeason,
  }) : super(key: key);

  final String email;
  final TeamUserSeasons tus;
  final Season currentSeason;

  @override
  _SeasonSelectState createState() => _SeasonSelectState();
}

class _SeasonSelectState extends State<SeasonSelect> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "Season Select",
      isLarge: true,
      leading: const MenuButton(),
      children: [
        cv.NativeList(
          itemPadding: kIsWeb
              ? const EdgeInsets.all(8)
              : Platform.isIOS || Platform.isMacOS
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.all(8),
          children: [
            for (Season i in widget.tus.seasons)
              _seasonSelectCell(context, i, dmodel),
          ],
        ),
      ],
    );
  }

  Widget _seasonSelectCell(
      BuildContext context, Season season, DataModel dmodel) {
    return cv.BasicButton(
      onTap: () {
        if (widget.currentSeason.seasonId != season.seasonId) {
          // TODO - Add roster fetch
          dmodel.setCurrentSeason(season);
          dmodel.seasonUsers = null;
        }
      },
      child: Row(
        children: [
          Icon(
            widget.currentSeason.seasonId == season.seasonId
                ? Icons.radio_button_checked
                : Icons.radio_button_unchecked,
            color: CustomColors.textColor(context).withOpacity(
                season.seasonId == widget.currentSeason.seasonId ? 1 : 0.5),
          ),
          const SizedBox(width: 16),
          Text(
            season.title,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 18,
              color: CustomColors.textColor(context).withOpacity(
                  season.seasonId == widget.currentSeason.seasonId ? 1 : 0.5),
            ),
          ),
        ],
      ),
    );
  }
}
