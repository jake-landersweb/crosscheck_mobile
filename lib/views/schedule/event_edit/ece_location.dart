import 'package:flutter/material.dart';
import 'package:pnflutter/extras/root.dart';
import 'root.dart';
import '../../../client/root.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;

class ECELocation extends StatefulWidget {
  const ECELocation({Key? key}) : super(key: key);

  @override
  _ECELocationState createState() => _ECELocationState();
}

class _ECELocationState extends State<ECELocation> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    ECEModel ecemodel = Provider.of<ECEModel>(context);
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        _location(context, dmodel, ecemodel),
        _color(context, dmodel, ecemodel),
      ],
    );
  }

  Widget _location(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: cv.Section(
        "Location",
        child: cv.NativeList(
          itemPadding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            // location
            cv.TextField(
              labelText: "Name",
              onChanged: (value) {
                setState(() {
                  ecemodel.event.eventLocation.name = value;
                });
              },
              validator: (value) {},
              showBackground: false,
              value: ecemodel.event.eventLocation.name ?? "",
              isLabeled: true,
            ),
            cv.TextField(
              labelText: "Address",
              onChanged: (value) {
                setState(() {
                  ecemodel.event.eventLocation.address = value;
                });
              },
              validator: (value) {},
              showBackground: false,
              value: ecemodel.event.eventLocation.address ?? "",
              isLabeled: true,
            ),
          ],
        ),
      ),
    );
  }

  List<String> _avaliableColors = [
    "f97180",
    "f3ab8d",
    "f9d26e",
    "5ee498",
    "6caff2",
    "dbb3f2"
  ];

  Widget _color(BuildContext context, DataModel dmodel, ECEModel ecemodel) {
    return cv.Section(
      "Color:  ${ecemodel.event.eventColor == "" ? "None" : ecemodel.event.eventColor}",
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i in _avaliableColors.sublist(0, 3))
                  _colorCell(context, dmodel, ecemodel, i)
              ],
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (var i in _avaliableColors.sublist(3, 6))
                  _colorCell(context, dmodel, ecemodel, i)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _colorCell(
      BuildContext context, DataModel dmodel, ECEModel ecemodel, String color) {
    return cv.BasicButton(
      onTap: () {
        if (color == ecemodel.event.eventColor) {
          setState(() {
            ecemodel.event.eventColor = "";
          });
        } else {
          setState(() {
            ecemodel.event.eventColor = color;
          });
        }
      },
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: CustomColors.fromHex(color),
          shape: BoxShape.circle,
        ),
        child: ecemodel.event.eventColor == color
            ? const Icon(Icons.circle, color: Colors.white)
            : Container(),
      ),
    );
  }
}
