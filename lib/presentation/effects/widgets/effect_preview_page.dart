import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../domain/entities/festive_effect.dart';
import '../../../domain/entities/blessing_message.dart';
import '../../shared/aurora_background.dart';
import '../../shared/bell_chime_layer.dart';
import '../../shared/candy_cane_rain_layer.dart';
import '../../shared/cookie_baking_layer.dart';
import '../../shared/crystal_particle_layer.dart';
import '../../shared/firework_burst_layer.dart';
import '../../shared/frost_transition_layer.dart';
import '../../shared/glowing_tree_layer.dart';
import '../../shared/lantern_drift_layer.dart';
import '../../shared/magic_dust_layer.dart';
import '../../shared/midnight_clockwork_layer.dart';
import '../../shared/meteor_shower_layer.dart';
import '../../shared/north_pole_mail_layer.dart';
import '../../shared/ribbon_portal_layer.dart';
import '../../shared/starry_village_layer.dart';
import '../../shared/snowfall_layer.dart';
import '../../shared/toy_parade_layer.dart';

class EffectPreviewPage extends StatefulWidget {
  const EffectPreviewPage({super.key, required this.effect});

  final FestiveEffect effect;

  @override
  State<EffectPreviewPage> createState() => _EffectPreviewPageState();
}

class _EffectPreviewPageState extends State<EffectPreviewPage>
    with TickerProviderStateMixin {
  late final AnimationController _auroraController;
  late final Ticker _ticker;
  double _time = 0;
  double _lastFireworkSpawn = 0;
  final List<FireworkSeed> _fireworks = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _ticker = createTicker((elapsed) {
      final seconds = elapsed.inMilliseconds / 1000;
      setState(() {
        _time = seconds;
        _fireworks.removeWhere((seed) => seconds - seed.startTime > 2.5);
      });
      if (_supportsFireworks && seconds - _lastFireworkSpawn > .6) {
        _fireworks.add(
          FireworkSeed(
            startTime: seconds,
            horizontalFactor: _random.nextDouble() * .6 + .2,
          ),
        );
        _lastFireworkSpawn = seconds;
      }
    })..start();
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layers = _buildLayers();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF040B14),
                    Color(0xFF071324),
                    Color(0xFF091C33),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child:
                  layers.isEmpty
                      ? const Center(
                        child: Text(
                          '该特效暂未提供全屏 Demo\n可先浏览描述或体验其它特效',
                          textAlign: TextAlign.center,
                        ),
                      )
                      : Stack(children: layers),
            ),
          ),
          Positioned(
            top: 24,
            left: 16,
            child: IconButton.filled(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: .55),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: .2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.effect.name,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(widget.effect.description),
                    if (widget.effect.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children:
                            widget.effect.tags
                                .map((tag) => Chip(label: Text(tag)))
                                .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Text('提示：全屏预览不会影响简单特效开关，返回后可在控制台继续调节。'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLayers() {
    final layers = <Widget>[];
    if (_supportsAurora) {
      layers.add(AuroraBackground(animation: _auroraController, enabled: true));
    }
    if (_supportsVillage) {
      layers.add(StarryVillageLayer(time: _time, enabled: true));
    }
    if (_supportsSnow) {
      layers.add(SnowfallLayer(time: _time, density: .8, enabled: true));
    }
    if (_supportsCandy) {
      layers.add(CandyCaneRainLayer(time: _time, enabled: true));
    }
    if (_supportsLantern) {
      layers.add(LanternDriftLayer(time: _time, enabled: true));
    }
    if (_supportsMeteor) {
      layers.add(MeteorShowerLayer(time: _time, enabled: true));
    }
    if (_supportsMagicDust) {
      layers.add(
        MagicDustLayer(
          time: _time,
          enabled: true,
          message: _previewBlessing,
        ),
      );
    }
    if (_supportsFireworks) {
      layers.add(FireworkBurstLayer(time: _time, seeds: _fireworks));
    }
    if (_supportsCrystal) {
      layers.add(CrystalParticleLayer(time: _time, enabled: true));
    }
    if (_supportsRibbonPortal) {
      layers.add(RibbonPortalLayer(time: _time, enabled: true));
    }
    if (_supportsGlowingTree) {
      layers.add(GlowingTreeLayer(time: _time, enabled: true));
    }
    if (_supportsFrost) {
      layers.add(FrostTransitionLayer(time: _time, enabled: true));
    }
    if (_supportsCookieBaking) {
      layers.add(CookieBakingLayer(time: _time, enabled: true));
    }
    if (_supportsToyParade) {
      layers.add(ToyParadeLayer(time: _time, enabled: true));
    }
    if (_supportsClockwork) {
      layers.add(MidnightClockworkLayer(time: _time, enabled: true));
    }
    if (_supportsNorthPoleMail) {
      layers.add(
        NorthPoleMailLayer(
          time: _time,
          enabled: true,
          messages: const [_previewBlessing],
          featured: _previewBlessing,
          messageRevision: 0,
        ),
      );
    }
    if (_supportsPolarWind) {
      layers.add(
        SnowfallLayer(
          time: _time,
          density: .9,
          enabled: true,
          wind: const Offset(2.2, 0.8),
        ),
      );
    }
    if (_supportsBellChime) {
      layers.add(BellChimeLayer(time: _time, enabled: true));
    }
    return layers;
  }

  bool get _supportsAurora => _matches(const ['aurora', '极光']);
  bool get _supportsVillage => _matches(const ['village', 'starry', '小镇']);
  bool get _supportsSnow => _matches(const ['snow', '雪', 'winter']);
  bool get _supportsLantern => _matches(const ['lantern', '灯']);
  bool get _supportsCandy => _matches(const ['candy', 'cane', '糖']);
  bool get _supportsMeteor => _matches(const ['meteor', '流星']);
  bool get _supportsMagicDust => _matches(const ['magic', 'dust', '彩粉', '文字']);
  bool get _supportsFireworks =>
      _matches(const ['firework', '焰火', '烟花', 'gift']);
  bool get _supportsCrystal => _matches(const ['crystal', '晶', '冰']);
  bool get _supportsRibbonPortal =>
      _matches(const ['ribbon', 'portal', '丝带', '传送']);
  bool get _supportsGlowingTree => _matches(const ['tree', 'glow', '树']);
  bool get _supportsFrost => _matches(const ['frost', '霜', '冰霜']);
  bool get _supportsCookieBaking => _matches(const ['cookie', 'bake', '烘焙']);
  bool get _supportsToyParade => _matches(const ['toy', 'parade', '玩具']);
  bool get _supportsClockwork => _matches(const ['clock', 'gear', '钟', '齿轮']);
  bool get _supportsPolarWind => _matches(const ['polar', 'wind', '风']);
  bool get _supportsNorthPoleMail => _matches(const ['mail', '信封', '北极']);
  bool get _supportsBellChime => _matches(const ['bell', 'chime', '铃']);

  bool _matches(Iterable<String> keywords) {
    final name = widget.effect.name.toLowerCase();
    final tags = widget.effect.tags.map((tag) => tag.toLowerCase());
    for (final key in keywords) {
      final lower = key.toLowerCase();
      if (name.contains(lower)) return true;
      if (tags.any((tag) => tag.contains(lower))) return true;
    }
    return false;
  }
}

const _previewBlessing = BlessingMessage(
  id: 'preview',
  content: '愿你今晚被极光环抱，所有烦恼融化成雪。',
  sender: 'Aurora Studio',
  recipient: '你',
);
