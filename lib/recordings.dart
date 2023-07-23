import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'api.dart' as api;

class RecordingsList extends StatefulWidget {
  const RecordingsList({super.key});

  @override
  State<RecordingsList> createState() => _RecordingsListState();
}

class _RecordingsListState extends State<RecordingsList> {
  String directory = "";
  List<FileSystemEntity> files = List.empty();
  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  void _listofFiles() async {
    directory = (await getExternalStorageDirectory())!.path;
    setState(() {
      files = Directory("$directory/")
          .listSync(); //use your folder name insted of resume.
    });
  }

  GlobalKey key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: RefreshIndicator(
        onRefresh: () async {
          _listofFiles();
        },
        child: ListView.separated(
            key: key,
            itemCount: files.length,
            separatorBuilder: (context, index) => const SizedBox(
                  height: 5,
                ),
            itemBuilder: (BuildContext context, int index) {
              final String fileName = files[index].path.split("/").last;
              final file = File(files[index].path);
              DateTime date = file.lastModifiedSync();
              TextEditingController fileNameController =
                  TextEditingController(text: fileName);
              return Dismissible(
                key: UniqueKey(),
                onDismissed: (direction) {
                  files[index].delete();
                  files.removeAt(index);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("$fileName is Deleted"),
                    duration: const Duration(seconds: 1),
                  ));
                },
                background: Container(color: Colors.red),
                child: ListTile(
                  tileColor: Colors.yellow,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40)),
                  // textColor: Colors.white,
                  title: Text(fileName),
                  subtitle: Text(DateFormat("HH:mm dd/MM/yy").format(date)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_library_books,
                        color: Colors.black,
                        size: 30,
                      ),
                      Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: 35,
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        opaque: false,
                        pageBuilder: (context, _, __) => MyAudioPlayer(
                          file: file,
                        ),
                      ),
                    );
                  },
                  onLongPress: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Rename File"),
                        content: TextField(
                          controller: fileNameController,
                        ),
                        actions: [
                          ElevatedButton(
                            child: Text('CANCEL'),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          ElevatedButton(
                            child: Text('OK'),
                            onPressed: () {
                              print(fileNameController.text);
                              var path = file.path;
                              var lastSeperator =
                                  path.lastIndexOf(Platform.pathSeparator);
                              var newPath =
                                  path.substring(0, lastSeperator + 1) +
                                      fileNameController.text;
                              file.renameSync(newPath);
                              setState(() {
                                _listofFiles();
                              });
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
      ),
    );
  }
}

class MyAudioPlayer extends StatefulWidget {
  const MyAudioPlayer({
    super.key,
    required this.file,
  });
  final File file;

  @override
  State<MyAudioPlayer> createState() => _MyAudioPlayerState();
}

class _MyAudioPlayerState extends State<MyAudioPlayer> {
  bool _transcribe = false;

  toTranscribe() {
    _transcribe = !_transcribe;
    setState(() {
      print(_transcribe);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white30,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Player(file: widget.file, notifyTranscribe: toTranscribe),
                    _transcribe
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: SingleChildScrollView(
                                child: FutureBuilder(
                                  future: api.transcribe(widget.file),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return snapshot.data!;
                                    }
                                    return LoadingIndicator(
                                        indicatorType: Indicator.ballPulse);
                                  },
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}

class Player extends StatefulWidget {
  const Player({
    super.key,
    required this.file,
    required this.notifyTranscribe,
  });

  final Function() notifyTranscribe;
  final File file;

  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final _player = AudioPlayer();
  bool _isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    setAudio();

    _player.onPlayerStateChanged.listen((event) {
      setState(() {
        _isPlaying = event == PlayerState.playing;
      });
    });

    _player.onDurationChanged.listen((event) {
      setState(() {
        duration = event;
      });
    });

    _player.onPositionChanged.listen((event) {
      setState(() {
        position = event;
      });
    });

    super.initState();
  }

  // @override
  // void dispose() async {
  //   await _player.stop();
  //   super.dispose();
  // }

  Future setAudio() async {
    await _player.play(DeviceFileSource(widget.file.path));
    _player.setReleaseMode(ReleaseMode.loop);
  }

  String formatTime(Duration time) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(time.inHours);
    final min = twoDigits(time.inMinutes.remainder(60));
    final seconds = twoDigits(time.inSeconds.remainder(60));

    return [if (time.inHours > 0) hours, min, seconds].join(":");
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      Text(widget.file.path.split('/').last),
      Slider(
        min: 0,
        max: duration.inSeconds.toDouble(),
        value: position.inSeconds.toDouble(),
        onChanged: (value) async {
          position = Duration(seconds: value.toInt());
          await _player.seek(position);
          await _player.resume();
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(formatTime(position)), Text(formatTime(duration))],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              widget.notifyTranscribe();
            },
            icon: const Icon(Icons.transcribe),
          ),
          IconButton(
            onPressed: () async {
              if (_isPlaying) {
                await _player.pause();
              } else {
                await _player.resume();
              }
            },
            icon: _isPlaying
                ? const Icon(Icons.pause)
                : const Icon(Icons.play_arrow),
          ),
          IconButton(
              onPressed: () async {
                await _player.stop();
                if (!mounted) return;
                Navigator.pop(context);
              },
              icon: const Icon(Icons.close))
        ],
      ),
    ]);
  }
}
