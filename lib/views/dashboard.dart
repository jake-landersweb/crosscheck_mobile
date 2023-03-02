import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';

import 'root.dart';
import '../client/root.dart';
import '../extras/root.dart';

class Dashboard extends StatefulWidget {
  static const String route = "/dashboard";

  const Dashboard({
    Key? key,
    required this.initPage,
  }) : super(key: key);

  final String initPage;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<MenuModel>().setPage(widget.initPage);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme:
            Theme.of(context).colorScheme.copyWith(primary: dmodel.color),
      ),
      // child: MenuHost(),
      child: const MainHome(),
    );
  }
}
