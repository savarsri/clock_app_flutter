import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:watch_app/Functions/functions.dart';
import '../Functions/notifications.dart';
import 'package:watch_app/Functions/notifications.dart';
import 'dart:async';

class watchTimer extends StatefulWidget {
  watchTimer({Key? key}) : super(key: key);

  @override
  State<watchTimer> createState() => _watchTimerState();
}

int _hourValue = 0,
    _minuteValue = 0,
    _secondValue = 0,
    _timerTime = 0,
    _incrementProgressBar = 50,
    _progressTime = 0,
    h = 0,
    m = 0,
    s = 0;

String _remainingTime = "", notification = "";
Timer _timerRemainingTime =
    Timer.periodic(Duration(milliseconds: _progressTime), nothing);
Timer _timerProgressBar =
    Timer.periodic(Duration(milliseconds: _progressTime), nothing);
bool _isVisibleTimer = false, _isVisiblePauseTimer = false;

void nothing(Timer _) {}

class _watchTimerState extends State<watchTimer> {
  @override
  void initState() {
    super.initState();
    _isVisibleTimer = false;
    _isVisiblePauseTimer = false;
  }

  @override
  void dispose() {
    super.dispose();
    _timerProgressBar.cancel();
    _timerRemainingTime.cancel();
  }

  void _playButtonTImer() {
    setState(() {
      _timerTime = (_hourValue * 3600 + _minuteValue * 60 + _secondValue);
      _progressTime = _timerTime * 20;

      if (_timerTime > 0) {
        functions().stopAlarmRingtone();
        _isVisibleTimer = true;
        _isVisiblePauseTimer = false;
        _timerProgressBar = Timer.periodic(
            Duration(milliseconds: _progressTime), _updateProgressBar);
        h = _timerTime ~/ 3600;
        m = ((_timerTime - h * 3600)) ~/ 60;
        s = _timerTime - (h * 3600) - (m * 60);
        _remainingTime =
            functions().printDurationHHMMSS(Duration(seconds: _timerTime));
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
    functions().stopAlarmRingtone();
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
        _remainingTime =
            functions().printDurationHHMMSS(Duration(seconds: _timerTime));
      });
    } else {
      _timerRemainingTime.cancel();
      _isVisibleTimer = false;
      _timerProgressBar.cancel();
      _incrementProgressBar = 50;
      _remainingTime = "";
      functions().playAlarmRingtone();
      createTimerNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                height: height * 0.185,
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
}
