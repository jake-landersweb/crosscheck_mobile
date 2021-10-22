// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import '../root.dart';
// import '../../client/root.dart';
// import '../../data/root.dart';
// import '../../custom_views/root.dart' as cv;

// class TeamRoster extends StatefulWidget {
//   const TeamRoster({
//     Key? key,
//     required this.teamId,
//   }) : super(key: key);

//   final String teamId;

//   @override
//   _TeamRosterState createState() => _TeamRosterState();
// }

// class _TeamRosterState extends State<TeamRoster> {
//   @override
//   void initState() {
//     super.initState();
//     _checkRoster(context.read<DataModel>());
//   }

//   @override
//   Widget build(BuildContext context) {
//     DataModel dmodel = Provider.of<DataModel>(context);
//     return cv.AppBar(
//       title: "Team Roster",
//       isLarge: true,
//       refreshable: true,
//       color: dmodel.color,
//       onRefresh: () => _refresh(dmodel),
//       leading: cv.BackButton(color: dmodel.color),
//       children: [
//         _roster(context, dmodel),
//       ],
//     );
//   }

//   Widget _roster(BuildContext context, DataModel dmodel) {
//     if (dmodel.teamRoster == null) {
//       // show loading
//       return cv.NativeList(
//         children: [
//           for (int i = 0; i < 15; i++) const UserCellLoading(),
//         ],
//       );
//     } else {
//       return Column(children: [
//         cv.NativeList(
//           children: [
//             for (SeasonUser i in dmodel.teamRoster!)
//               _rosterCell(context, i, dmodel),
//           ],
//         ),
//         const SizedBox(height: 30),
//       ]);
//     }
//   }

//   Widget _rosterCell(BuildContext context, SeasonUser user, DataModel dmodel) {
//     return cv.BasicButton(
//       onTap: () {
//         cv.Navigate(
//           context,
//           SeasonUserDetail(
//             user: user,
//             teamId: dmodel.tus!.team.teamId,
//             seasonId: dmodel.currentSeason!.seasonId,
//           ),
//         );
//       },
//       child: UserCell(
//         user: user,
//         isClickable: true,
//       ),
//     );
//   }

//   void _checkRoster(DataModel dmodel) async {
//     if (dmodel.teamRoster == null) {
//       await dmodel.getTeamRoster(widget.teamId, (users) {
//         dmodel.setTeamRoster(users);
//       });
//     } else {
//       print('already have team roster');
//     }
//   }

//   Future<void> _refresh(DataModel dmodel) async {
//     await dmodel.getTeamRoster(widget.teamId, (users) {
//       dmodel.setTeamRoster(users);
//     });
//   }
// }
