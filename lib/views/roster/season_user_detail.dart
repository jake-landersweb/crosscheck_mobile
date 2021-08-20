import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../root.dart';
import '../../client/root.dart';
import '../../data/root.dart';
import '../../custom_views/root.dart' as cv;

class SeasonUserDetail extends StatelessWidget {
  const SeasonUserDetail({
    Key? key,
    required this.user,
  }) : super(key: key);

  final SeasonUser user;

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar(
      title: "",
      leading: cv.BackButton(
        color: dmodel.color,
      ),
      children: [
        UserAvatar(
          user: user,
          diameter: 100,
          fontSize: 50,
        ),
        SizedBox(height: 16),
        Text(user.seasonName(),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
