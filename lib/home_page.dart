import 'package:flutter/material.dart';
import 'package:flutterxbackground/helper/constants.dart';

import 'services/notificaiton_service.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime scheduleTime = DateTime.now();
  bool isRunning = false;

  @override
  void initState() {
    checkBgServiceStatus();
    super.initState();
  }

  checkBgServiceStatus() async{
    isRunning = await service.isRunning();
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
                ElevatedButton(
                  child: const Text("Start Service"),
                  onPressed: () async {
                    service.startService();
                  },
                ),
                //Stop/Start Service
                ElevatedButton(
                  child: const Text("Stop Service"),
                  onPressed: () async {
                    service.invoke('stopService');
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
                    //Start Bg service
                    service.startService();

                    //After Starting the Bg service schedule notification
                    NotificationService().scheduleNotification(
                      title: 'Scheduled Notification',
                      body: 'Hey you have an event on $scheduleTime',
                      scheduledNotificationDateTime: scheduleTime
                    );

                    //Print shedule time
                    debugPrint('Notification Scheduled for $scheduleTime');
                    
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