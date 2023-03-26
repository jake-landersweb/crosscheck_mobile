import 'dart:ui';

import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/tsce/root.dart';
import 'package:crosscheck_sports/views/tsce/tsce_model.dart';
import 'package:flutter/material.dart';
import 'package:crosscheck_sports/custom_views/root.dart' as cv;
import 'package:provider/provider.dart';
import 'package:sprung/sprung.dart';

class TSCERoot extends StatefulWidget {
  const TSCERoot({
    super.key,
    required this.user,
  });
  final User user;

  @override
  State<TSCERoot> createState() => _TSCERootState();
}

class _TSCERootState extends State<TSCERoot> {
  late PageController _controller;
  bool _isLoading = false;

  @override
  void initState() {
    _controller = PageController();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dmodel = context.read<DataModel>();
    return ChangeNotifierProvider(
      create: (context) => TSCEModel(email: widget.user.email),
      builder: (context, _) {
        return Container(
          color: CustomColors.backgroundColor(context),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              cv.AppBar.sheet(
                canScroll: false,
                title: "Create My Team",
                leading: [
                  cv.BackButton(
                    color: dmodel.color,
                    showIcon: false,
                    showText: true,
                    title: "Cancel",
                  )
                ],
                children: [
                  Expanded(
                    child: _body(context, dmodel),
                  ),
                ],
              ),
              _navigation(context, dmodel),
            ],
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, DataModel dmodel) {
    var model = Provider.of<TSCEModel>(context);
    return Column(
      children: [
        Container(
          color: CustomColors.textColor(context).withOpacity(0.05),
          child: Column(children: [
            const SizedBox(height: 60),
            model.status(context, dmodel, _controller),
            const SizedBox(height: 16),
          ]),
        ),
        Expanded(
          child: PageView(
            controller: _controller,
            children: const [
              //
              TSCETemplates(),
              TSCEBasic(),
              TSCERoster(),
              TSCEAdditional(),
            ],
            onPageChanged: (page) {
              model.setIndex(page);
            },
          ),
        ),
      ],
    );
  }

  Widget _navigation(BuildContext context, DataModel dmodel) {
    TSCEModel model = Provider.of<TSCEModel>(context);
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            16, 0, 16, MediaQuery.of(context).padding.bottom == 0 ? 10 : 0),
        child: Row(
          children: [
            AnimatedOpacity(
              opacity: model.index == 0 ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: cv.BasicButton(
                onTap: () {
                  if (model.index != 0) {
                    _controller.previousPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped,
                    );
                  }
                },
                child: cv.GlassContainer(
                  height: 50,
                  width: 50,
                  borderRadius: BorderRadius.circular(25),
                  backgroundColor:
                      CustomColors.textColor(context).withOpacity(0.1),
                  child: Icon(
                    Icons.chevron_left,
                    color: CustomColors.textColor(context).withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const Spacer(),
            cv.BasicButton(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 5,
                    sigmaY: 5,
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Sprung.overDamped,
                    decoration: BoxDecoration(
                      color: model.isAtEnd() && !model.isValidated().v1()
                          ? Colors.red.withOpacity(0.3)
                          : dmodel.color,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    width: model.isAtEnd()
                        ? MediaQuery.of(context).size.width / 1.5
                        : 50,
                    height: 50,
                    child: model.isAtEnd()
                        ? Center(
                            child: _isLoading
                                ? const cv.LoadingIndicator(color: Colors.white)
                                : Text(
                                    model.isValidated().v2(),
                                    softWrap: false,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                      color: model.isValidated().v1()
                                          ? Colors.white
                                          : Colors.red[900],
                                    ),
                                  ),
                          )
                        : const Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
              onTap: () {
                if (model.isAtEnd()) {
                  if (model.isValidated().v1()) {
                    // if (model.isCreate) {
                    //   _create(context, dmodel, tcemodel);
                    // } else {
                    //   _update(context, dmodel, tcemodel);
                    // }
                  }
                } else {
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 700),
                      curve: Sprung.overDamped);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
