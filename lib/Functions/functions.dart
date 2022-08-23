import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:watch_app/Views/alarmPage.dart';

class functions {
  int getYear(DateTime datetime) {
    int year;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(0, 4);
    year = int.parse(result);
    return year;
  }

  int getMonth(DateTime datetime) {
    int month;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(5, 7);
    month = int.parse(result);
    return month;
  }

  int getDay(DateTime datetime) {
    int day;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(8, 10);
    day = int.parse(result);
    return day;
  }

  int getHour(DateTime datetime) {
    int hour;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(11, 13);
    hour = int.parse(result);
    return hour;
  }

  int getMinute(DateTime datetime) {
    int minute;
    String result, dateTimeNow;
    dateTimeNow = datetime.toString();
    result = dateTimeNow.substring(14, 16);
    minute = int.parse(result);
    return minute;
  }

  String printDurationHHMMSS(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  String printDurationHHMM(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    if (int.parse(twoDigits(duration.inHours)) / 12 >= 0) {
      return "${(int.parse(twoDigits(duration.inHours)) % 12).toString()}:$twoDigitMinutes";
    } else {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes";
    }
  }

  void addAlarm(BuildContext context) {
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            pageBuilder: (BuildContext context, _, __) {
              return alarmPage();
            },
            transitionsBuilder:
                (___, Animation<double> animation, ____, Widget child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            }));
  }

  void playAlarmRingtone() {
    FlutterRingtonePlayer.playAlarm(volume: 1.0);
  }

  void stopAlarmRingtone() {
    FlutterRingtonePlayer.stop();
    print("Tried to stop");
  }
}
