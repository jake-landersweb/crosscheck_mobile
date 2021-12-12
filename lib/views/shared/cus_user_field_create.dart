// import 'package:flutter/material.dart';
// import '../../data/root.dart';
// import 'root.dart';
// import '../../custom_views/root.dart' as cv;

// class CustomUserFieldCreate extends StatefulWidget {
//   const CustomUserFieldCreate({
//     Key? key,
//     required this.customUserFields,
//   }) : super(key: key);
//   final List<CustomUserField> customUserFields;

//   @override
//   _CustomUserFieldCreateState createState() => _CustomUserFieldCreateState();
// }

// class _CustomUserFieldCreateState extends State<CustomUserFieldCreate> {
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         cv.AnimatedList<CustomUserField>(
//           padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//           buttonPadding: 20,
//           children: widget.customUserFields,
//           cellBuilder: (BuildContext context, CustomUserField item) {
//             return CustomUserFieldField(item: item);
//           },
//         ),
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: cv.BasicButton(
//             onTap: () {
//               setState(() {
//                 widget.customUserFields.add(CustomUserField.empty());
//               });
//             },
//             child: const cv.NativeList(
//               children: [
//                 SizedBox(
//                   height: 40,
//                   child: Center(
//                     child: Text(
//                       "Add new",
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
