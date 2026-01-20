import 'package:hive/hive.dart';

part "department.g.dart";

@HiveType(typeId: 0)
class Department extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  Department({required this.name, required this.description});
}
