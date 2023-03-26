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
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TSCETemplates extends StatefulWidget {
  const TSCETemplates({super.key});

  @override
  State<TSCETemplates> createState() => _TSCETemplatesState();
}

class _TSCETemplatesState extends State<TSCETemplates> {
  @override
  void initState() {
    if (context.read<TSCEModel>().names == null) {
      _getTemplates(context.read<DataModel>(), context.read<TSCEModel>());
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
    var model = Provider.of<TSCEModel>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'This wizard will help you through the process of creating your team and a season.',
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
          if (model.names == null)
            cv.LoadingWrapper(
              child: cv.ListView<int>(
                horizontalPadding: 0,
                minHeight: 50,
                childPadding: const EdgeInsets.symmetric(horizontal: 16),
                children: [for (var i = 0; i < 8; i++) i],
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
              minHeight: 50,
              childPadding: const EdgeInsets.symmetric(horizontal: 16),
              children: model.names!,
              onChildTap: ((context, item) {
                if (item.title == "None") {
                  setState(() {
                    model.selectedName = item.title;
                  });
                  model.setTemplate(Template.empty());
                } else {
                  // fetch the template
                  _getTemplate(dmodel, model, item);
                }
              }),
              childBuilder: (context, item) {
                return Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: CustomColors.random(item.title),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: item.icon.isEmpty
                              ? const Icon(Icons.block_outlined,
                                  size: 20, color: Colors.white)
                              : SvgPicture.asset(item.getIcon()!,
                                  height: 20, width: 20, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 18,
                        color: model.selectedName == item.title
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

  void _getTemplates(DataModel dmodel, TSCEModel model) async {
    await dmodel.getxCheckTemplateNames(false, true, (names) {
      setState(() {
        model.names = names;
        model.names!.insert(
            0, TemplateName(id: "", sortKey: "", title: "None", icon: ""));
      });
    });
  }

  void _getTemplate(
      DataModel dmodel, TSCEModel model, TemplateName name) async {
    await dmodel.getxCheckTemplate(name.sortKey, (p0) {
      setState(() {
        model.selectedName = name.title;
      });
      // set the season info
      model.setTemplate(p0);
    });
  }
}
