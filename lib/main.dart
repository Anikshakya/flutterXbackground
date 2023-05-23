import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterxbackground/home_page.dart';
import 'package:flutterxbackground/services/background_service.dart';
import 'package:flutterxbackground/services/notificaiton_service.dart';
import 'package:timezone/data/latest.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService.configureBackgroundService();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notifications',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
