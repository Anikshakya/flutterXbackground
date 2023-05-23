import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutterxbackground/helper/read_write.dart';

import 'services/notificaiton_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime scheduleTime = DateTime.now();
  String text = "Stop Service";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Notification Scheduler'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical : 120.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text("Foreground Mode"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsForeground");
                  },
                ),
                ElevatedButton(
                  child: const Text("Background Mode"),
                  onPressed: () {
                    FlutterBackgroundService().invoke("setAsBackground");
                  },
                ),
                //Stop/Start Service
                ElevatedButton(
                  child: Text(text),
                  onPressed: () async {
                    final service = FlutterBackgroundService();
                    var isRunning = await service.isRunning();
                    if (isRunning) {
                      service.invoke("stopService");
                    } else {
                      service.startService();
                    }
                  
                    if (!isRunning) {
                      text = 'Stop Service';
                    } else {
                      text = 'Start Service';
                    }
                    setState(() {});
                  },
                ),
                //Pick date
                ElevatedButton(
                  onPressed: () {
                    var selectedDateTime = DateTime.now();
                    showDatePicker(
                      context: context,
                      initialDate: selectedDateTime,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2030),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light(), // Customize the theme if needed
                          child: child!,
                        );
                      },
                    ).then((DateTime? selectedDate) {
                      if (selectedDate != null) {
                        showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(selectedDateTime),
                        ).then((TimeOfDay? selectedTime) {
                          if (selectedTime != null) {
                            selectedDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              selectedTime.hour,
                              selectedTime.minute,
                            );
                            // Do something with the selected date and time
                            scheduleTime = selectedDateTime;
                            write("scheduledTime", selectedDateTime.toString());
                          }
                        });
                      }
                    });
                  },
                  child: const Text(
                    'Select Date Time',
                  ),
                ),
                //Schedule Button
                ElevatedButton(
                  child: const Text('Schedule notifications'),
                  onPressed: () {
                    debugPrint('Notification Scheduled for $scheduleTime');
                    NotificationService().scheduleNotification(
                      title: 'Scheduled Notification',
                      body: 'Hey you have an event on $scheduleTime',
                      scheduledNotificationDateTime: scheduleTime
                    );
                    //Snack bar
                    final snackBar = SnackBar(
                      content: Text('Notification Scheduled at $scheduleTime'),
                      action: SnackBarAction(
                        label: 'Close',
                        onPressed: () {
                          // Some action to be performed when the SnackBar action button is pressed.
                        },
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }
}