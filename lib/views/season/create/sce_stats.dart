// import 'package:flutter/material.dart';
// import 'package:pnflutter/client/api_helpers.dart';
// import 'package:pnflutter/views/season/create/sce_model.dart';
// import 'package:pnflutter/views/season/create/sce_customf.dart';
// import 'package:pnflutter/views/shared/positions_create.dart';
// import 'package:provider/provider.dart';
// import '../../../client/root.dart';
// import '../../../data/root.dart';
// import '../../../extras/root.dart';
// import '../../menu/root.dart';
// import '../../../custom_views/root.dart' as cv;
// import 'package:flutter_switch/flutter_switch.dart';
// import '../../shared/root.dart';
// import 'root.dart';

// class SCEStats extends StatefulWidget {
//   const SCEStats({
//     Key? key,
//     required this.team,
//   }) : super(key: key);
//   final Team team;

//   @override
//   _SCEStatsState createState() => _SCEStatsState();
// }

// class _SCEStatsState extends State<SCEStats> {
//   @override
//   Widget build(BuildContext context) {
//     DataModel dmodel = Provider.of<DataModel>(context);
//     SCEModel scemodel = Provider.of<SCEModel>(context);
//     return ListView(
//       shrinkWrap: true,
//       padding: EdgeInsets.zero,
//       children: [
//         _isActive(context, dmodel, scemodel),
//         const SizedBox(height: 16),
//         _statList(context, dmodel, scemodel),
//         const SizedBox(height: 48),
//       ],
//     );
//   }

//   Widget _isActive(BuildContext context, DataModel dmodel, SCEModel scemodel) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0),
//       child: cv.Section(
//         "Stats",
//         child: cv.NativeList(
//           children: [
//             cv.LabeledWidget(
//               "Is Active",
//               height: cellHeight,
//               child: FlutterSwitch(
//                 value: scemodel.stats.isActive,
//                 height: 25,
//                 width: 50,
//                 toggleSize: 18,
//                 activeColor: dmodel.color,
//                 onToggle: (value) {
//                   setState(() {
//                     scemodel.stats.isActive = value;
//                   });
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _statList(BuildContext context, DataModel dmodel, SCEModel scemodel) {
//     return Column(
//       children: [
//         scemodel.statView(context, dmodel),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: cv.RoundedLabel(
//             "Add New",
//             color: CustomColors.cellColor(context),
//             textColor: CustomColors.textColor(context),
//             onTap: () {
//               scemodel.addStat(StatItem.empty());
//             },
//           ),
//         ),
//         const SizedBox(height: 48),
//       ],
//     );
//   }
// }

// class StatCell extends StatefulWidget {
//   const StatCell({
//     Key? key,
//     required this.item,
//     this.color = Colors.blue,
//     required this.onTitleChange,
//   }) : super(key: key);
//   final StatItem item;
//   final Color color;
//   final Function(String) onTitleChange;

//   @override
//   _StatCellState createState() => _StatCellState();
// }

// class _StatCellState extends State<StatCell> {
//   @override
//   Widget build(BuildContext context) {
//     DataModel dmodel = Provider.of<DataModel>(context);
//     SCEModel scemodel = Provider.of<SCEModel>(context);
//     return Column(
//       children: [
//         cv.TextField(
//           fieldPadding: EdgeInsets.zero,
//           value: widget.item.getTitle(),
//           labelText: "Title",
//           onChanged: (value) {
//             setState(() {
//               widget.onTitleChange(value);
//             });
//           },
//           validator: (value) {},
//           isLabeled: true,
//         ),
//         const Divider(height: 0.5, indent: 15),
//         cv.LabeledWidget(
//           "Is Active",
//           height: cellHeight,
//           child: FlutterSwitch(
//             value: widget.item.isActive,
//             height: 25,
//             width: 50,
//             toggleSize: 18,
//             activeColor: dmodel.color,
//             onToggle: (value) {
//               setState(() {
//                 widget.item.isActive = value;
//               });
//             },
//           ),
//         ),
//       ],
//     );
//   }
// }
