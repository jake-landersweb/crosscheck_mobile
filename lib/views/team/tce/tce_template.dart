import 'package:crosscheck_sports/data/templates/template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TCETemplate extends StatefulWidget {
  const TCETemplate({super.key});

  @override
  State<TCETemplate> createState() => _TCETemplateState();
}

class _TCETemplateState extends State<TCETemplate> {
  @override
  void initState() {
    if (context.read<TCEModel>().names == null) {
      getTemplates(context.read<DataModel>(), context.read<TCEModel>());
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _body(context),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _body(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    TCEModel tmodel = Provider.of<TCEModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'This wizard will help you through the process of creating your season.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Icon(
              Icons.draw_rounded,
              color: dmodel.color,
              size: 72,
            ),
          ),
          const SizedBox(height: 32),
          const SizedBox(
            width: double.infinity,
            child: Text(
              "Start from a basic template:",
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          if (tmodel.names == null)
            cv.LoadingWrapper(
              child: cv.ListView<int>(
                horizontalPadding: 0,
                children: [for (var i = 0; i < 10; i++) i],
                childBuilder: (context, item) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: SizedBox(height: 28, width: 28),
                  );
                },
              ),
            )
          else
            cv.ListView<TemplateName>(
              horizontalPadding: 0,
              children: tmodel.names!,
              onChildTap: ((context, item) {
                if (item.title == "None") {
                  setState(() {
                    tmodel.selectedName = item.title;
                  });
                  tmodel.setTemplate(Template.empty());
                } else {
                  // fetch the template
                  getTemplate(dmodel, tmodel, item);
                }
              }),
              childBuilder: (context, item) {
                return Row(
                  children: [
                    SizedBox(
                      height: 28,
                      width: 28,
                      child: item.icon.isEmpty
                          ? Icon(
                              Icons.block_outlined,
                              size: 28,
                              color: tmodel.selectedName == item.title
                                  ? dmodel.color
                                  : CustomColors.textColor(context)
                                      .withOpacity(0.5),
                            )
                          : SvgPicture.asset(
                              item.getIcon()!,
                              height: 28,
                              width: 28,
                              color: tmodel.selectedName == item.title
                                  ? dmodel.color
                                  : CustomColors.textColor(context)
                                      .withOpacity(0.5),
                            ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18,
                        color: tmodel.selectedName == item.title
                            ? dmodel.color
                            : CustomColors.textColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void getTemplates(DataModel dmodel, TCEModel tmodel) async {
    await dmodel.getxCheckTemplateNames(true, false, (names) {
      setState(() {
        tmodel.names = names;
        tmodel.names!.insert(
            0, TemplateName(id: "", title: "None", icon: "", sortKey: ""));
      });
    });
  }

  void getTemplate(DataModel dmodel, TCEModel tmodel, TemplateName name) async {
    await dmodel.getxCheckTemplate(name.sortKey, (p0) {
      setState(() {
        tmodel.selectedName = name.title;
      });
      // set the team info
      tmodel.setTemplate(p0);
    });
  }
}

// class TCETemplates extends StatefulWidget {
//   const TCETemplates({
//     Key? key,
//     required this.user,
//     this.color = Colors.blue,
//   }) : super(key: key);
//   final User user;
//   final Color color;

//   @override
//   _TCETemplatesState createState() => _TCETemplatesState();
// }

// class _TCETemplatesState extends State<TCETemplates> {
//   Tuple<String, Team> _selectedTemplate = Tuple("None", Team.empty());

//   @override
//   Widget build(BuildContext context) {
//     return cv.Sheet(
//       title: "Start From Template",
//       color: widget.color,
//       child: Column(
//         children: [
//           // teamplate list
//           cv.DynamicSelector<Tuple<String, Team>>(
//             selections: [
//               Tuple("None", Team.empty()),
//               Tuple("Hockey", Team.hockey()),
//               Tuple("Basketball", Team.basketball()),
//               Tuple("Football", Team.football()),
//               Tuple("Golf", Team.golf()),
//               Tuple("Soccer", Team.soccer()),
//               Tuple("Baseball", Team.baseball()),
//             ],
//             selectedLogic: (context, item) {
//               return item.v1() == _selectedTemplate.v1();
//             },
//             titleBuilder: (context, item) {
//               return item.v1();
//             },
//             onSelect: ((context, item) {
//               setState(() {
//                 _selectedTemplate = item;
//               });
//             }),
//             color: widget.color,
//             selectorStyle: cv.DynamicSelectorStyle.list,
//           ),
//           // cv.ListView(
//           //   children: [
//           //     Tuple("None", Team.empty()),
//           //     Tuple("Hockey", Team.hockey()),
//           //     Tuple("Basketball", Team.basketball()),
//           //     Tuple("Football", Team.football()),
//           //     Tuple("Golf", Team.golf()),
//           //     Tuple("Soccer", Team.soccer()),
//           //     Tuple("Baseball", Team.baseball()),
//           //   ],
//           //   horizontalPadding: 0,
//           //   color: widget.color,
//           //   selected: [_selectedTemplate],
//           //   backgroundColor: CustomColors.sheetCell(context),
//           //   allowsSelect: true,
//           //   onSelect: (Tuple<String, Team> value) {
//           //     setState(() {
//           //       _selectedTemplate = value;
//           //     });
//           //   },
//           //   childBuilder: (context, Tuple<String, Team> item) {
//           //     return Text(item.v1(),
//           //         style: TextStyle(
//           //             fontWeight: item.v1() == _selectedTemplate.v1()
//           //                 ? FontWeight.w500
//           //                 : FontWeight.w400,
//           //             fontSize: 18,
//           //             color: item.v1() == _selectedTemplate.v1()
//           //                 ? widget.color
//           //                 : CustomColors.textColor(context).withOpacity(0.7)));
//           //   },
//           //   selectedLogic: (Tuple<String, Team> item) {
//           //     return item.v1() == _selectedTemplate.v1();
//           //   },
//           // ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: cv.RoundedLabel(
//               "Next",
//               color: widget.color,
//               textColor: Colors.white,
//               onTap: () {
//                 Navigator.of(context).pop();
//                 showMaterialModalBottomSheet(
//                   context: context,
//                   builder: (context) {
//                     return TCERoot(
//                       user: widget.user,
//                       team: _selectedTemplate.v2(),
//                       isCreate: true,
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
