import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watch_app/Functions/functions.dart';
import 'package:watch_app/Functions/notifications.dart';

import 'alarmPage.dart';

class watchAlarm extends StatefulWidget {
  watchAlarm({Key? key}) : super(key: key);

  @override
  State<watchAlarm> createState() => watchAlarmState();
}

String _time = DateFormat("hh:mm:ss a").format(DateTime.now());
String _date = ("Date: " + DateFormat("dd/MM/yyyy").format(DateTime.now()));
late int selectedAlarmId;
late Timer _timerClock;
bool switchBool = true, onTapBool = true;

String selectedValue = "Once";
List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("Once"), value: "Once"),
    DropdownMenuItem(child: Text("Daily"), value: "Daily"),
  ];
  return menuItems;
}

List<int> alarmID = [];
List<int> alarmHour = [];
List<int> alarmMinute = [];
List<String> alarmTime = [];
int hourValueAlarm = 0, minuteValueAlarm = 0, count = 0;

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

  void setAlarm() {
    int tempTime = hourValueAlarm * 60 * 60 + minuteValueAlarm * 60;
    if (hourValueAlarm / 12 < 1) {
      alarmTime.add(
          functions().printDurationHHMM(Duration(seconds: tempTime)) + " am");
    } else {
      alarmTime.add(
          functions().printDurationHHMM(Duration(seconds: tempTime)) + " pm");
    }
    if (hourValueAlarm >= functions().getHour(DateTime.now())) {
      if (minuteValueAlarm > functions().getMinute(DateTime.now())) {
        alarmID.add(count);
        alarmHour.add(hourValueAlarm);
        alarmMinute.add(minuteValueAlarm);
        AndroidAlarmManager.oneShotAt(
            DateTime(
                functions().getYear(DateTime.now()),
                functions().getMonth(DateTime.now()),
                functions().getDay(DateTime.now()),
                hourValueAlarm,
                minuteValueAlarm),
            alarmID[count],
            fireAlarm,
            wakeup: true,
            allowWhileIdle: true,
            rescheduleOnReboot: true);
        print("alarm setted");
      } else {
        alarmID.add(count);
        alarmHour.add(hourValueAlarm);
        alarmMinute.add(minuteValueAlarm);
        AndroidAlarmManager.oneShotAt(
            DateTime(
                functions().getYear(DateTime.now()),
                functions().getMonth(DateTime.now()),
                functions().getDay(DateTime.now()) + 1,
                hourValueAlarm,
                minuteValueAlarm),
            alarmID[count],
            fireAlarm,
            wakeup: true,
            allowWhileIdle: true,
            rescheduleOnReboot: true);
        print("alarm setted");
      }
    } else {
      alarmID.add(count);
      alarmHour.add(hourValueAlarm);
      alarmMinute.add(minuteValueAlarm);
      AndroidAlarmManager.oneShotAt(
          DateTime(
              functions().getYear(DateTime.now()),
              functions().getMonth(DateTime.now()),
              functions().getDay(DateTime.now()) + 1,
              hourValueAlarm,
              minuteValueAlarm),
          alarmID[count],
          fireAlarm,
          wakeup: true,
          allowWhileIdle: true,
          rescheduleOnReboot: true);
      print("alarm setted");
    }
    print(alarmID[count]);
    count++;
  }

  void deleteAlarm() {
    alarmTime.removeAt(selectedAlarmId);
    AndroidAlarmManager.cancel(alarmID[selectedAlarmId]);
    alarmID.removeAt(selectedAlarmId);
    count--;
  }

  static void fireAlarm() {
    createAlarmNotifications();
    print("Alarm fired");
  }

  void stopAlarmRingtone() {
    FlutterRingtonePlayer.stop();
    print("Tried to stop");
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: onTapBool
            ? Container(
                key: Key("WatchPage"),
                color: Colors.black,
                child: Padding(
                  padding: EdgeInsetsDirectional.only(
                      top: height * 0.1,
                      start: width * 0.05,
                      end: width * 0.05),
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
                                        hourValueAlarm =
                                            alarmHour[selectedAlarmId];
                                        minuteValueAlarm =
                                            alarmMinute[selectedAlarmId];
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
                                            hourValueAlarm =
                                                alarmHour[selectedAlarmId];
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
                      Padding(
                        padding: EdgeInsetsDirectional.only(top: height * 0.01),
                        child: SizedBox(
                          height: height * 0.0038,
                          child: Container(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              hourValueAlarm =
                                  functions().getHour(DateTime.now());
                              minuteValueAlarm =
                                  functions().getMinute(DateTime.now());
                              setState(() {
                                onTapBool = false;
                              });
                              //functions().addAlarm(context);
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
              )
            : Container(
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: height * 0.05,
                      width: width,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              onTapBool = true;
                            });
                          },
                          icon: Icon(Icons.arrow_back),
                        ),
                        Text(
                          "Add Alarm",
                          style: TextStyle(fontSize: height * 0.032),
                        ),
                        IconButton(
                          onPressed: () {
                            setAlarm();
                            onTapBool = true;
                          },
                          icon: Icon(Icons.check),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: height * 0.4,
                      width: width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          NumberPicker(
                            value: hourValueAlarm,
                            minValue: 00,
                            maxValue: 23,
                            haptics: true,
                            itemHeight: height * 0.1,
                            infiniteLoop: true,
                            selectedTextStyle: TextStyle(
                              fontSize: width * 0.09,
                              color: Colors.blue,
                            ),
                            textStyle: TextStyle(
                              fontSize: width * 0.07,
                              color: Colors.white,
                            ),
                            onChanged: (value) =>
                                setState(() => hourValueAlarm = value),
                          ),
                          NumberPicker(
                            value: minuteValueAlarm,
                            minValue: 00,
                            maxValue: 59,
                            itemHeight: height * 0.1,
                            infiniteLoop: true,
                            selectedTextStyle: TextStyle(
                              fontSize: width * 0.09,
                              color: Colors.blue,
                            ),
                            textStyle: TextStyle(
                              fontSize: width * 0.07,
                              color: Colors.white,
                            ),
                            onChanged: (value) =>
                                setState(() => minuteValueAlarm = value),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: height * 0.1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hours',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: width * 0.05),
                          ),
                          Text(
                            'Minutes',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Card(
                      color: Colors.black,
                      child: ListTile(
                        title: Text(
                          'Repeat',
                          style: TextStyle(),
                        ),
                        trailing: DropdownButton(
                            value: selectedValue,
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedValue = newValue!;
                              });
                            },
                            items: dropdownItems),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.1,
                      width: width,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        deleteAlarm();
                      },
                      child: Text(
                        "Delete Alarm",
                        style: TextStyle(
                            color: Colors.red, fontSize: width * 0.045),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Color.fromARGB(255, 44, 44, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
