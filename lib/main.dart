import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/*
 * Alarm example: https://github.com/Yahhi/pomodoro_on_flutter
 */
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Tik-Tak Alarm'),
        ),
        body: Center(
          child: Alarm(),
        ),
      ),
    );
  }
}

class AlarmState extends State<Alarm> {
  String alarmingText = "Alarm!";
  Duration timeToAlarm;
  TimeOfDay alarmTime;
  Timer counter;
  AudioPlayer currentPlayer;
  BuildContext context;

  static AudioCache player = new AudioCache();
  static const _alarmAudioPath = "alarm.mp3";
  static const _timePrefName = "timePref";


  @override
  Widget build(BuildContext context) {
    this.context = context;
    if (counter == null) {
      initTime();
      counter = new Timer.periodic(Duration(seconds: 1), handleTick);
    }
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Column(
                  children: <Widget>[
                    Text("Time to alarm", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue.shade900
                    )),
                    Text("${formatDuration(timeToAlarm)}", style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade900
                    )),
                  ]
              ),
              Column(
                  children: <Widget>[
                    Text("Alarm time", style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Colors.blue.shade900
                    )),
                    Text("${formatTimeOfDay(alarmTime)}", style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade900
                    )),
                  ]
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  RaisedButton(
                      onPressed: () {
                        DatePicker.showTimePicker(
                            context, showTitleActions: true,
                            onConfirm: setAlarmTime,
                            currentTime: DateTime.now());
                      },
                      child: Text(
                        'Setup alarm',
                        style: TextStyle(
                            fontSize: 16
                        ),
                      ),
                      color: Colors.blue.shade400
                  ),
                  RaisedButton(
                    onPressed: () {
                      stopAlarm();
                    },
                    child: Text("Stop alarm",
                      style: TextStyle(
                          fontSize: 16
                      ),),
                    color: Colors.orange.shade400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void initTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String alarmTimeRaw = prefs.getString(_timePrefName);
    if (alarmTimeRaw == null) {
      return;
    }
    setState(() {
      alarmTime = TimeOfDay.fromDateTime(DateTime.parse(alarmTimeRaw));
      timeToAlarm = getTimeToAlarm();
    });
  }

  void setAlarmTime(DateTime time) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timePrefName, time.toString());
    setState(() {
      alarmTime = TimeOfDay.fromDateTime(time);
      timeToAlarm = getTimeToAlarm();
    });
  }

  void handleTick(Timer timer) {
    Duration nextTimeToAlarm = getTimeToAlarm();
    if (nextTimeToAlarm.inSeconds == 0) {
      startAlarm();
      showStopDialog();
    }
    setState(() {
      timeToAlarm = nextTimeToAlarm;
    });
  }

  void startAlarm() {
    player
        .loop(_alarmAudioPath, mode: PlayerMode.LOW_LATENCY)
        .then((currentPlayer) {
      this.currentPlayer = currentPlayer;
    });
  }

  final _text = TextEditingController();

  void showStopDialog() async {
    var rnd = new Random();
    int a = rnd.nextInt(100);
    int b = rnd.nextInt(100);
    String trueAns = (a + b).toString();

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text(
              "Let's to stop it!", textAlign: TextAlign.center,),
            children: <Widget>[
              Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text("How much is $a + $b?"),
                    new TextField(
                      controller: _text,
                      onChanged: (a) => checkAnswer(trueAns, context),
                      style: new TextStyle(fontSize: 15.0, color: Colors.black),
                      decoration: new InputDecoration(
                          hintText: "Answer",
                          labelStyle: TextStyle(fontWeight: FontWeight.w700),
                          contentPadding: const EdgeInsets.all(20.0)),
                      autofocus: true,
                      keyboardType:
                      TextInputType.numberWithOptions(signed: true),

                    )
                  ]),
            ],
          );
        });
  }

  void checkAnswer(String trueAnswer, BuildContext context) {
    if (_text.text == trueAnswer) {
      stopAlarm();
      _text.clear();
      Navigator.pop(context);
    } else {
      if (trueAnswer.length == _text.text.length) _text.clear();
    }
  }

  void stopAlarm() {
    if (currentPlayer != null) {
      currentPlayer.stop();
    }
    Fluttertoast.showToast(
        msg: "Great!🏆 Wake up ASAP",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }

  Duration getTimeToAlarm() {
    Duration now = durationFromDateTime(DateTime.now());
    Duration alarmDuration = durationFromTimeOfDate(alarmTime);
    Duration diff = alarmDuration - now;
    if (diff.isNegative) {
      Duration nextDayAlarmTime = alarmDuration + Duration(days: 1);
      return nextDayAlarmTime - now;
    }
    return diff;
  }

  int secondsFromDateTime(DateTime time) {
    return time.hour * Duration.secondsPerHour +
        time.minute * Duration.secondsPerMinute + time.second;
  }

  Duration durationFromDateTime(DateTime time) {
    return Duration(
        hours: time.hour, minutes: time.minute, seconds: time.second
    );
  }

  String formatDuration(Duration duration) {
    if (duration == null) {
      return "never";
    }
    //hack
    return duration.toString().substring(0, 8).replaceAll(".", "");
  }

  String formatTimeOfDay(TimeOfDay timeOfDay) {
    if (timeOfDay == null) {
      return "never";
    }
    final now = new DateTime.now();
    final date = DateTime(
        now.year, now.month, now.day, timeOfDay.hour, timeOfDay.minute);
    return new DateFormat('hh:mm').format(date);
  }

  Duration durationFromTimeOfDate(TimeOfDay timeOfDay) {
    return Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute);
  }
}

class Alarm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AlarmState();
}
