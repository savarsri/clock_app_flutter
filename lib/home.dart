// ignore_for_file: prefer_const_constructors
import 'dart:isolate';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watch_app/alarmPage.dart';
import 'package:watch_app/notifications.dart';

class WatchApp extends StatefulWidget {
  WatchApp({Key? key}) : super(key: key);

  @override
  State<WatchApp> createState() => _WatchAppState();
}

PageController pageController = PageController();
late Timer _timerClock, _timerProgressBar, _timerRemainingTime;
int _selectedindex = 0,
    _hourValue = 0,
    _minuteValue = 0,
    _secondValue = 0,
    _timerTime = 0,
    _incrementProgressBar = 50,
    _progressTime = 0,
    h = 0,
    m = 0,
    s = 0,
    counter = 1;

String _time = DateFormat("hh:mm:ss a").format(DateTime.now());
bool _isVisibleTimer = false, _isVisiblePauseTimer = false;
bool _isVisibleStopWatch = true,
    _isVisiblePauseStopWatch = true,
    switchBool = true,
    onTapBool = false;
String _remainingTime = "";
String _date = ("Date: " + DateFormat("dd/MM/yyyy").format(DateTime.now()));
String stopWatchTimeString = "00:00:00";
late Isolate _isolate;
String notification = "";
late ReceivePort _receivePort;
late Capability cap;
List<String> lapTime = [];
List<String> lapNo = [];
List<String> delta = [];
List<int> stopWatchTimeList = [];
List<bool> onOffSwitch = [];
late int selectedAlarmId;

class _WatchAppState extends State<WatchApp> {
  static int _stopWatchTime = 0;
  @override
  void initState() {
    super.initState();
    _time = DateFormat("hh:mm:ss a").format(DateTime.now());
    _isVisibleTimer = false;
    _isVisiblePauseTimer = false;
    _timerClock =
        Timer.periodic(const Duration(milliseconds: 1000), _updateTime);

    AwesomeNotifications().actionStream.listen((event) {
      setState(() {
        FlutterRingtonePlayer.stop();
      });
    });

    AwesomeNotifications().dismissedStream.listen(((event) {
      setState(() {
        FlutterRingtonePlayer.stop();
      });
    }));
  }

