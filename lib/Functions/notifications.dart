import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:watch_app/Functions/functions.dart';

Future<void> createTimerNotifications() async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 2,
        channelKey: 'Timer Notification',
        title: "Time's up",
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'stop',
          label: 'Stop',
          color: Colors.blueAccent,
        ),
      ]);
}

Future<void> createAlarmNotifications() async {
  functions().playAlarmRingtone();
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'Alarm Notification',
        title: "Alarm",
        wakeUpScreen: true,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'stop',
          label: 'Stop',
          color: Colors.blueAccent,
        ),
      ]);
}
