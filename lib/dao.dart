import 'package:hive/hive.dart';
import 'dto.dart';

class EventDAO {
  final Box<Event> eventBox;

  EventDAO(this.eventBox);

  void addEvent(Event event) {
    eventBox.add(event); // Hive automatically assigns a unique key
  }

  void editEvent(int key, Event updatedEvent) {
    eventBox.put(key, updatedEvent); // Update the event at the specified key
  }

  void deleteEvent(int key) {
    eventBox.delete(key); // Delete the event with the specified key
  }

}
