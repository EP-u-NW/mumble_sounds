import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mumble_sounds/mumble_sounds.dart';

const String WARNING =
    '''WARNING: This example only runs on Windows and requires ffplay (from ffmpeg) to be in your PATH!''';
void main() {
  print(WARNING);
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

Future<void> _ffplay(Stream<List<int>> data) async {
  Process p =
      await Process.start('ffplay', ['-i', '-', '-nodisp', '-autoexit']);
  p.stdout.transform(ascii.decoder).drain();
  p.stderr.transform(ascii.decoder).drain();
  await p.stdin.addStream(data);
  await p.stdin.close();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mumble Sounds Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Mumble Sounds Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const List<SoundSample> _allSamples = const [
    SoundSample.critical,
    SoundSample.off,
    SoundSample.on,
    SoundSample.permissionDenied,
    SoundSample.recordingStateChanged,
    SoundSample.selfMutedDeafened,
    SoundSample.serverConnected,
    SoundSample.serverDisconnected,
    SoundSample.textMessage,
    SoundSample.userJoinedChannel,
    SoundSample.userKickedYouOrByYou,
    SoundSample.userLeftChannel,
    SoundSample.userMutedYouOrByYou
  ];

  bool _playing = false;
  SoundSample _current = _allSamples[0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: [
            Text(WARNING),
            DropdownButton<SoundSample>(
              value: _current,
              items: _allSamples
                  .map((SoundSample s) => DropdownMenuItem<SoundSample>(
                        child: Text(s.name),
                        value: s,
                      ))
                  .toList(),
              onChanged: (SoundSample? sample) {
                setState(() {
                  _current = sample!;
                });
              },
            ),
            Text(
                'Select a sound from the drop down and press the play button to play it.'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: _playing ? null : () => _playCurrent(context),
          tooltip: _playing ? 'Wait for play to end' : 'Play',
          child: Icon(Icons.play_arrow)),
    );
  }

  void _playCurrent(BuildContext context) {
    if (!_playing) {
      Stream<List<int>> stream = _current.stream(context: context);
      _ffplay(stream).then((_) => {
            setState(() {
              _playing = false;
            })
          });
      setState(() {
        _playing = true;
      });
    }
  }
}
