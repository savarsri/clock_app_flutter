import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

Future<void> createTimerNotifications() async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 1,
        channelKey: 'Timer Notification',
        title: "Time's up",
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'stop',
          label: 'Stop',
          color: Colors.blueAccent,
        ),
      ]);
}

int uniqueNotificationId() {
  return DateTime.now().microsecondsSinceEpoch;
}
