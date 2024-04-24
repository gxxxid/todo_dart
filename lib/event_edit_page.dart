import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dao.dart';
import 'dto.dart';

class EventEditPage extends StatefulWidget {
  final EventDAO eventDAO;
  final Event event;
  final int? eventIndex; // This is null when adding a new event.

  EventEditPage({required this.eventDAO, required this.event, this.eventIndex});

  @override
  _EventEditPageState createState() => _EventEditPageState();
}

class _EventEditPageState extends State<EventEditPage> {
  late TextEditingController _titleController;
  late TextEditingController _detailController;
  DateTime _selectedDate = DateTime.now();
  String _selectedRepeatCycle = 'none';
  bool _isRepeat = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _detailController = TextEditingController(text: widget.event.eventDetail);
    _selectedDate = widget.event.startDate;
    _selectedRepeatCycle = widget.event.repeatCycle;
    _isRepeat = widget.event.repeat;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailController.dispose();
    super.dispose();
  }

  void _saveEvent() {
    final updatedEvent = Event(
      title: _titleController.text,
      startDate: _selectedDate,
      repeat: _isRepeat,
      repeatCycle: _selectedRepeatCycle,
      repeatIndex: 0, // This should be updated based on user input for repeat specifics.
      eventDetail: _detailController.text,
    );

    if (widget.eventIndex == null) {
      widget.eventDAO.addEvent(updatedEvent);
    } else {
      widget.eventDAO.editEvent(widget.eventIndex!, updatedEvent);
    }

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.eventIndex == null ? 'Add Event' : 'Edit Event'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            ListTile(
              title: Text('Date: ${DateFormat.yMd().format(_selectedDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context),
            ),
            SwitchListTile(
              title: Text('Repeat'),
              value: _isRepeat,
              onChanged: (bool value) {
                setState(() {
                  _isRepeat = value;
                });
              },
            ),
            DropdownButtonFormField(
              value: _selectedRepeatCycle,
              onChanged: _isRepeat ? (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRepeatCycle = newValue;
                  });
                }
              } : null,
              items: <String>['none', 'day', 'week', 'month', 'year']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Repeat Cycle'),
            ),
            TextFormField(
              controller: _detailController,
              decoration: InputDecoration(labelText: 'Details'),
              maxLines: 5,
            ),
            ElevatedButton(
              onPressed: _saveEvent,
              child: Text('Confirm'),
            )
          ],
        ),
      ),
    );
  }
}
