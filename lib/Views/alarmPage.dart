import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watch_app/Functions/functions.dart';
import 'package:watch_app/Functions/notifications.dart';
import 'package:watch_app/Views/watchAlarm.dart';

class alarmPage extends StatefulWidget {
  alarmPage({Key? key}) : super(key: key);

  @override
  State<alarmPage> createState() => alarmPageState();
}

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

set sethourValueAlarm(int value) {
  hourValueAlarm = value;
}

set setminuteValueAlarm(int value) {
  minuteValueAlarm = value;
}

class alarmPageState extends State<alarmPage> {
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
    //functions().playAlarmRingtone();
    createAlarmNotifications();
    print("Alarm fired");
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: BackButton(),
        centerTitle: true,
        title: Text(
          'Add Alarm',
          style: TextStyle(),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                setAlarm();
                //Navigator.pop(context);
              },
              icon: Icon(Icons.check))
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
              height: height * 0.15,
              width: width,
            ),
            ElevatedButton(
              onPressed: () {
                deleteAlarm();
                Navigator.maybePop(
                    context,
                    PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (BuildContext context, _, __) {
                          return alarmPage();
                        },
                        transitionsBuilder: (___, Animation<double> animation,
                            ____, Widget child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        }));
              },
              child: Text(
                "Delete Alarm",
                style: TextStyle(color: Colors.red, fontSize: width * 0.045),
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
    );
  }
}

/*
void activateAlarm() {
  if (hourValueAlarm >= getHour(DateTime.now())) {
    if (minuteValueAlarm > getMinute(DateTime.now())) {
      alarmID.add(count);
      alarmHour.add(hourValueAlarm);
      alarmMinute.add(minuteValueAlarm);
      AndroidAlarmManager.oneShotAt(
          DateTime(getYear(DateTime.now()), getMonth(DateTime.now()),
              getDay(DateTime.now()), hourValueAlarm, minuteValueAlarm),
          alarmID[count],
          alarmPageState().fireAlarm(),
          wakeup: true,
          allowWhileIdle: true,
          rescheduleOnReboot: true);
      print("alarm setted");
    } else {
      alarmID.add(count);
      alarmHour.add(hourValueAlarm);
      alarmMinute.add(minuteValueAlarm);
      AndroidAlarmManager.oneShotAt(
          DateTime(getYear(DateTime.now()), getMonth(DateTime.now()),
              getDay(DateTime.now()) + 1, hourValueAlarm, minuteValueAlarm),
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
        DateTime(getYear(DateTime.now()), getMonth(DateTime.now()),
            getDay(DateTime.now()) + 1, hourValueAlarm, minuteValueAlarm),
        alarmID[count],
        fireAlarm,
        wakeup: true,
        allowWhileIdle: true,
        rescheduleOnReboot: true);
    print("alarm setted");
  }
  
}
*/
