import 'package:flutter/material.dart';
import 'package:launch_review/launch_review.dart';
import '../custom_views/root.dart' as cv;

class Update extends StatelessWidget {
  const Update({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset("assets/launch/x.png"),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Update to the latest version to enjoy all that Crosscheck has to offer",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),
            cv.BasicButton(
              child: Material(
                color: Colors.green,
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    "Update",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              onTap: () {
                LaunchReview.launch(
                    iOSAppId: "1585600361",
                    androidAppId: "com.landersweb.pnflutter",
                    writeReview: false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
