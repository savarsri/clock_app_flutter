import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class alarmPage extends StatefulWidget {
  const alarmPage({key});

  @override
  State<alarmPage> createState() => _alarmPageState();
}

List<String> lapTime = [];
List<String> lapNo = [];
List<String> delta = [];
String selectedValue = "Once";
List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("Once"), value: "Once"),
    DropdownMenuItem(child: Text("Daily"), value: "Daily"),
  ];
  return menuItems;
}

List<int> alarmID = [];
List<String> alarmTime = [];
int count = 0;
int _hourValueAlarm = 0, _minuteValueAlarm = 0;

void setAlarm() {
  print("alarm setted");
  if (_hourValueAlarm / 12 == 0) {
    alarmTime.add("$_hourValueAlarm:$_minuteValueAlarm am");
  } else {
    int temp = _hourValueAlarm % 12;
    alarmTime.add("$temp:$_minuteValueAlarm pm");
  }
  if (selectedValue == "Once") {
    alarmID.add(count);
    AndroidAlarmManager.oneShotAt(
        DateTime(2022, 8, 13, _hourValueAlarm, _minuteValueAlarm),
        alarmID[count],
        fireAlarm);
    count++;
  } else {}
}

void deleteAlarm() {}

void fireAlarm() {
  print("Alarm fired");
}

class _alarmPageState extends State<alarmPage> {
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
                Navigator.maybePop(context);
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
                    value: _hourValueAlarm,
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
                        setState(() => _hourValueAlarm = value),
                  ),
                  NumberPicker(
                    value: _minuteValueAlarm,
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
                        setState(() => _minuteValueAlarm = value),
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
              onPressed: () {},
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
