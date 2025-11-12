import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sendapp/Home.dart';
import 'package:sendapp/sendhive.dart';

Box<Settings>? settings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(SettingsAdapter());
  final box = await Hive.openBox<Settings>('SettingsBox');
  settings = box;

  if (box.isEmpty) {
    box.add(Settings(darkmood: false, history: '', first: true));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<Settings>('SettingsBox');
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, value, child) {
        final settings = box.getAt(0);
        return MaterialApp(
          theme: ThemeData.light().copyWith(
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Lateef'),
            primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
              fontFamily: 'Lateef',
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            textTheme: ThemeData.light().textTheme.apply(fontFamily: 'Lateef'),
            primaryTextTheme: ThemeData.light().primaryTextTheme.apply(
              fontFamily: 'Lateef',
            ),
          ),
          themeMode: settings!.darkmood ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: const Home(),
          ),
        );
      },
    );
  }
}
