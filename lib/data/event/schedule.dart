import 'root.dart';

class Schedule {
  late List<Event> upcomingEvents;
  late List<Event> previousEvents;
  Event? nextEvent;

  Schedule({
    required this.upcomingEvents,
    required this.previousEvents,
    this.nextEvent,
  });

  Schedule.empty() {
    upcomingEvents = [];
    previousEvents = [];
    nextEvent = Event.empty();
  }

  Schedule.of(Schedule schedule) {
    upcomingEvents = schedule.upcomingEvents;
    previousEvents = schedule.previousEvents;
    nextEvent = schedule.nextEvent;
  }

  Schedule.fromjson(Map<String, dynamic> json) {
    upcomingEvents = [];
    previousEvents = [];
    json['upcomingEvents'].forEach((v) {
      upcomingEvents.add(Event.fromJson(v));
    });
    json['previousEvents'].forEach((v) {
      previousEvents.add(Event.fromJson(v));
    });
    if (json['nextEvent'] != null) {
      nextEvent = Event.fromJson(json['nextEvent']);
    }
  }
}
