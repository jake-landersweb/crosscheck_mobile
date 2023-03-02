// import 'package:flutter/material.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:crosscheck_sports/data/root.dart';
// import 'package:crosscheck_sports/data/tuple.dart';
// import 'package:crosscheck_sports/views/root.dart';
// import '../../../custom_views/root.dart' as cv;

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/data/templates/template.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/season/create/sce_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class SCETemplates extends StatefulWidget {
  const SCETemplates({super.key});

  @override
  State<SCETemplates> createState() => _SCETemplatesState();
}

class _SCETemplatesState extends State<SCETemplates> {
  @override
  void initState() {
    if (context.read<SCEModel>().names == null) {
      getTemplates(context.read<DataModel>(), context.read<SCEModel>());
    }
    if (context.read<SCEModel>().seasonTemplates == null) {
      getSeasonTemplates(context.read<DataModel>(), context.read<SCEModel>());
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
    SCEModel smodel = Provider.of<SCEModel>(context);
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
              "Start from an old season:",
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          if (smodel.seasonTemplates == null)
            cv.LoadingWrapper(
              child: cv.ListView<int>(
                horizontalPadding: 0,
                children: [for (var i = 0; i < 6; i++) i],
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
              children: smodel.seasonTemplates!,
              onChildTap: ((context, item) {
                getSeasonTemplate(dmodel, smodel, item.sortKey);
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
                              color: smodel.selectedName == item.title
                                  ? dmodel.color
                                  : CustomColors.textColor(context)
                                      .withOpacity(0.5),
                            )
                          : SvgPicture.asset(
                              item.getIcon()!,
                              height: 28,
                              width: 28,
                              color: smodel.selectedName == item.title
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
                        color: smodel.selectedName == item.title
                            ? dmodel.color
                            : CustomColors.textColor(context),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 16),
          const SizedBox(
            width: double.infinity,
            child: Text(
              "Start from a basic template:",
              style: TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 16),
          if (smodel.names == null)
            cv.LoadingWrapper(
              child: cv.ListView<int>(
                horizontalPadding: 0,
                children: [for (var i = 0; i < 6; i++) i],
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
              children: smodel.names!,
              onChildTap: ((context, item) {
                if (item.title == "None") {
                  setState(() {
                    smodel.selectedName = item.title;
                  });
                  smodel.setTemplate(Template.empty());
                } else {
                  // fetch the template
                  getTemplate(dmodel, smodel, item);
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
                              color: smodel.selectedName == item.title
                                  ? dmodel.color
                                  : CustomColors.textColor(context)
                                      .withOpacity(0.5),
                            )
                          : SvgPicture.asset(
                              item.getIcon()!,
                              height: 28,
                              width: 28,
                              color: smodel.selectedName == item.title
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
                        color: smodel.selectedName == item.title
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

  Widget _templateCell(DataModel dmodel, SCEModel smodel, TemplateName name,
      {bool? showIcon, bool? isSeason}) {
    return cv.BasicButton(
      onTap: () {
        if (isSeason ?? false) {
          getSeasonTemplate(dmodel, smodel, name.sortKey);
        } else {
          if (name.title == "None") {
            setState(() {
              smodel.selectedName = name.title;
            });
            smodel.setSeasonData(Season.empty());
          } else {
            // fetch the template
            getTemplate(dmodel, smodel, name);
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: CustomColors.cellColor(context),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSeason ?? false
                ? smodel.selectedName == name.sortKey
                    ? dmodel.color
                    : Colors.transparent
                : smodel.selectedName == name.title
                    ? dmodel.color
                    : Colors.transparent,
            width: 1,
          ),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showIcon ?? false)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.block_outlined),
                      SizedBox(width: 8),
                    ],
                  ),
                Text(
                  name.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    color: CustomColors.textColor(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void getTemplates(DataModel dmodel, SCEModel smodel) async {
    await dmodel.getxCheckTemplateNames(false, true, (names) {
      setState(() {
        smodel.names = names;
        smodel.names!.insert(
            0, TemplateName(id: "", sortKey: "", title: "None", icon: ""));
      });
    });
  }

  void getSeasonTemplates(DataModel dmodel, SCEModel smodel) async {
    await dmodel.getSeasonsAsTemplateNames(smodel.team.teamId, (names) {
      setState(() {
        smodel.seasonTemplates = names;
      });
    });
  }

  void getTemplate(DataModel dmodel, SCEModel smodel, TemplateName name) async {
    await dmodel.getxCheckTemplate(name.sortKey, (p0) {
      setState(() {
        smodel.selectedName = name.title;
      });
      // set the season info
      smodel.setTemplate(p0);
    });
  }

  void getSeasonTemplate(
      DataModel dmodel, SCEModel smodel, String seasonId) async {
    await dmodel.getSeasonAsTemplate(smodel.team.teamId, seasonId, (p0) {
      setState(() {
        smodel.selectedName = seasonId;
      });
      smodel.setTemplate(p0);
    });
  }
}
