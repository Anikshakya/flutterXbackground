import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutterxbackground/home_page.dart';
import 'package:flutterxbackground/services/background_service.dart';
import 'package:flutterxbackground/services/notificaiton_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Initialize Backgroung Service
  await initializeBackgroundService();
  //Initialize Notification Service
  NotificationService().initNotification();
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
      title: 'flutterXbackground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}
