import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math';

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
          title: Text('Welcome to CSF Alarm'),
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
  int duration = 0;
  Timer counter;
  AudioPlayer currentPlayer;
  BuildContext context;

  static AudioCache player = new AudioCache();
  static const alarmAudioPath = "alarm.mp3";

  @override
  Widget build(BuildContext context) {
    this.context = context;
    if (counter == null) {
      counter = new Timer.periodic(Duration(seconds: 1), handleTimeout);
    }
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text("Time to alarm: ${Duration(seconds: duration)}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                FlatButton(
                    onPressed: () {
                      DatePicker.showTimePicker(context, showTitleActions: true,
                          onConfirm: (date) {
                        setState(() {
                          duration = date.second;
                        });
                      }, currentTime: DateTime.now());
                    },
                    child: Text('Setup alarm')),
                FlatButton(
                  onPressed: () {

                    stopAlarm();
                  },
                  child: Text("Stop alarm"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void handleTimeout(Timer timer) {
    if (duration == 1) {
      showStopDialog();
      startAlarm();
      setState(() {
        duration = 0;
      });
    } else if (duration > 1) {
      setState(() {
        duration--;
      });
    }
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
            title: const Text("Let's to stop it!", textAlign: TextAlign.center,),
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

//              Row(
//                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                  children: <Widget>[
//                    FlatButton(
//                      onPressed: () {
//                        stopAlarm();
//                        Navigator.pop(context);
//                      },
//                      child: const Text('Stop'),
//                    ),
//                  ])
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

  void startAlarm() {
    player
        .loop(alarmAudioPath, mode: PlayerMode.LOW_LATENCY)
        .then((currentPlayer) {
      this.currentPlayer = currentPlayer;
    });
  }

  void stopAlarm() {
    if (currentPlayer != null) {
      currentPlayer.stop();
    }
    setState(() {
      duration = 0;
    });
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
}

class Alarm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AlarmState();
}
