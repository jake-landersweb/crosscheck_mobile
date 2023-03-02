import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import 'package:provider/provider.dart';
import '../custom_views/root.dart' as cv;
import 'components/root.dart' as comp;

class Update extends StatelessWidget {
  const Update({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Container(
      color: CustomColors.backgroundColor(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              "assets/launch/x.png",
              height: MediaQuery.of(context).size.width / 2,
              width: MediaQuery.of(context).size.width / 2,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Update to the latest version to enjoy all that Crosscheck has to offer",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: CustomColors.textColor(context)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: comp.ActionButton(
                color: dmodel.color,
                title: "Update",
                onTap: () {
                  LaunchReview.launch(
                    iOSAppId: "1585600361",
                    androidAppId: "com.landersweb.crosscheck_sports",
                    writeReview: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
