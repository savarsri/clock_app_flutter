import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:watch_app/home.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationInit();
  AndroidAlarmManager.initialize();
  runApp(const MyApp());
}

void notificationInit() async {
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'Timer Notification',
      channelName: 'Timer Notifications',
      channelDescription: '',
      enableVibration: true,
      importance: NotificationImportance.Max,
      playSound: false,
      channelShowBadge: true,
      defaultColor: Color.fromARGB(255, 44, 44, 44),
    )
  ]);
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
      channelKey: 'Alarm Notification',
      channelName: 'Alarm Notifications',
      channelDescription: '',
      enableVibration: true,
      importance: NotificationImportance.Max,
      playSound: false,
      channelShowBadge: true,
      defaultColor: Color.fromARGB(255, 44, 44, 44),
    )
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: "Clock",
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: homePage(),
    );
  }
}
