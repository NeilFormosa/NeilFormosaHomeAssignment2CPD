import 'package:hive/hive.dart';

part 'event.g.dart';

@HiveType(typeId: 1)
class Event {
  @HiveField(0)
  String name;

  @HiveField(1)
  String? description;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String departmentName;

  Event({
    required this.name,
    this.description,
    required this.date,
    required this.departmentName,
  });
}
