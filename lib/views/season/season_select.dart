// import 'package:crosscheck_sports/extras/root.dart';
// import 'package:crosscheck_sports/views/root.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../../client/root.dart';
// import '../../custom_views/root.dart' as cv;
// import '../../data/root.dart';

// class SeasonSelect extends StatefulWidget {
//   const SeasonSelect({
//     Key? key,
//     required this.email,
//     required this.tus,
//     required this.currentSeason,
//   }) : super(key: key);

//   final String email;
//   final TeamUserSeasons tus;
//   final Season currentSeason;

//   @override
//   _SeasonSelectState createState() => _SeasonSelectState();
// }

// class _SeasonSelectState extends State<SeasonSelect> {
//   @override
//   Widget build(BuildContext context) {
//     DataModel dmodel = Provider.of<DataModel>(context);
//     return cv.Sheet(
//       title: "Select Season",
//       color: dmodel.color,
//       child: _body2(context, dmodel),
//     );
//   }

//   Widget _body2(BuildContext context, DataModel dmodel) {
//     return ConstrainedBox(
//       constraints:
//           BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
//       child: SingleChildScrollView(
//         child: Column(
//           children: [
//             cv.DynamicSelector<Season>(
//               selections: widget.tus.seasons,
//               titleBuilder: (context, season) {
//                 return season.title;
//               },
//               selectedLogic: (context, season) {
//                 if (season.title == (dmodel.currentSeason?.title ?? "")) {
//                   return true;
//                 } else {
//                   return false;
//                 }
//               },
//               color: dmodel.color,
//               selectorStyle: cv.DynamicSelectorStyle.list,
//               selectorInline: true,
//               onSelect: (context, season) {
//                 dmodel.setCurrentSeason(season);
//                 dmodel.seasonUsers = null;
//                 Navigator.of(context).pop();
//               },
//             ),
//             const SizedBox(height: 16),
//             cv.BasicButton(
//               onTap: () {
//                 cv.showFloatingSheet(
//                   context: context,
//                   builder: (context) {
//                     return SeasonSelectAll(
//                       team: widget.tus.team,
//                       onSelect: ((season) async {
//                         await FirebaseAnalytics.instance.logEvent(
//                           name: "change_season",
//                           parameters: {"platform": "mobile"},
//                         );
//                         dmodel.setCurrentSeason(season);
//                         dmodel.seasonUsers = null;
//                         Navigator.of(context).pop();
//                         Navigator.of(context).pop();
//                       }),
//                     );
//                   },
//                 );
//               },
//               child: Text(
//                 "See All",
//                 style: TextStyle(
//                   fontWeight: FontWeight.w400,
//                   fontSize: 16,
//                   color: CustomColors.textColor(context).withOpacity(0.5),
//                 ),
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
