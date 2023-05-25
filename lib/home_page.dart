import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutterxbackground/helper/read_write.dart';
import 'package:flutterxbackground/services/background_service.dart';

import 'services/notificaiton_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime scheduleTime = DateTime.now();
  String text = "Start Service";
  FlutterBackgroundService? service;
  bool isRunning = false;

  @override
  void initState() {
    checkBgServiceStatus();
    super.initState();
  }

  checkBgServiceStatus() async{
    write("isRunning", false);
    service = FlutterBackgroundService();
    isRunning = await service!.isRunning();
    write("isRunning", isRunning);
    setState(() {});
  }

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
                //Stop/Start Service
                ElevatedButton(
                  child: Text(text),
                  onPressed: () async {
                    if (read("isRunning")) {
                      BackgroundService.stopBgService();
                      write("isRunning", false);
                      setState(() {
                        text = 'Start Service';
                      });
                    } else {
                      BackgroundService.startBgService();
                      setState(() {
                        text = 'Stop Service';
                      });
                    }
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
                  onPressed: () async{
                    //To Start the service if it hasnt already, This will automatically trigger the notification beacuse the trigger function is defiled insde bg service
                    if (!read("isRunning")) {
                      BackgroundService.startBgService();
                      setState(() {
                        text = 'Stop Service';
                      });
                    }
                    //Print shedule time
                    debugPrint('Notification Scheduled for $scheduleTime');

                    //Store notification date to call on background
                    write("scheduledTime", scheduleTime.toString());

                    //For Foreground
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