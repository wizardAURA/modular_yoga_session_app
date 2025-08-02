import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:modular_yoga_session_app/models/yoga_session.dart';

class SessionProvider extends ChangeNotifier {
  late YogaSession _session;
  bool _hasSession = false;

  int _currentSeqIdx = 0;
  int _currentLoopIteration = 0;
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isSessionComplete = false;
  Duration _poseElapsed = Duration.zero;

  Duration _elapsedBeforePause = Duration.zero; // Accumulated elapsed before pause

  Timer? _timer;
  DateTime? _poseStartTime;

  final AudioPlayer _audioPlayer = AudioPlayer();

  bool get isInitialized => _hasSession;

  List<SequenceItem> get sequence => _hasSession ? _session.sequence : [];
  Metadata? get metadata => _hasSession ? _session.metadata : null;
  Assets? get assets => _hasSession ? _session.assets : null;

  SequenceItem get currentItem {
    if (!_hasSession) {
      throw Exception("Session data not loaded yet.");
    }
    return sequence[_currentSeqIdx];
  }

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isSessionComplete => _isSessionComplete;
  Duration get elapsed => _poseElapsed;

  Future<void> loadSessionFromAsset(String assetPath) async {
    final data = await rootBundle.loadString(assetPath);
    final jsonMap = json.decode(data);

    final metadata = Metadata.fromJson(jsonMap['metadata']);
    final assets = Assets.fromJson(jsonMap['assets']);
    final rawSequence = (jsonMap['sequence'] as List)
        .map((e) => SequenceItem.fromJson(e))
        .toList();

    final sequence = rawSequence.map((item) {
      final iter = item.iterations;
      int actualIterations = 1;
      if (iter is String && iter == "{{loopCount}}") {
        actualIterations = metadata.defaultLoopCount;
      } else if (iter is int) {
        actualIterations = iter;
      }
      return SequenceItem(
        type: item.type,
        name: item.name,
        audioRef: item.audioRef,
        durationSec: item.durationSec,
        iterations: actualIterations,
        loopable: item.loopable,
        script: item.script,
      );
    }).toList();

    _session = YogaSession(metadata: metadata, assets: assets, sequence: sequence);

    _currentSeqIdx = 0;
    _currentLoopIteration = 0;
    _isPlaying = false;
    _isPaused = false;
    _isSessionComplete = false;
    _poseElapsed = Duration.zero;
    _elapsedBeforePause = Duration.zero; // reset on new load

    _hasSession = true;
    notifyListeners();
  }

  void startSession() {
    if (!_hasSession || sequence.isEmpty) return;

    _isPlaying = true;
    _isPaused = false;
    _isSessionComplete = false;
    _currentSeqIdx = 0;
    _currentLoopIteration = 0;
    _poseElapsed = Duration.zero;
    _elapsedBeforePause = Duration.zero;

    _startCurrentSequence();
    notifyListeners();
  }

  void _startCurrentSequence() async {
    _timer?.cancel();
    _poseElapsed = Duration.zero;
    _elapsedBeforePause = Duration.zero;
    _poseStartTime = DateTime.now();

    final item = currentItem;
    final audioFileName = assets?.audio[item.audioRef] ?? '';
    final audioPath = audioFileName.isNotEmpty ? 'audio/$audioFileName' : '';

    await _audioPlayer.stop();
    if (audioPath.isNotEmpty) {
      await _audioPlayer.play(AssetSource(audioPath));
    }

    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!_isPlaying || _isPaused) return;

      _poseElapsed = _elapsedBeforePause + DateTime.now().difference(_poseStartTime!);

      if (_poseElapsed.inSeconds >= item.durationSec) {
        _advanceSequence();
      }

      notifyListeners();
    });
  }

  void pauseSession() {
    if (!_isPlaying || _isPaused) return;

    _audioPlayer.pause();
    _timer?.cancel();

    // accumulate elapsed time till pause
    _elapsedBeforePause += DateTime.now().difference(_poseStartTime!);

    _isPaused = true;
    notifyListeners();
  }

  void resumeSession() {
    if (!_isPlaying || !_isPaused) return;

    _isPaused = false;
    // reset start time to now, accumulate elapsed added in timer
    _poseStartTime = DateTime.now();

    _audioPlayer.resume();

    _timer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!_isPlaying || _isPaused) return;

      _poseElapsed = _elapsedBeforePause + DateTime.now().difference(_poseStartTime!);

      if (_poseElapsed.inSeconds >= currentItem.durationSec) {
        _advanceSequence();
      }

      notifyListeners();
    });

    notifyListeners();
  }

  void skipPose() async {
    if (!_isPlaying) return;

    await _audioPlayer.stop();
    _timer?.cancel();

    _advanceSequence();
    notifyListeners();
  }

  void _advanceSequence() {
    final item = currentItem;

    if (item.type == 'loop') {
      _currentLoopIteration++;
      if (_currentLoopIteration < (item.iterations ?? 1)) {
        _startCurrentSequence();
        notifyListeners();
        return;
      } else {
        _currentLoopIteration = 0;
      }
    }

    if (_currentSeqIdx < sequence.length - 1) {
      _currentSeqIdx++;
      _startCurrentSequence();
    } else {
      _isPlaying = false;
      _isSessionComplete = true;
      _timer?.cancel();
      _audioPlayer.stop();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
