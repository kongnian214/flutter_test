import 'package:flutter/widgets.dart';

import '../../shared/audio/festive_audio_controller.dart';
import 'blessing_message_controller.dart';
import 'stage_experience_controller.dart';
import '../../shared/firework_burst_layer.dart';

typedef SceneLayerBuilder = Widget Function(SceneLayerContext context);

class SceneLayerPlugin {
  final String id;
  final SceneLayerBuilder builder;
  final bool Function(StageExperienceState state)? isActive;
  final bool useRepaintBoundary;
  final Object? Function(SceneLayerContext context)? cacheKeyBuilder;

  const SceneLayerPlugin({
    required this.id,
    required this.builder,
    this.isActive,
    this.useRepaintBoundary = false,
    this.cacheKeyBuilder,
  });

  bool enabled(StageExperienceState state) =>
      isActive == null ? true : isActive!(state);

  Widget build(SceneLayerContext context) {
    final child = builder(context);
    if (!useRepaintBoundary) return child;
    final cacheKey = cacheKeyBuilder?.call(context);
    final key =
        cacheKey == null ? ValueKey(id) : ValueKey('${id}_$cacheKey');
    return RepaintBoundary(key: key, child: child);
  }
}

class SceneLayerContext {
  final StageExperienceState state;
  final double time;
  final double deltaTime;
  final Animation<double> auroraAnimation;
  final List<FireworkSeed> fireworks;
  final AudioReactiveSnapshot audioSnapshot;
  final BlessingMessageState blessings;

  const SceneLayerContext({
    required this.state,
    required this.time,
    required this.deltaTime,
    required this.auroraAnimation,
    required this.fireworks,
    required this.audioSnapshot,
    required this.blessings,
  });
}

class SceneController {
  final List<SceneLayerPlugin> _plugins;

  SceneController({required List<SceneLayerPlugin> plugins})
    : _plugins = List.unmodifiable(plugins);

  List<Widget> buildLayers(SceneLayerContext context) {
    return [
      for (final plugin in _plugins)
        if (plugin.enabled(context.state)) plugin.build(context),
    ];
  }
}
