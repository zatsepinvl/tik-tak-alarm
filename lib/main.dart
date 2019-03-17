import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

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
          title: Text('Welcome to Flutter'),
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

  static AudioCache player = new AudioCache();
  static const alarmAudioPath = "alarm.mp3";

  @override
  Widget build(BuildContext context) {
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
                          },
                          currentTime: DateTime.now()
                      );
                    },
                    child: Text('Setup alarm')
                ),
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
      startAlarm();
      setState(() {
        duration = 0;
      });
    }
    else if (duration > 1) {
      setState(() {
        duration--;
      });
    }
  }

  void startAlarm() {
    player.loop(alarmAudioPath, mode: PlayerMode.LOW_LATENCY)
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
  }
}

class Alarm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new AlarmState();
}
