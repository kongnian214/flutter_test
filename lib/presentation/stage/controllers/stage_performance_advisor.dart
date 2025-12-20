import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum StagePerformanceTier { high, balanced, low }

class StagePerformanceSnapshot {
  final double averageFps;
  final double lastFrameMs;
  final StagePerformanceTier tier;
  final String? message;

  const StagePerformanceSnapshot({
    required this.averageFps,
    required this.lastFrameMs,
    required this.tier,
    required this.message,
  });

  factory StagePerformanceSnapshot.initial() => const StagePerformanceSnapshot(
        averageFps: 60,
        lastFrameMs: 16.6,
        tier: StagePerformanceTier.high,
        message: null,
      );

  StagePerformanceSnapshot copyWith({
    double? averageFps,
    double? lastFrameMs,
    StagePerformanceTier? tier,
    String? message,
  }) {
    return StagePerformanceSnapshot(
      averageFps: averageFps ?? this.averageFps,
      lastFrameMs: lastFrameMs ?? this.lastFrameMs,
      tier: tier ?? this.tier,
      message: message,
    );
  }
}

class StagePerformanceAdvisor
    extends StateNotifier<StagePerformanceSnapshot> {
  StagePerformanceAdvisor() : super(StagePerformanceSnapshot.initial()) {
    SchedulerBinding.instance.addTimingsCallback(_handleTimings);
  }

  static StagePerformanceTier _resolveTier(double fps) {
    if (fps >= 55) return StagePerformanceTier.high;
    if (fps >= 45) return StagePerformanceTier.balanced;
    return StagePerformanceTier.low;
  }

  void _handleTimings(List<FrameTiming> timings) {
    if (timings.isEmpty) return;
    final frame = timings.last;
    final frameMs = frame.totalSpan.inMicroseconds / 1000.0;
    final fps = frameMs <= 0 ? 60.0 : math.min(120, 1000 / frameMs);
    final smoothed = state.averageFps * .8 + fps * .2;
    final tier = _resolveTier(smoothed);
    String? message;
    if (tier == StagePerformanceTier.low &&
        state.tier != StagePerformanceTier.low) {
      message = '检测到帧率低于 45fps，自动切换至低负载模式。';
    } else if (tier == StagePerformanceTier.balanced &&
        state.tier == StagePerformanceTier.high) {
      message = '已进入均衡模式，建议减少叠加特效。';
    } else if (tier == StagePerformanceTier.high &&
        state.tier != StagePerformanceTier.high) {
      message = '性能恢复，已解除降级限制。';
    }
    state = state.copyWith(
      averageFps: smoothed,
      lastFrameMs: frameMs,
      tier: tier,
      message: message,
    );
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_handleTimings);
    super.dispose();
  }
}

final stagePerformanceAdvisorProvider =
    StateNotifierProvider<StagePerformanceAdvisor, StagePerformanceSnapshot>(
      (ref) => StagePerformanceAdvisor(),
    );

extension StagePerformanceTierLabel on StagePerformanceTier {
  String get label => switch (this) {
        StagePerformanceTier.high => '性能优先',
        StagePerformanceTier.balanced => '均衡模式',
        StagePerformanceTier.low => '保帧模式',
      };
}
