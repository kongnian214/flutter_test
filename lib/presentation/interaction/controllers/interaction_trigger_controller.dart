import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../stage/controllers/stage_experience_controller.dart';

class InteractionTriggerState {
  final double micLevel;
  final bool microphoneGranted;
  final bool voiceListening;
  final bool voiceEnabled;
  final bool shakeEnabled;
  final bool longPressEnabled;
  final double voiceThreshold;
  final double shakeMagnitude;
  final DateTime? lastVoiceTrigger;
  final DateTime? lastShakeTrigger;

  const InteractionTriggerState({
    this.micLevel = 0,
    this.microphoneGranted = false,
    this.voiceListening = false,
    this.voiceEnabled = true,
    this.shakeEnabled = true,
    this.longPressEnabled = true,
    this.voiceThreshold = 60,
    this.shakeMagnitude = 18,
    this.lastVoiceTrigger,
    this.lastShakeTrigger,
  });

  InteractionTriggerState copyWith({
    double? micLevel,
    bool? microphoneGranted,
    bool? voiceListening,
    bool? voiceEnabled,
    bool? shakeEnabled,
    bool? longPressEnabled,
    double? voiceThreshold,
    double? shakeMagnitude,
    DateTime? lastVoiceTrigger,
    DateTime? lastShakeTrigger,
  }) {
    return InteractionTriggerState(
      micLevel: micLevel ?? this.micLevel,
      microphoneGranted: microphoneGranted ?? this.microphoneGranted,
      voiceListening: voiceListening ?? this.voiceListening,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      shakeEnabled: shakeEnabled ?? this.shakeEnabled,
      longPressEnabled: longPressEnabled ?? this.longPressEnabled,
      voiceThreshold: voiceThreshold ?? this.voiceThreshold,
      shakeMagnitude: shakeMagnitude ?? this.shakeMagnitude,
      lastVoiceTrigger: lastVoiceTrigger ?? this.lastVoiceTrigger,
      lastShakeTrigger: lastShakeTrigger ?? this.lastShakeTrigger,
    );
  }
}

