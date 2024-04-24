import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dao.dart';
import 'dto.dart';
import 'event_edit_page.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(EventAdapter());
  var box = await Hive.openBox<Event>('events');
  runApp(MyApp(eventDAO: EventDAO(box)));
}

class MyApp extends StatelessWidget {
  final EventDAO eventDAO;

  MyApp({required this.eventDAO});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ToDo List',
      home: MainPage(eventDAO: eventDAO),
    );
  }
}

class MainPage extends StatefulWidget {
  final EventDAO eventDAO;

  MainPage({required this.eventDAO});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool showEvents = true; // Toggle between Events and History

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.event),
            onPressed: () => setState(() => showEvents = true),
          ),
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => setState(() => showEvents = false),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventEditPage(
                    eventDAO: widget.eventDAO,
                    event: Event(title: '', startDate: DateTime.now(), repeat: false, repeatCycle: 'none', repeatIndex: 0, eventDetail: ''),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: EventList(widget.eventDAO, showEvents),
    );
  }
}
class EventList extends StatefulWidget {
  final EventDAO eventDAO;
  final bool showEvents;

  EventList(this.eventDAO, this.showEvents);

  @override
  _EventListState createState() => _EventListState();
}

class _EventListState extends State<EventList> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.eventDAO.eventBox.listenable(),
      builder: (context, Box<Event> box, _) {
        List<Event> events = box.values.toList();

        // Correctly filtering events based on the showEvents flag
        if (widget.showEvents) {
          // Include today's events and future events
          events = events.where((event) => !event.startDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))).toList();
        } else {
          // Include only past events
          events = events.where((event) => event.startDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))).toList();
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            Event event = events[index];
            // Determine subtitle based on current or past event
            String subtitle;
            if (widget.showEvents) {
              int daysLeft = DateTime(event.startDate.year, event.startDate.month, event.startDate.day)
                  .difference(DateTime.now())
                  .inDays;
              subtitle = daysLeft >= 0 ? '$daysLeft day(s) left' : 'Today'; // Future events including today
            } else {
              int daysPast = DateTime.now()
                  .difference(DateTime(event.startDate.year, event.startDate.month, event.startDate.day))
                  .inDays;
              subtitle = '$daysPast day(s) past'; // Past events
            }

            return Dismissible(
              key: Key(event.key.toString()), // Ensure unique key for Dismissible
              direction: DismissDirection.endToStart, // Only allow dismiss by swiping to the left
              onDismissed: (_) {
                // Delete the event from the database
                widget.eventDAO.deleteEvent(event.key);
                // Update the UI
                setState(() {
                  events.removeAt(index); // Remove the event from the list
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(subtitle),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EventEditPage(
                        eventDAO: widget.eventDAO,
                        event: event,
                        eventIndex: event.key,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
