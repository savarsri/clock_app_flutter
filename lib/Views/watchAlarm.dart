import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:watch_app/Functions/functions.dart';
import 'package:watch_app/Views/alarmPage.dart';
import '../Functions/notifications.dart';

class watchAlarm extends StatefulWidget {
  watchAlarm({Key? key}) : super(key: key);

  @override
  State<watchAlarm> createState() => watchAlarmState();
}

String _time = DateFormat("hh:mm:ss a").format(DateTime.now());
String _date = ("Date: " + DateFormat("dd/MM/yyyy").format(DateTime.now()));
late int selectedAlarmId;
late Timer _timerClock;
bool switchBool = true, onTapBool = false;

void stopAlarm() {
  functions().stopAlarmRingtone();
  FlutterRingtonePlayer.stop();
}

class watchAlarmState extends State<watchAlarm> {
  @override
  void initState() {
    _time = DateFormat("hh:mm:ss a").format(DateTime.now());
    _timerClock =
        Timer.periodic(const Duration(milliseconds: 1000), _updateTime);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _timerClock.cancel();
  }

  void _updateTime(Timer _) {
    setState(() {
      _time = DateFormat("hh:mm:ss a").format(DateTime.now());
    });
  }

/*
  void alarmSet() {
    AndroidAlarmManager.oneShotAt(
        DateTime(
            functions().getYear(DateTime.now()),
            functions().getMonth(DateTime.now()),
            functions().getDay(DateTime.now()),
            functions().getHour(DateTime.now()),
            functions().getMinute(DateTime.now()) + 1),
        0,
        fireAlarm);
    print("Alarm set");
  }
  */

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black,
        child: Padding(
          padding: EdgeInsetsDirectional.only(
              top: height * 0.1, start: width * 0.05, end: width * 0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _time,
                style: TextStyle(
                  fontSize: width * 0.10,
                  color: Colors.white,
                ),
              ),
              Text(
                _date,
                style: TextStyle(
                  fontSize: width * 0.05,
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.only(top: 8.0),
                child: Container(
                  height: height * 0.58,
                  width: width,
                  color: Colors.black,
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      itemCount: alarmTime.length,
                      itemBuilder: ((context, index) {
                        selectedAlarmId = index;
                        return Card(
                          elevation: 4,
                          color: Colors.black,
                          shadowColor: Colors.white38,
                          child: ListTile(
                            onTap: () {
                              setState(() {
                                selectedAlarmId = index;
                                hourValueAlarm = alarmHour[selectedAlarmId];
                                minuteValueAlarm = alarmMinute[selectedAlarmId];
                                print("ID: $selectedAlarmId");
                              });
                              functions().addAlarm(context);
                            },
                            minVerticalPadding: height * 0.02,
                            title: Text(
                              alarmTime[index],
                              style: TextStyle(
                                fontSize: height * 0.04,
                              ),
                            ),
                            trailing: Switch(
                                value: switchBool,
                                onChanged: ((value) {
                                  if (switchBool == true) {
                                    //stopAlarm();
                                    switchBool = false;
                                  } else {
                                    selectedAlarmId = index;
                                    hourValueAlarm = alarmHour[selectedAlarmId];
                                    minuteValueAlarm =
                                        alarmMinute[selectedAlarmId];
                                    //activateAlarm();
                                    switchBool = true;
                                  }
                                })),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      hourValueAlarm = functions().getHour(DateTime.now());
                      minuteValueAlarm = functions().getMinute(DateTime.now());
                      functions().addAlarm(context);
                    },
                    child: Icon(
                      Icons.add,
                      size: width * 0.1,
                      color: Colors.blue,
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      primary: Color.fromARGB(255, 44, 44, 44),
                      padding: EdgeInsets.all(10),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
