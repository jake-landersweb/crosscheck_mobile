import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crosscheck_sports/components/core/loading_indicator.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Scaffold(
      body: Stack(
        children: [
          const SizedBox(
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Image.asset("assets/launch/x.png", height: 267, width: 267),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).size.height / 2,
              left: 16,
              right: 16,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  XCLoadingIndicator(color: dmodel.color),
                  const SizedBox(height: 16),
                  Text(
                    dmodel.loadText,
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: CustomColors.textColor(context).withOpacity(0.3),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
