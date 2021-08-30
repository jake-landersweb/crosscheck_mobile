import 'root.dart';

class CalendarEvent {
  late String color;
  late List<EventRaw> events;

  CalendarEvent({required this.color, required this.events});

  CalendarEvent.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    if (json['events'] != null) {
      events = [];
      json['events'].forEach((v) {
        events.add(EventRaw.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['events'] = events.map((v) => v.toJson()).toList();
    return data;
  }
}
