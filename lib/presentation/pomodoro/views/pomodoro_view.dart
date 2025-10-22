import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';

import 'package:e_learning_mobile/common/helpers/local_notification_service.dart';

class PomodoroPage extends StatefulWidget {
  const PomodoroPage({super.key});

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  final _focusController = TextEditingController(text: '25');
  final _relaxController = TextEditingController(text: '5');

  Duration _totalDuration = const Duration(minutes: 25);
  Duration _remaining = const Duration(minutes: 25);
  Timer? _timer;
  bool _isRunning = false;
  bool _isFocus = true;

  final _player = AudioPlayer();
  String? _pickedPath;
  final ValueNotifier<double> _progressNotifier = ValueNotifier(0.0);

  @override
  void initState() {
    super.initState();
    LocalNotificationService.init();
    // create channel for pomodoro notifications (android)
    LocalNotificationService.createAndroidNotificationChannel(
      id: 'pomodoro_channel',
      title: 'Pomodoro',
      description: 'Pomodoro timer notifications',
    );
    _updateDurations();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _player.dispose();
    _focusController.dispose();
    _relaxController.dispose();
    super.dispose();
  }

  void _updateDurations() {
    final focusMin = int.tryParse(_focusController.text) ?? 25;
    final d = Duration(minutes: focusMin);
    setState(() {
      _totalDuration = d;
      if (!_isRunning) {
        _remaining = d;
      }
      _progressNotifier.value = _totalDuration.inSeconds == 0
          ? 0.0
          : (1 - (_remaining.inSeconds / _totalDuration.inSeconds)) * 100;
    });
  }

  Future<void> _pickAudio() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _pickedPath = result.files.single.path!;
      });
      try {
        await _player.setFilePath(_pickedPath!);
      } catch (e) {
        // ignore errors from unsupported files
      }
    }
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });

    // play background audio if available
    if (_pickedPath != null) {
      _player.setLoopMode(LoopMode.one);
      _player.play();
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining.inSeconds <= 1) {
        t.cancel();
        _onTimerFinish();
      } else {
        setState(() {
          _remaining = Duration(seconds: _remaining.inSeconds - 1);
          _progressNotifier.value = _totalDuration.inSeconds == 0
              ? 0.0
              : (1 - (_remaining.inSeconds / _totalDuration.inSeconds)) * 100;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _player.pause();
    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _onTimerFinish() async {
    _player.pause();

    // send local notification
    await LocalNotificationService.showNotification(
      title: _isFocus ? 'Focus complete' : 'Relax complete',
      body: _isFocus ? 'Time to take a break!' : 'Ready to focus again!',
      channelId: 'pomodoro_channel',
      channelName: 'Pomodoro',
    );

    // play an alarm sound if available (try picked path, else system)
    if (_pickedPath != null && File(_pickedPath!).existsSync()) {
      try {
        await _player.setFilePath(_pickedPath!);
        await _player.setLoopMode(LoopMode.off);
        await _player.play();
      } catch (_) {}
    }

    setState(() {
      _isRunning = false;
      // switch mode
      _isFocus = !_isFocus;
      final nextMin = _isFocus
          ? int.tryParse(_focusController.text) ?? 25
          : int.tryParse(_relaxController.text) ?? 5;
      _totalDuration = Duration(minutes: nextMin);
      _remaining = _totalDuration;
      _progressNotifier.value = 0.0;
    });
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SimpleCircularProgressBar(
              size: 180,
              progressColors: _isFocus
                  ? const [Colors.red, Colors.orange]
                  : const [Colors.green, Colors.lightGreen],
              backColor: Colors.black12,
              valueNotifier: _progressNotifier,
              onGetText: (value) => Text(_format(_remaining),
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _focusController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Focus (minutes)'),
                    onChanged: (_) => _updateDurations(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _relaxController,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Relax (minutes)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickAudio,
                  icon: const Icon(Icons.music_note),
                  label: const Text('Pick background sound'),
                ),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(_pickedPath == null
                        ? 'No track selected'
                        : _pickedPath!.split(Platform.pathSeparator).last)),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _pauseTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                  ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _timer?.cancel();
                    _player.stop();
                    setState(() {
                      _isRunning = false;
                      _isFocus = true;
                      _updateDurations();
                    });
                  },
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop'),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
