// ignore_for_file: prefer_const_constructors
import 'dart:isolate';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:watch_app/Functions/functions.dart';
import 'package:watch_app/Views/alarmPage.dart';
import 'package:watch_app/Views/stopwatch.dart';
import 'package:watch_app/Views/timer.dart';
import 'package:watch_app/Views/watchAlarm.dart';

class homePage extends StatefulWidget {
  homePage({Key? key}) : super(key: key);

  @override
  State<homePage> createState() => homePageState();
}

PageController pageController = PageController();
int _selectedindex = 0;

class homePageState extends State<homePage> {
  @override
  void initState() {
    super.initState();
    AwesomeNotifications().actionStream.listen((event) {
      if (event.channelKey == "Timer Notification") {
        setState(() {
          functions().stopAlarmRingtone();
          print('Timer');
        });
      } else if (event.channelKey == "Alarm Notification") {
        FlutterRingtonePlayer.stop;
        functions().stopAlarmRingtone();
      }
    });

    AwesomeNotifications().dismissedStream.listen(((event) {
      if (event.channelKey == "Timer Notification") {
        setState(() {
          functions().stopAlarmRingtone();
          print('Timer');
        });
      } else if (event.channelKey == "Alarm Notification") {
        FlutterRingtonePlayer.stop;
        functions().stopAlarmRingtone();
      }
    }));
  }

  @override
  void dispose() {
    super.dispose();
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().dismissedSink.close();
  }

  void onTapped(int index) {
    setState(() {
      _selectedindex = index;
    });
    pageController.animateToPage(index,
        duration: const Duration(milliseconds: 500), curve: Curves.easeIn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (page) {
          setState(() {
            _selectedindex = page;
          });
        },
        children: [
          watchAlarm(),
          watchTimer(),
          stopwatch(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: '',
          ),
        ],
        currentIndex: _selectedindex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.white54,
        onTap: onTapped,
        backgroundColor: Colors.black,
      ),
    );
  }
}
