import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

part 'sendhive.g.dart';

@HiveType(typeId: 0)
class Settings extends HiveObject {
  @HiveField(0)
  bool darkmood = false;

  @HiveField(1)
  String history;

  @HiveField(2)
  bool first;

  Settings({required this.darkmood, required this.history, required this.first});
}
