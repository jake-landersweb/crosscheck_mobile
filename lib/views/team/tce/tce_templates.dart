import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:pnflutter/client/root.dart';
import 'package:pnflutter/data/root.dart';
import 'package:pnflutter/extras/root.dart';
import 'package:pnflutter/views/root.dart';
import 'package:pnflutter/views/shared/positions_create.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class TCETemplates extends StatefulWidget {
  const TCETemplates({
    Key? key,
    required this.user,
    this.color = Colors.blue,
  }) : super(key: key);
  final User user;
  final Color color;

  @override
  _TCETemplatesState createState() => _TCETemplatesState();
}

class _TCETemplatesState extends State<TCETemplates> {
  Tuple<String, Team> _selectedTemplate = Tuple("None", Team.empty());

  @override
  Widget build(BuildContext context) {
    return cv.Sheet(
      title: "Start From Template",
      color: widget.color,
      child: Column(
        children: [
          // teamplate list
          cv.ListView(
            children: [
              Tuple("None", Team.empty()),
              Tuple("Hockey", Team.hockey()),
              Tuple("Golf", Team.golf()),
            ],
            horizontalPadding: 0,
            color: widget.color,
            selected: [_selectedTemplate],
            // backgroundColor: CustomColors.textColor(context).withOpacity(0.1),
            allowsSelect: true,
            onSelect: (Tuple<String, Team> value) {
              setState(() {
                _selectedTemplate = value;
              });
            },
            childBuilder: (context, Tuple<String, Team> item) {
              return Text(item.v1());
            },
            selectedLogic: (Tuple<String, Team> item) {
              return item.v1() == _selectedTemplate.v1();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: cv.RoundedLabel(
              "Next",
              color: widget.color,
              textColor: Colors.white,
              onTap: () {
                Navigator.of(context).pop();
                showMaterialModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return TCERoot(
                      user: widget.user,
                      team: _selectedTemplate.v2(),
                      isCreate: true,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
