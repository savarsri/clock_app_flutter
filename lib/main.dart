import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:watch_app/home.dart';
import 'package:flutter/services.dart';

void main() async {
  AwesomeNotifications().initialize(null, [
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
  await AndroidAlarmManager.initialize();
  runApp(const MyApp());
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
      title: "Watch",
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: WatchApp(),
    );
  }
}
