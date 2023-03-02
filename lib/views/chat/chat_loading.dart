import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';

class ChatLoading extends StatelessWidget {
  const ChatLoading({super.key});

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.LoadingWrapper(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                // messsage list
                Expanded(child: Container()),
                // text input
                Column(
                  children: [
                    const Divider(height: 0.5, indent: 0, endIndent: 0),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            cv.BasicButton(
                              onTap: () {},
                              child: SizedBox(
                                height: 40,
                                width: 40,
                                child: Center(
                                  child: Icon(
                                    Icons.add,
                                    color: dmodel.color,
                                  ),
                                ),
                              ),
                            ),
                            // text field
                            Expanded(
                              child: cv.TextField2(
                                autocorrect: true,
                                labelText: "Type here ...",
                                showBackground: false,
                                isLabeled: false,
                                highlightColor: dmodel.color,
                                maxLines: 1,
                                onChanged: (value) {},
                              ),
                            ),
                            Opacity(
                              opacity: 0.5,
                              child: SizedBox(
                                height: 44,
                                width: 44,
                                child: Center(
                                  child: Icon(Icons.send,
                                      color: CustomColors.textColor(context)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                // padding
                const SizedBox(height: 8),
              ],
            ),
            // top bar
            cv.GlassContainer(
              width: double.infinity,
              borderRadius: BorderRadius.circular(0),
              backgroundColor: CustomColors.backgroundColor(context),
              opacity: 0.7,
              blur: 10,
              height: MediaQuery.of(context).padding.top + 40,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: const [
                    Align(alignment: Alignment.bottomLeft, child: MenuButton()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
