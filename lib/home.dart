// ignore_for_file: prefer_const_constructors
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:watch_app/notifications.dart';

class WatchApp extends StatefulWidget {
  WatchApp({Key? key}) : super(key: key);

  @override
  State<WatchApp> createState() => _WatchAppState();
}

class _WatchAppState extends State<WatchApp> {
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
      s = 0;
  String _time = DateFormat("hh:mm:ss a").format(DateTime.now());
  bool _isVisible = false, _isVisiblePause = false;
  String _remainingTime = "";
  String _date = ("Date: " + DateFormat("dd/MM/yyyy").format(DateTime.now()));

  @override
  void initState() {
    super.initState();
    _time = DateFormat("hh:mm:ss a").format(DateTime.now());
    _isVisible = false;
    _isVisiblePause = false;
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
    _timerClock.cancel();
    _timerProgressBar.cancel();
    _timerRemainingTime.cancel();
    AwesomeNotifications().actionSink.close();
    AwesomeNotifications().dismissedSink.close();
    super.dispose();
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

  void _playButton() {
    setState(() {
      _timerTime = (_hourValue * 3600 + _minuteValue * 60 + _secondValue);
      _progressTime = _timerTime * 20;

      if (_timerTime > 0) {
        FlutterRingtonePlayer.stop();
        _isVisible = true;
        _isVisiblePause = false;
        _timerProgressBar = Timer.periodic(
            Duration(milliseconds: _progressTime), _updateProgressBar);
        h = _timerTime ~/ 3600;
        m = ((_timerTime - h * 3600)) ~/ 60;
        s = _timerTime - (h * 3600) - (m * 60);
        _remainingTime = "$h:$m:$s";
        _timerRemainingTime =
            Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
      }
    });
  }

  void _pauseButton() {
    setState(() {
      _isVisiblePause = true;
      _timerProgressBar.cancel();
      _timerRemainingTime.cancel();
    });
  }

  void _playPauseButton() {
    setState(() {
      _isVisiblePause = false;
      _timerProgressBar = Timer.periodic(
          Duration(milliseconds: _progressTime), _updateProgressBar);
      _timerRemainingTime =
          Timer.periodic(Duration(seconds: 1), _updateRemainingTime);
    });
  }

  void _stopButton() {
    setState(() {
      _isVisible = false;
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
        _remainingTime = "$h:$m:$s";
      });
    } else {
      _timerRemainingTime.cancel();
      _isVisible = false;
      _timerProgressBar.cancel();
      _incrementProgressBar = 50;
      _remainingTime = "";
      FlutterRingtonePlayer.playAlarm(volume: 1.0);
      createTimerNotifications();
    }
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
          Container(
            color: Colors.green,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.watch_later),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.hourglass_empty),
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
                  fontSize: width * 0.12,
                  color: Colors.white,
                ),
              ),
              Text(
                _date,
                style: TextStyle(
                  fontSize: width * 0.05,
                ),
              ),
              Stack(
                children: [
                  Positioned(
                    child: Padding(
                      padding: EdgeInsetsDirectional.only(top: 8.0),
                      child: Container(
                        height: height * 0.7,
                        width: width,
                        color: Colors.black,
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: true,
                          child: ListView.builder(
                            itemCount: 10,
                            itemBuilder: ((context, index) {
                              return Card(
                                elevation: 4,
                                color: Color.fromARGB(255, 40, 40, 40),
                                child: ListTile(
                                  minVerticalPadding: height * 0.02,
                                  title: Text(
                                    '07:40 am',
                                    style: TextStyle(
                                      fontSize: height * 0.04,
                                    ),
                                  ),
                                  subtitle:
                                      Text('Alarm in 9 hours and 5 minutes'),
                                  trailing: Switch(
                                      value: true, onChanged: ((value) {})),
                                ),
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      top: height * 0.8,
                      child: FloatingActionButton(
                        onPressed: () {},
                      ))
                ],
              ),
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
                    visible: _isVisible,
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
                      visible: !_isVisible,
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
                      visible: !_isVisible,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _playButton,
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
                    visible: _isVisible,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              child: Visibility(
                                visible: !_isVisiblePause,
                                child: ElevatedButton(
                                  onPressed: _pauseButton,
                                  child: Icon(
                                    Icons.pause,
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
                                visible: _isVisiblePause,
                                child: ElevatedButton(
                                  onPressed: _playPauseButton,
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
                            )
                          ],
                        ),
                        ElevatedButton(
                          onPressed: _stopButton,
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
                  ))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