class InteractionTriggerController
    extends StateNotifier<InteractionTriggerState> {
  InteractionTriggerController(this._ref)
      : super(const InteractionTriggerState());

  final Ref _ref;
  final NoiseMeter _noiseMeter = NoiseMeter();
  StreamSubscription<NoiseReading>? _noiseSubscription;
  StreamSubscription<UserAccelerometerEvent>? _shakeSubscription;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;
    _startShakeListener();
    _startVoiceListener();
  }

  void triggerLongPressEffect() {
    if (!state.longPressEnabled) return;
    _applyTimedEffect(
      enableCheck: (stage) => stage.ribbonPortalEnabled,
      toggle: _ref.read(stageExperienceProvider.notifier).toggleRibbonPortal,
    );
    _applyTimedEffect(
      enableCheck: (stage) => stage.auroraTrailsEnabled,
      toggle: _ref.read(stageExperienceProvider.notifier).toggleAuroraTrails,
    );
  }

  Future<void> setVoiceEnabled(bool value) async {
    if (value == state.voiceEnabled) return;
    state = state.copyWith(voiceEnabled: value);
    if (value) {
      await _startVoiceListener();
    } else {
      await _stopVoiceListener();
    }
  }

  void setShakeEnabled(bool value) {
    if (value == state.shakeEnabled) return;
    state = state.copyWith(shakeEnabled: value);
    if (value) {
      _startShakeListener();
    } else {
      _shakeSubscription?.cancel();
      _shakeSubscription = null;
    }
  }

  void setLongPressEnabled(bool value) {
    state = state.copyWith(longPressEnabled: value);
  }

  void updateVoiceThreshold(double value) {
    state = state.copyWith(voiceThreshold: value);
  }

  void updateShakeSensitivity(double value) {
    state = state.copyWith(shakeMagnitude: value);
  }

  void _startShakeListener() {
    if (!state.shakeEnabled) {
      _shakeSubscription?.cancel();
      _shakeSubscription = null;
      return;
    }
    _shakeSubscription ??=
        userAccelerometerEventStream().listen(_handleAccelerometerEvent);
  }

  void _handleAccelerometerEvent(UserAccelerometerEvent event) {
    if (!state.shakeEnabled) return;
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    if (magnitude < state.shakeMagnitude) return;
    final now = DateTime.now();
    final last = state.lastShakeTrigger;
    if (last != null && now.difference(last) < const Duration(seconds: 6)) {
      return;
    }
    _applyTimedEffect(
      enableCheck: (stage) => stage.giftFireworksEnabled,
      toggle: _ref.read(stageExperienceProvider.notifier).toggleGiftFireworks,
      holdDuration: const Duration(seconds: 10),
    );
    _applyTimedEffect(
      enableCheck: (stage) => stage.meteorEnabled,
      toggle: _ref.read(stageExperienceProvider.notifier).toggleMeteor,
      holdDuration: const Duration(seconds: 10),
    );
    state = state.copyWith(lastShakeTrigger: now);
  }

  Future<void> _startVoiceListener() async {
    if (!state.voiceEnabled) {
      await _stopVoiceListener();
      return;
    }
    if (kIsWeb) return;
    if (!await _ensureMicrophonePermission()) {
      state = state.copyWith(
        microphoneGranted: false,
        voiceListening: false,
        voiceEnabled: false,
      );
      return;
    }
    state = state.copyWith(microphoneGranted: true);
    _noiseSubscription ??= _noiseMeter.noise.listen(
      (reading) {
        final db = reading.meanDecibel.isNaN ? 0.0 : reading.meanDecibel;
        state = state.copyWith(micLevel: db, voiceListening: true);
        if (db > state.voiceThreshold) {
          _handleVoiceActivity();
        }
      },
      onError: (_) => state = state.copyWith(voiceListening: false),
    );
  }

  Future<void> _stopVoiceListener() async {
    await _noiseSubscription?.cancel();
    _noiseSubscription = null;
    state = state.copyWith(voiceListening: false);
  }

  Future<bool> _ensureMicrophonePermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  void _handleVoiceActivity() {
    if (!state.voiceEnabled) return;
    final now = DateTime.now();
    final last = state.lastVoiceTrigger;
    if (last != null && now.difference(last) < const Duration(seconds: 5)) {
      return;
    }
    _applyTimedEffect(
      enableCheck: (stage) => stage.magicDustEnabled,
      toggle: _ref.read(stageExperienceProvider.notifier).toggleMagicDust,
      holdDuration: const Duration(seconds: 12),
    );
    _applyTimedEffect(
      enableCheck: (stage) => stage.starChoirEnabled,
      toggle: _ref.read(stageExperienceProvider.notifier).toggleStarChoir,
      holdDuration: const Duration(seconds: 12),
    );
    state = state.copyWith(lastVoiceTrigger: now);
  }

  void _applyTimedEffect({
    required bool Function(StageExperienceState state) enableCheck,
    required void Function(bool enabled) toggle,
    Duration holdDuration = const Duration(seconds: 8),
  }) {
    final stageState = _ref.read(stageExperienceProvider);
    final alreadyEnabled = enableCheck(stageState);
    if (alreadyEnabled) {
      return;
    }
    toggle(true);
    Timer(holdDuration, () {
      final latest = _ref.read(stageExperienceProvider);
      if (enableCheck(latest)) {
        toggle(false);
      }
    });
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _shakeSubscription?.cancel();
    super.dispose();
  }
}

final interactionTriggerControllerProvider = StateNotifierProvider<
    InteractionTriggerController, InteractionTriggerState>((ref) {
  final controller = InteractionTriggerController(ref)..initialize();
  ref.onDispose(controller.dispose);
  return controller;
});
