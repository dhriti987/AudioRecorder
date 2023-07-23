import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:animate_icons/animate_icons.dart';

class FancyFab extends StatefulWidget {
  const FancyFab({super.key});

  @override
  State<FancyFab> createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab> with TickerProviderStateMixin {
  bool isOpened = false;
  // bool _play = false;
  bool _isRecorderReady = false;
  final Curve _curve = Curves.easeOut;
  final double _fabHeight = 56.0;
  late AnimationController _animationController;
  late AnimationController _animationController2;
  late Animation<Color?> _buttonColor;
  late AnimateIconController _animateIcon;
  late Animation<double> _translateButton;
  late FlutterSoundRecorder _recorder;

  @override
  initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animationController2 = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        setState(() {});
      });
    _animateIcon = AnimateIconController();
    _buttonColor = ColorTween(
      begin: Colors.green,
      end: Colors.blue,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    _recorder = FlutterSoundRecorder();
    initRecorder();
    super.initState();
  }

  Future initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw "Permission not Granted";
    }
    await _recorder.openRecorder();
    _isRecorderReady = true;
  }

  @override
  dispose() {
    _animationController.dispose();
    _animationController2.dispose();
    _recorder.closeRecorder();
    _isRecorderReady = false;
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController2.forward();
      _animationController.forward();
      // _play = true;
      startRecording();
    } else {
      _animationController2.reverse();
      _animationController.reverse();
      // _play = false;
      stopRecorading();
    }
    isOpened = !isOpened;
  }

  Future<String> getPath() async {
    var directory = await getExternalStorageDirectory();
    var directoryPath = directory!.path;
    return "$directoryPath/${DateTime.now().millisecondsSinceEpoch}.wav";
  }

  Future startRecording() async {
    var path = await getPath();
    await _recorder.startRecorder(toFile: path, codec: Codec.pcm16WAV);
  }

  Future stopRecorading() async {
    await _recorder.stopRecorder();
  }

  Future pauseRecording() async {
    await _recorder.pauseRecorder();
  }

  Future resumeRecording() async {
    await _recorder.resumeRecorder();
  }

  // Widget add() {
  //   return const FloatingActionButton(
  //     onPressed: null,
  //     tooltip: 'Add',
  //     child: Icon(Icons.add),
  //   );
  // }

  Widget pause() {
    return FloatingActionButton(
      heroTag: "btn1",
      backgroundColor: Colors.red,
      onPressed: animate,
      tooltip: 'STop',
      child: const Icon(Icons.stop),
    );
  }

  Widget toggle() {
    return FloatingActionButton(
        heroTag: "btn2",
        backgroundColor: _buttonColor.value,
        onPressed: () {
          // if (!_isRecorderReady) return;
          // if (isOpened) {
          //   if (_play) {
          //     _play = false;
          //     _animationController2.reverse();
          //     pauseRecording();
          //   } else {
          //     _play = true;
          //     _animationController2.forward();
          //     resumeRecording();
          //   }
          // } else {
          //   animate();
          // }
        },
        tooltip: 'Toggle',
        child: AnimateIcons(
          controller: _animateIcon,
          startIcon: Icons.mic,
          endIcon: Icons.pause,
          startIconColor: Colors.white,
          endIconColor: Colors.white,
          onStartIconPress: () {
            if (!_isRecorderReady) return false;
            if (isOpened) {
              _animationController2.forward();
              resumeRecording();
            } else {
              animate();
            }
            return true;
          },
          onEndIconPress: () {
            if (!_isRecorderReady) return false;
            if (isOpened) {
              _animationController2.reverse();
              pauseRecording();
            } else {
              animate();
            }
            return true;
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: pause(),
        ),
        toggle(),
      ],
    );
  }
}
