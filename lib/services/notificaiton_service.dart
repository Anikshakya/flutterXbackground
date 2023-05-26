import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: depend_on_referenced_packages
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('ic_launcher');

    DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      onDidReceiveLocalNotification:(int id, String? title, String? body, String? payload) async {}
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS
    );
      
    await notificationsPlugin.initialize(initializationSettings,onDidReceiveNotificationResponse:(NotificationResponse notificationResponse) async {});
  }

  NotificationDetails  notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails('channelId', 'channelName',
      importance: Importance.max),
      iOS: DarwinNotificationDetails()
    );
  }

  Future showNotification({int id = 0, String? title, String? body, String? payLoad}) async {
    return notificationsPlugin.show(
      id, 
      title, 
      body, 
      notificationDetails()
    );
  }

  Future scheduleNotification({int id = 0, String? title, String? body, String? payLoad, required DateTime scheduledNotificationDateTime}) async {
    //To initialize the TZDateTime(required)
    tz.initializeTimeZones();
    return notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledNotificationDateTime,tz.local,),
      notificationDetails(),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:UILocalNotificationDateInterpretation.absoluteTime
    );
  }
}
