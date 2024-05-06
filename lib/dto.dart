import 'package:hive/hive.dart';

part 'dto.g.dart'; // Hive generator file

@HiveType(typeId: 0)
class Event extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime startDate;

  @HiveField(2)
  bool repeat;

  @HiveField(3)
  String repeatCycle;

  @HiveField(4)
  int repeatIndex;

  @HiveField(5)
  String eventDetail;

  Event({
    required this.title,
    required this.startDate,
    required this.repeat,
    required this.repeatCycle,
    required this.repeatIndex,
    required this.eventDetail,
  });
}
