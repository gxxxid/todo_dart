import 'package:hive/hive.dart';
import 'dto.dart';

class EventDAO {
  final Box<Event> eventBox;

  EventDAO(this.eventBox);

  void addEvent(Event event) {
    eventBox.add(event);
  }

  void editEvent(int key, Event updatedEvent) {
    eventBox.put(key, updatedEvent);
  }

  void deleteEvent(int key) {
    eventBox.delete(key);
  }

}
