import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../custom_views/root.dart' as cv;
import '../../client/root.dart';
import 'root.dart';

class Schedule extends StatefulWidget {
  const Schedule({Key? key}) : super(key: key);

  @override
  _ScheduleState createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  @override
  Widget build(BuildContext context) {
    DataModel dmodel = Provider.of<DataModel>(context);
    if (dmodel.currentSchedule != null) {
      return Column(
        children: [
          _previous(context, dmodel),
          _next(context, dmodel),
          _upcoming(context, dmodel),
          const SizedBox(height: 16),
        ],
      );
    } else {
      if (dmodel.hasSeasons) {
        return const ScheduleLoading();
      } else {
        return const Center(child: Text("There are no seasons for this team."));
      }
    }
  }

  Widget _previous(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSchedule!.previousEvents.isNotEmpty) {
      return cv.Section(
        "Previous",
        allowsCollapse: true,
        child: Opacity(
          opacity: 0.5,
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dmodel.currentSchedule!.previousEvents.length,
            itemBuilder: (context, index) {
              return Column(
                children: [
                  EventCell(
                      event: dmodel.currentSchedule!.previousEvents[index],
                      email: dmodel.user!.email,
                      teamId: dmodel.tus!.team.teamId,
                      seasonId: dmodel.currentSeason!.seasonId),
                  if (dmodel.currentSchedule!.previousEvents[index] !=
                      dmodel.currentSchedule!.previousEvents.last)
                    const SizedBox(height: 10)
                ],
              );
            },
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _next(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSchedule!.nextEvent != null) {
      return cv.Section(
        "Next",
        child: EventCell(
            isExpaded: true,
            event: dmodel.currentSchedule!.nextEvent!,
            email: dmodel.user!.email,
            teamId: dmodel.tus!.team.teamId,
            seasonId: dmodel.currentSeason!.seasonId),
      );
    } else {
      return Container();
    }
  }

  Widget _upcoming(BuildContext context, DataModel dmodel) {
    if (dmodel.currentSchedule!.upcomingEvents.isNotEmpty) {
      return cv.Section(
        "Upcoming",
        allowsCollapse: true,
        initOpen: true,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: dmodel.currentSchedule!.upcomingEvents.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                EventCell(
                    event: dmodel.currentSchedule!.upcomingEvents[index],
                    email: dmodel.user!.email,
                    teamId: dmodel.tus!.team.teamId,
                    seasonId: dmodel.currentSeason!.seasonId),
                if (dmodel.currentSchedule!.upcomingEvents[index] !=
                    dmodel.currentSchedule!.upcomingEvents.last)
                  const SizedBox(height: 10),
              ],
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
