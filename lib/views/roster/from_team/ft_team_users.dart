import 'package:crosscheck_sports/client/root.dart';
import 'package:crosscheck_sports/data/root.dart';
import 'package:crosscheck_sports/extras/root.dart';
import 'package:crosscheck_sports/views/root.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../custom_views/root.dart' as cv;
import '../../components/root.dart' as comp;
import 'root.dart';

class FTTeamUsers extends StatefulWidget {
  const FTTeamUsers({super.key});

  @override
  State<FTTeamUsers> createState() => _FTTeamUsersState();
}

class _FTTeamUsersState extends State<FTTeamUsers> {
  @override
  build(BuildContext context) {
    FTModel ftmodel = Provider.of<FTModel>(context);
    DataModel dmodel = Provider.of<DataModel>(context);
    return cv.AppBar.sheet(
        title: "Select Team Users",
        color: dmodel.color,
        trailing: [
          cv.BackButton(
            title: "Done",
            color: dmodel.color,
            showIcon: false,
            showText: true,
          ),
        ],
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.8,
            child: ftmodel.isLoading
                ? const Center(child: cv.LoadingIndicator())
                : ftmodel.users == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "Issue finding Users",
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 18,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: comp.SubActionButton(
                                title: "Retry",
                                backgroundColor:
                                    CustomColors.sheetCell(context),
                                onTap: () => ftmodel.fetchUsers(dmodel),
                              ),
                            )
                          ],
                        ),
                      )
                    : ChangeNotifierProvider<RosterSorting>(
                        create: (_) => RosterSorting(
                          team: ftmodel.team,
                        ),
                        // we use `builder` to obtain a new `BuildContext` that has access to the provider
                        builder: (context, child) {
                          // No longer throws
                          return _body(context, dmodel, ftmodel);
                        },
                      ),
          ),
        ]);
  }

  Widget _body(BuildContext context, DataModel dmodel, FTModel ftmodel) {
    RosterSorting smodel = Provider.of<RosterSorting>(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          smodel.header(context, dmodel),
          if (ftmodel.users!.isEmpty)
            const Center(
              child: Text(
                "All your team users are on this season.",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            )
          else
            cv.ListView<SeasonUser>(
              children: smodel.users(ftmodel.users!,
                  showNicknames: dmodel.tus!.team.showNicknames),
              color: dmodel.color,
              allowsSelect: true,
              selected: ftmodel.selectedUsers,
              horizontalPadding: 0,
              childPadding: const EdgeInsets.all(8),
              backgroundColor: CustomColors.sheetCell(context),
              onSelect: (item) => ftmodel.handleSelect(item),
              selectedLogic: (item) {
                return ftmodel.selectedUsers
                    .any((element) => element.email == item.email);
              },
              childBuilder: (context, item) {
                return Row(
                  children: [
                    Expanded(
                      child: BasicRosterCell(user: item, team: ftmodel.team),
                    ),
                    _trailingWidget(context, item, smodel),
                  ],
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _trailingWidget(
      BuildContext context, SeasonUser user, RosterSorting smodel) {
    if (smodel.sortCF != null) {
      String val = user.teamFields!.customFields
          .firstWhere(
              (element) => element.getTitle() == smodel.sortCF!.getTitle())
          .getValue();
      return Text(val);
    } else {
      return Container();
    }
  }
}
