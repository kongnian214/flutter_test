import 'dart:async';
import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AudioReactiveSnapshot {
  final bool initialized;
  final bool playing;
  final double beatLevel;
  final double accentLevel;

  const AudioReactiveSnapshot({
    required this.initialized,
    required this.playing,
    required this.beatLevel,
    required this.accentLevel,
  });

  static const silent = AudioReactiveSnapshot(
    initialized: false,
    playing: false,
    beatLevel: 0,
    accentLevel: 0,
  );

  AudioReactiveSnapshot copyWith({
    bool? initialized,
    bool? playing,
    double? beatLevel,
    double? accentLevel,
  }) {
    return AudioReactiveSnapshot(
      initialized: initialized ?? this.initialized,
      playing: playing ?? this.playing,
      beatLevel: beatLevel ?? this.beatLevel,
      accentLevel: accentLevel ?? this.accentLevel,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudioReactiveSnapshot &&
        other.initialized == initialized &&
        other.playing == playing &&
        other.beatLevel == beatLevel &&
        other.accentLevel == accentLevel;
  }

  @override
  int get hashCode =>
      Object.hash(initialized, playing, beatLevel, accentLevel);
}

class FestiveAudioController extends ChangeNotifier {
  FestiveAudioController();

  final AudioPlayer _bgmPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();

  AudioReactiveSnapshot _snapshot = AudioReactiveSnapshot.silent;
  AudioReactiveSnapshot get snapshot => _snapshot;

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _initializing = false;
  double _accentLevel = 0;

  Future<void> initialize() async {
    if (_snapshot.initialized || _initializing) return;
    _initializing = true;
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      await _bgmPlayer.setLoopMode(LoopMode.all);
      await _bgmPlayer.setAudioSource(
        AudioSource.asset('assets/audio/christmas_theme.mp3'),
      );
      await _bgmPlayer.setVolume(.65);
      _positionSubscription =
          _bgmPlayer.positionStream.listen(_handlePosition);
      _playerStateSubscription =
          _bgmPlayer.playerStateStream.listen(_handlePlayerState);
      _updateSnapshot(initialized: true, playing: false);
    } catch (error, stack) {
      debugPrint('FestiveAudioController init error: $error\n$stack');
      _updateSnapshot(initialized: true, playing: false);
    } finally {
      _initializing = false;
    }
  }

  void _handlePosition(Duration position) {
    final seconds = position.inMilliseconds / 1000;
    const bpm = 84 / 60;
    final beat = (math.sin(seconds * bpm * math.pi * 2) + 1) / 2;
    _accentLevel *= .92;
    _updateSnapshot(beatLevel: beat, accentLevel: _accentLevel);
  }

  void _handlePlayerState(PlayerState state) {
    _updateSnapshot(playing: state.playing, initialized: true);
  }

  Future<void> setBgmEnabled(bool enabled) async {
    if (enabled) {
      await _bgmPlayer.play();
    } else {
      await _bgmPlayer.pause();
    }
  }

  Future<void> triggerBellAccent() async {
    _accentLevel = 1;
    _updateSnapshot(accentLevel: _accentLevel);
    try {
      await _effectPlayer.setAudioSource(
        AudioSource.asset('assets/audio/effect_bell.wav'),
      );
      await _effectPlayer.setVolume(.9);
      await _effectPlayer.play();
    } catch (error, stack) {
      debugPrint('Bell accent playback failed: $error\n$stack');
    }
  }

  bool get isBgmPlaying => _bgmPlayer.playing;

  void _updateSnapshot({
    bool? initialized,
    bool? playing,
    double? beatLevel,
    double? accentLevel,
  }) {
    final next = _snapshot.copyWith(
      initialized: initialized,
      playing: playing,
      beatLevel: beatLevel,
      accentLevel: accentLevel,
    );
    if (next == _snapshot) return;
    _snapshot = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _bgmPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }
}

final festiveAudioControllerProvider =
    ChangeNotifierProvider<FestiveAudioController>((ref) {
      final controller = FestiveAudioController();
      // Fire and forget initialization; controller guards against repeats.
      unawaited(controller.initialize());
      return controller;
    });