  @override
  void dispose() {
    super.dispose();
    _timerClock.cancel();
    _timerProgressBar.cancel();
    _timerRemainingTime.cancel();
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

  void _updateTime(Timer _) {
    setState(() {
      _time = DateFormat("hh:mm:ss a").format(DateTime.now());
    });
  }

  void _playButtonTImer() {
    setState(() {
      _timerTime = (_hourValue * 3600 + _minuteValue * 60 + _secondValue);
      _progressTime = _timerTime * 20;

      if (_timerTime > 0) {
        FlutterRingtonePlayer.stop();
        _isVisibleTimer = true;
        _isVisiblePauseTimer = false;
        _timerProgressBar = Timer.periodic(
            Duration(milliseconds: _progressTime), _updateProgressBar);
        h = _timerTime ~/ 3600;
        m = ((_timerTime - h * 3600)) ~/ 60;
        s = _timerTime - (h * 3600) - (m * 60);
        _remainingTime = _printDurationHHMMSS(Duration(seconds: _timerTime));
        _timerRemainingTime =
            Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
      }
    });
  }

  void _pauseButtonTImer() {
    setState(() {
      _isVisiblePauseTimer = true;
      _timerProgressBar.cancel();
      _timerRemainingTime.cancel();
    });
  }

  void _playPauseButtonTimer() {
    setState(() {
      _isVisiblePauseTimer = false;
      _timerProgressBar = Timer.periodic(
          Duration(milliseconds: _progressTime), _updateProgressBar);
      _timerRemainingTime =
          Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
    });
  }

  void _stopButtonTimer() {
    setState(() {
      _isVisibleTimer = false;
      _timerProgressBar.cancel();
      _timerRemainingTime.cancel();
      _incrementProgressBar = 50;
      _remainingTime = "";
    });
    FlutterRingtonePlayer.stop();
  }

  void _updateProgressBar(Timer _) {
    setState(() {
      if (_incrementProgressBar > 0) {
        _incrementProgressBar--;
      } else {}
    });
  }

  void _updateRemainingTime(Timer _) {
    if (_timerTime > 1) {
      _timerTime--;
      setState(() {
        h = _timerTime ~/ 3600;
        m = ((_timerTime - h * 3600)) ~/ 60;
        s = _timerTime - (h * 3600) - (m * 60);
        _remainingTime = _printDurationHHMMSS(Duration(seconds: _timerTime));
      });
    } else {
      _timerRemainingTime.cancel();
      _isVisibleTimer = false;
      _timerProgressBar.cancel();
      _incrementProgressBar = 50;
      _remainingTime = "";
      FlutterRingtonePlayer.playAlarm(volume: 1.0);
      createTimerNotifications();
    }
  }

  void _playButtonStopWatch() async {
    _isVisibleStopWatch = false;
    _receivePort = ReceivePort();
    _isolate = await Isolate.spawn(_checkTimer, _receivePort.sendPort);
    _receivePort.listen(_handleMessage, onDone: () {
      print("done!");
    });
  }

  static void _checkTimer(SendPort sendPort) async {
    Timer.periodic(new Duration(milliseconds: 1), (Timer t) {
      _stopWatchTime++;
      String msg = _printDurationMMSSmm(Duration(milliseconds: _stopWatchTime));
      sendPort.send(msg);
    });
  }

  void _handleMessage(dynamic data) {
    setState(() {
      stopWatchTimeString = data;
    });
  }

  void _pauseButtonStopWatch() {
    _isVisiblePauseStopWatch = false;
    cap = _isolate.pause(_isolate.pauseCapability);
  }

  void _playPauseButtonStopWatch() {
    _isVisiblePauseStopWatch = true;
    _isolate.resume(cap);
  }

  void _stopButtonStopWatch() {
    _isVisibleStopWatch = true;
    _isVisiblePauseStopWatch = true;
    setState(() {
      stopWatchTimeString = '00:00:00';
      lapTime.clear();
    });
    _receivePort.close();
    _isolate.kill(priority: Isolate.immediate);
  }

  void _flagButtonStopWatch() {
    String lapCounter = counter.toString();
    print(_stopWatchTime);
    stopWatchTimeList.add(_stopWatchTime);
    print(stopWatchTimeList[0]);
    if (counter == 1) {
      delta.add(
          _printDurationMMSSmm(Duration(milliseconds: stopWatchTimeList[0])));
    } else {
      delta.add(_printDurationMMSSmm(Duration(
          milliseconds: stopWatchTimeList[counter - 1] -
              stopWatchTimeList[counter - 2])));
    }
    lapTime.add(stopWatchTimeString);
    lapNo.add("Lap $lapCounter");
    counter++;
  }

  String _printDurationHHMMSS(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  static String _printDurationMMSSmm(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds =
        twoDigits(duration.inMilliseconds.remainder(100));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds:$twoDigitMilliseconds";
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
          widgetClock(),
          widgetTimer(),
          widgetStopWatch(),
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

  Scaffold widgetClock() {
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
                              _addAlarm(context);
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
                                    stopAlarm();
                                    switchBool = false;
                                  } else {
                                    selectedAlarmId = index;
                                    hourValueAlarm = alarmHour[selectedAlarmId];
                                    minuteValueAlarm =
                                        alarmMinute[selectedAlarmId];
                                    activateAlarm();
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
                      hourValueAlarm = getHour(DateTime.now());
                      minuteValueAlarm = getMinute(DateTime.now());
                      _addAlarm(context);
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

  Scaffold widgetTimer() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Positioned(
                  child: Visibility(
                    visible: _isVisibleTimer,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding:
                              EdgeInsetsDirectional.only(top: height * 0.15),
                          child: SizedBox(
                            height: width * 0.7,
                            width: width * 0.7,
                            child: Stack(
                              children: [
                                Positioned(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      _remainingTime,
                                      style: TextStyle(
                                        fontSize: width * 0.12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  child: CircularStepProgressIndicator(
                                    totalSteps: 50,
                                    currentStep: _incrementProgressBar,
                                    selectedStepSize: 20,
                                    unselectedStepSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  child: Padding(
                    padding: EdgeInsetsDirectional.only(
                      top: height * 0.2,
                      bottom: height * 0.05,
                    ),
                    child: Visibility(
                      visible: !_isVisibleTimer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          NumberPicker(
                            value: _hourValue,
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
                                setState(() => _hourValue = value),
                          ),
                          SizedBox(
                            height: height * 0.3,
                            width: width * 0.002,
                            child: Container(
                              color: Colors.white38,
                            ),
                          ),
                          NumberPicker(
                            value: _minuteValue,
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
                                setState(() => _minuteValue = value),
                          ),
                          SizedBox(
                            height: height * 0.3,
                            width: width * 0.002,
                            child: Container(
                              color: Colors.white38,
                            ),
                          ),
                          NumberPicker(
                            value: _secondValue,
                            minValue: 0,
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
                                setState(() => _secondValue = value),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(top: height * 0.03),
              child: SizedBox(
                height: height * 0.15,
                child: Container(
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsetsDirectional.only(top: height * 0.03),
              child: Stack(
                children: [
                  Positioned(
                    child: Visibility(
                      visible: !_isVisibleTimer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _playButtonTImer,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: width * 0.1,
                              color: Colors.blue,
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                primary: Color.fromARGB(255, 44, 44, 44),
                                padding: EdgeInsets.all(10)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    child: Visibility(
                      visible: _isVisibleTimer,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Stack(
                            children: [
                              Positioned(
                                child: Visibility(
                                  visible: !_isVisiblePauseTimer,
                                  child: ElevatedButton(
                                    onPressed: _pauseButtonTImer,
                                    child: Icon(
                                      Icons.pause,
                                      size: width * 0.1,
                                      color: Colors.blue,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        primary:
                                            Color.fromARGB(255, 44, 44, 44),
                                        padding: EdgeInsets.all(10)),
                                  ),
                                ),
                              ),
                              Positioned(
                                child: Visibility(
                                  visible: _isVisiblePauseTimer,
                                  child: ElevatedButton(
                                    onPressed: _playPauseButtonTimer,
                                    child: Icon(
                                      Icons.play_arrow_rounded,
                                      size: width * 0.1,
                                      color: Colors.blue,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                        shape: CircleBorder(),
                                        primary:
                                            Color.fromARGB(255, 44, 44, 44),
                                        padding: EdgeInsets.all(10)),
                                  ),
                                ),
                              )
                            ],
                          ),
                          ElevatedButton(
                            onPressed: _stopButtonTimer,
                            child: Icon(
                              Icons.stop,
                              size: width * 0.1,
                              color: Colors.blue,
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                primary: Color.fromARGB(255, 44, 44, 44),
                                padding: EdgeInsets.all(10)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Scaffold widgetStopWatch() {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: Colors.black,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: height * 0.2,
            ),
            Text(
              stopWatchTimeString,
              style: TextStyle(fontSize: width * 0.14),
            ),
            SizedBox(
                height: height * 0.4,
                width: width,
                child: ListView.builder(
                    itemCount: lapTime.length,
                    itemBuilder: (context, index) {
                      int reverseIndex = lapTime.length - 1 - index;
                      return Card(
                        color: Colors.black,
                        elevation: 5,
                        shadowColor: Colors.white60,
                        child: ListTile(
                          leading: Icon(
                            Icons.flag_rounded,
                            color: Colors.white60,
                            size: width * 0.07,
                          ),
                          textColor: Colors.white,
                          title: Text(
                            lapTime[reverseIndex],
                            style: TextStyle(fontSize: width * 0.05),
                          ),
                          subtitle: Text(
                            lapNo[reverseIndex],
                            style: TextStyle(color: Colors.white60),
                          ),
                        ),
                      );
                    })),
            Padding(
              padding: EdgeInsetsDirectional.only(top: height * 0.05),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Positioned(
                        child: Visibility(
                          visible: _isVisibleStopWatch,
                          child: ElevatedButton(
                            onPressed: _playButtonStopWatch,
                            child: Icon(
                              Icons.play_arrow_rounded,
                              size: width * 0.1,
                              color: Colors.blue,
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: CircleBorder(),
                                primary: Color.fromARGB(255, 44, 44, 44),
                                padding: EdgeInsets.all(10)),
                          ),
                        ),
                      ),
                      Positioned(
                        child: Visibility(
                          visible: !_isVisibleStopWatch,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Stack(
                                children: [
                                  Visibility(
                                    visible: _isVisiblePauseStopWatch,
                                    child: ElevatedButton(
                                      onPressed: _flagButtonStopWatch,
                                      child: Icon(
                                        Icons.flag_rounded,
                                        size: width * 0.1,
                                        color: Colors.blue,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          primary:
                                              Color.fromARGB(255, 44, 44, 44),
                                          padding: EdgeInsets.all(10)),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !_isVisiblePauseStopWatch,
                                    child: ElevatedButton(
                                      onPressed: _stopButtonStopWatch,
                                      child: Icon(
                                        Icons.stop_rounded,
                                        size: width * 0.1,
                                        color: Colors.blue,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          primary:
                                              Color.fromARGB(255, 44, 44, 44),
                                          padding: EdgeInsets.all(10)),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: width * 0.2,
                              ),
                              Stack(
                                children: [
                                  Visibility(
                                    visible: _isVisiblePauseStopWatch,
                                    child: ElevatedButton(
                                      onPressed: _pauseButtonStopWatch,
                                      child: Icon(
                                        Icons.pause_rounded,
                                        size: width * 0.1,
                                        color: Colors.blue,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          primary:
                                              Color.fromARGB(255, 44, 44, 44),
                                          padding: EdgeInsets.all(10)),
                                    ),
                                  ),
                                  Visibility(
                                    visible: !_isVisiblePauseStopWatch,
                                    child: ElevatedButton(
                                      onPressed: _playPauseButtonStopWatch,
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        size: width * 0.1,
                                        color: Colors.blue,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                          shape: CircleBorder(),
                                          primary:
                                              Color.fromARGB(255, 44, 44, 44),
                                          padding: EdgeInsets.all(10)),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _addAlarm(BuildContext context) {
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
}
