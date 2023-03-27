import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/custom_views/timezone_select.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:crosscheck_sports/views/shared/positions_create.dart';
import 'package:crosscheck_sports/views/tsce/root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../components/root.dart' as comp;
import 'dart:math' as math;

class _CFPageItem {
  _CFPageItem({
    required this.title,
    required this.icon,
    required this.view,
    required this.color,
    required this.useSheet,
  });
  final String title;
  final IconData icon;
  final Widget view;
  final bool useSheet;
  final Color color;
}

class TSCEAdditional extends StatefulWidget {
  const TSCEAdditional({super.key});

  @override
  State<TSCEAdditional> createState() => _TSCEAdditionalState();
}

class _TSCEAdditionalState extends State<TSCEAdditional> {
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
    var dmodel = Provider.of<DataModel>(context);
    var model = Provider.of<TSCEModel>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          cv.Section(
            "Positions",
            allowsCollapse: true,
            initOpen: true,
            child: Column(
              children: [
                IgnorePointer(
                  ignoring: model.users.isEmpty,
                  child: Opacity(
                    opacity: model.users.isEmpty ? 0.5 : 1,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text(
                            "Create positions automatically from the positions you have in your excel sheet.",
                            style: TextStyle(
                              fontSize: 14,
                              color: CustomColors.textColor(context)
                                  .withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        comp.ListWrapper(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "Source From Roster",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: CustomColors.textColor(context)
                                        .withOpacity(0.7),
                                  ),
                                ),
                              ),
                              FlutterSwitch(
                                value: model.autoPositions,
                                height: 25,
                                width: 50,
                                toggleSize: 18,
                                activeColor: dmodel.color,
                                onToggle: (value) {
                                  setState(() {
                                    model.autoPositions = value;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                IgnorePointer(
                  ignoring: model.autoPositions,
                  child: Opacity(
                    opacity: model.autoPositions ? 0.5 : 1,
                    child: PositionsCreate(
                      positions: model.positions,
                      horizontalPadding: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          cv.Section(
            "Stats",
            allowsCollapse: true,
            initOpen: true,
            color: dmodel.color,
            helperView: (context) {
              return Column(
                children: const [
                  cv.Section(
                    "Stats",
                    child: Text(
                        "Stats can be added and removed at will, and these stats will be tracked for every game you create. But, if you remove a stat from this list later, every user will lose this stat field forever, and the information cannot be re-attained."),
                  )
                ],
              );
            },
            child: Column(
              children: [
                cv.ListView<Widget>(
                  horizontalPadding: 0,
                  childPadding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    cv.LabeledWidget(
                      "Allow Stats",
                      child: Row(
                        children: [
                          FlutterSwitch(
                            value: model.hasStats,
                            height: 25,
                            width: 50,
                            toggleSize: 18,
                            activeColor: dmodel.color,
                            onToggle: (value) {
                              setState(() {
                                model.hasStats = value;
                              });
                            },
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                StatCEList(
                  color: dmodel.color,
                  horizontalPadding: 0,
                  stats: model.stats,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          cv.Section(
            "Custom Fields",
            child: cv.ListView<_CFPageItem>(
              horizontalPadding: 0,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              onChildTap: ((context, item) {
                if (item.useSheet) {
                  cv.cupertinoSheet(
                    context: context,
                    wrapInNavigator: true,
                    builder: (context) {
                      return item.view;
                    },
                  );
                } else {
                  cv.Navigate(context, item.view);
                }
              }),
              childBuilder: ((context, item) {
                return ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 50),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: item.color,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(item.icon, size: 20, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.title,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: CustomColors.textColor(context),
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Transform.rotate(
                        angle: item.useSheet ? -math.pi / 2 : 0,
                        child: Icon(
                          Icons.chevron_right_rounded,
                          color:
                              CustomColors.textColor(context).withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              children: [
                _CFPageItem(
                  title: "Season Custom Fields",
                  color: Colors.blue,
                  icon: Icons.tune_rounded,
                  useSheet: true,
                  view: TSCECustomFields(
                    fields: model.seasonCustomFields,
                    valueLabelText: "Value",
                    onCompletion: (fields) {
                      setState(() {
                        model.seasonCustomFields = fields;
                      });
                      model.updateState();
                    },
                  ),
                ),
                _CFPageItem(
                  title: "Season Custom User Fields",
                  color: Colors.orange,
                  icon: Icons.manage_accounts_rounded,
                  useSheet: true,
                  view: TSCECustomFields(
                    fields: model.seasonCustomUserFields,
                    valueLabelText: "Default Value",
                    onCompletion: (fields) {
                      setState(() {
                        model.seasonCustomUserFields = fields;
                      });
                      model.updateState();
                    },
                  ),
                ),
                _CFPageItem(
                  title: "Event Custom Fields Template",
                  color: Colors.red,
                  icon: Icons.free_cancellation_rounded,
                  useSheet: true,
                  view: TSCECustomFields(
                    fields: model.eventCustomFieldsTemplate,
                    valueLabelText: "Value",
                    onCompletion: (fields) {
                      setState(() {
                        model.eventCustomFieldsTemplate = fields;
                      });
                      model.updateState();
                    },
                  ),
                ),
                _CFPageItem(
                  title: "Event Custom User Fields Template",
                  color: Colors.purple,
                  icon: Icons.manage_accounts_rounded,
                  useSheet: true,
                  view: TSCECustomFields(
                    fields: model.eventCustomFieldsTemplate,
                    valueLabelText: "Default Value",
                    onCompletion: (fields) {
                      setState(() {
                        model.eventCustomFieldsTemplate = fields;
                      });
                      model.updateState();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
