import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterxbackground/helper/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> initializeBackgroundService() async {
  //Specifi Notification Details for local notification(Optional)
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );


  if (Platform.isIOS) {
    await flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: const AndroidInitializationSettings('ic_launcher'), 
        iOS: DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification:(int id, String? title, String? body, String? payload) async {}
        )
      ),
      onDidReceiveNotificationResponse:(NotificationResponse notificationResponse) async {});
  }

  //This channel will be shown in the notification settings for android
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  //This will configure the necessary settings for starting a bg service(Required)
  await service.configure(
    //For Android
    androidConfiguration: AndroidConfiguration(
      //This will be executed when app is in foreground or background in separated isolate
      onStart: onStart,
      //Bg service auto start on app launch
      autoStart: false,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'flutterxbackground',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),

    //For IOS
    iosConfiguration: IosConfiguration(
      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      //Bg service auto start on app launch
      autoStart: false,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

//IOS background settings
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);

  return true;
}

//Background process for the app
@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  //Inside this function write the function that you want to execute in the background
  Timer.periodic(const Duration(seconds: 1), (timer) async {
    //For android
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.
        flutterLocalNotificationsPlugin.show(
          888,
          'Backgorund Service',
          'DateTime: ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // //Show notification
        // if(read("scheduledTime") != null && read("scheduledTime") != ""){
        //   service.invoke("stopService");
        //   NotificationService().scheduleNotification(
        //     title: 'Scheduled Notification',
        //     body: '${read("scheduledTime")}',
        //     scheduledNotificationDateTime: DateTime.parse(read("scheduledTime")),
        //   ).whenComplete(() {
        //     write("scheduledTime", "");
        //   });
        // }

        // if you don't using custom notification, uncomment this
        // service.setForegroundNotificationInfo(
        //   title: "My App Service",
        //   content: "Updated at ${DateTime.now()}",
        // );
      }
    }

    /// you can see this log in logcat
    debugPrint('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');

    // test using external plugin
    final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );
  });
}