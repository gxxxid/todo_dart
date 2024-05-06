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
  bool showEvents = true;
  Color darkGrey = Color(0xFFA9A9A9);
  Color lightGrey = Color(0xFFD9D9D9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightGrey,
      appBar: AppBar(
        //title: Text('ToDo List'),
        toolbarHeight: 70.0,
        backgroundColor: lightGrey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: darkGrey,
                onPrimary: Colors.black,
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(148, 60),
              ),
              onPressed: () => setState(() => showEvents = true),
              child: const Text('Current'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: darkGrey,
                onPrimary: Colors.black,
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(80, 60),
              ),
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
              child: const Text('+'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: darkGrey,
                onPrimary: Colors.black,
                textStyle: const TextStyle(fontSize: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size(148, 60),
              ),
              onPressed: () => setState(() => showEvents = false),
              child: const Text('Past'),
            ),
          ],
        ),
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


        if (widget.showEvents) {

          events = events.where((event) => !event.startDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))).toList();
        } else {

          events = events.where((event) => event.startDate.isBefore(DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day))).toList();
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            Event event = events[index];
            String subtitle;
            String daysText;
            if (widget.showEvents) {
              int daysLeft = DateTime(event.startDate.year, event.startDate.month, event.startDate.day)
                  .difference(DateTime.now())
                  .inDays;
              subtitle = daysLeft >= 0 ? 'day(s) left' : 'Today';
              daysText = daysLeft.toString();
            } else {
              int daysPast = DateTime.now()
                  .difference(DateTime(event.startDate.year, event.startDate.month, event.startDate.day))
                  .inDays;
              subtitle = 'day(s) past';
              daysText = daysPast.toString();
            }

            return Dismissible(
              key: Key(event.key.toString()),
              direction: DismissDirection.endToStart,
              onDismissed: (_) {
                widget.eventDAO.deleteEvent(event.key);
                setState(() {
                  events.removeAt(index);
                });
              },
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              child: InkWell(
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
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  margin: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.grey[500],
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Text(
                          daysText,
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              event.title,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

      },
    );
  }
}
