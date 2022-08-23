import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';

class stopwatch extends StatefulWidget {
  const stopwatch({key});

  @override
  State<stopwatch> createState() => _stopwatchState();
}

int counter = 1;
bool _isVisibleStopWatch = true,
    _isVisiblePauseStopWatch = true,
    switchBool = true,
    onTapBool = false;
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

class _stopwatchState extends State<stopwatch> {
  static int _stopWatchTime = 0;

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
    stopWatchTimeList.add(_stopWatchTime);
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

  static String _printDurationMMSSmm(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds =
        twoDigits(duration.inMilliseconds.remainder(100));
    return "${twoDigits(duration.inMinutes)}:$twoDigitSeconds:$twoDigitMilliseconds";
  }

  @override
  Widget build(BuildContext context) {
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
}
