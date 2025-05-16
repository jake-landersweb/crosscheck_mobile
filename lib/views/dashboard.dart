import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'root.dart';
import '../client/root.dart';

class Dashboard extends StatefulWidget {
  static const String route = "/dashboard";

  const Dashboard({
    super.key,
    required this.initPage,
  });

  final String initPage;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
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
