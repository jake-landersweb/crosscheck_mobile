import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import '../custom_views/root.dart' as cv;

class Update extends StatelessWidget {
  const Update({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: cv.BasicButton(
              child: Text("Open"),
              onTap: () {
                LaunchReview.launch(
                    iOSAppId: "1585600361",
                    androidAppId: "com.landersweb.pnflutter");
              })),
    );
  }
}
