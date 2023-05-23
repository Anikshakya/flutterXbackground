import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutterxbackground/helper/read_write.dart';
import 'package:flutterxbackground/services/notificaiton_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundService{
  final service = FlutterBackgroundService();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static configureBackgroundService() async{
    final service = FlutterBackgroundService();
    //Configure the background service
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        //This will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        //Auto start service
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Background Service Configuration',
        initialNotificationContent: 'Configuration on process..',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: true,

        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }

  static void startBgService(){
    final service = FlutterBackgroundService();
    service.startService();
  }

  static void stopBgService(){
    final service = FlutterBackgroundService();
    service.invoke("stopService");
  }

  static void setAsBgService(){
    final service = FlutterBackgroundService();
    service.invoke("setAsBackground");
  }
  
  static void setAsFgService(){
    final service = FlutterBackgroundService();
    service.invoke("setAsForeground");
  }

  // //Configure and start the background process
  // Future<void> initializeService() async {
  //   /// OPTIONAL, using custom notification channel id
  //   const AndroidNotificationChannel channel = AndroidNotificationChannel(
  //     'my_foreground', // id
  //     'MY FOREGROUND SERVICE', // title
  //     description:'This channel is used for important notifications.', // description
  //     importance: Importance.low, // importance must be at low or higher level
  //   );

  //   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  //   if (Platform.isIOS) {
  //     await flutterLocalNotificationsPlugin.initialize(
  //       InitializationSettings(
  //         android: const AndroidInitializationSettings('ic_launcher'), iOS: DarwinInitializationSettings(
  //         requestAlertPermission: true,
  //         requestBadgePermission: true,
  //         requestSoundPermission: true,
  //         onDidReceiveLocalNotification:
  //             (int id, String? title, String? body, String? payload) async {}))
  //     );
  //   }

  //   await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  //   //Configure the background service
  //   await service.configure(
  //     androidConfiguration: AndroidConfiguration(
  //       // this will be executed when app is in foreground or background in separated isolate
  //       onStart: onStart,

  //       // auto start service
  //       autoStart: true,
  //       isForegroundMode: true,

  //       notificationChannelId: 'my_foreground',
  //       initialNotificationTitle: 'Foreground Service',
  //       initialNotificationContent: 'Initializing',
  //       foregroundServiceNotificationId: 888,
  //     ),
  //     iosConfiguration: IosConfiguration(
  //       // auto start service
  //       autoStart: true,

  //       // this will be executed when app is in foreground in separated isolate
  //       onForeground: onStart,

  //       // you have to enable background fetch capability on xcode project
  //       onBackground: onIosBackground,
  //     ),
  //   );

  //   //Start the background service
  //   service.startService(); //This is to start the process
  // }


  //For IOS
  // to ensure this is executed
  // run app from xcode, then from xcode menu, select Simulate Background Fetch
  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);

    return true;
  }


  //For Android
  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // For flutter prior to version 3.0.0
    // We have to register the plugin manually

    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString("hello", "world");

    /// To Show Your own notification
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

    // bring to foreground
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (service is AndroidServiceInstance) {
        // if (await service.isForegroundService()) {
          /// OPTIONAL for use custom notification
          /// the notification id must be equals with AndroidConfiguration when you call configure() method.
          flutterLocalNotificationsPlugin.show(
            888,
            'Bg Service',
            'Hamro Date Time ${DateTime.now()}',
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'my_foreground',
                'MY FOREGROUND SERVICE',
                icon: 'ic_launcher',
                ongoing: true,
              ),
            ),
          );

        //   //Es ma k garne lekh nu parcha
          if(read("scheduledTime") != null && read("scheduledTime") != ""){
            NotificationService().scheduleNotification(
              title: 'Scheduled Notification',
              body: '${read("scheduledTime")}',
              scheduledNotificationDateTime: DateTime.parse(read("scheduledTime")),
            );
          }

        //   // if you don't using custom notification, uncomment this
        //   // service.setForegroundNotificationInfo(
        //   //   title: "My App Service",
        //   //   content: "Updated at ${DateTime.now()}",
        //   // );
        // }
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
}