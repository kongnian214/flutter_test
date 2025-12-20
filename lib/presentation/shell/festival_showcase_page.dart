import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lcs1/domain/entities/festive_effect.dart';
import 'package:lcs1/domain/entities/interaction_idea.dart';
import 'package:lcs1/domain/value_objects/countdown_snapshot.dart';
import 'package:lcs1/domain/value_objects/countdown_target.dart';
import 'package:lcs1/presentation/effects/controllers/effect_providers.dart';
import 'package:lcs1/presentation/effects/widgets/effect_preview_page.dart';
import 'package:lcs1/presentation/interaction/controllers/interaction_providers.dart';
import 'package:lcs1/presentation/interaction/controllers/interaction_trigger_controller.dart';
import 'package:lcs1/presentation/shared/aurora_background.dart';
import 'package:lcs1/presentation/shared/aurora_trails_layer.dart';
import 'package:lcs1/presentation/shared/candy_cane_rain_layer.dart';
import 'package:lcs1/presentation/shared/bell_chime_layer.dart';
import 'package:lcs1/presentation/shared/cookie_baking_layer.dart';
import 'package:lcs1/presentation/shared/crystal_particle_layer.dart';
import 'package:lcs1/presentation/shared/audio/festive_audio_controller.dart';
import 'package:lcs1/presentation/shared/frost_transition_layer.dart';
import 'package:lcs1/presentation/shared/frosted_card.dart';
import 'package:lcs1/presentation/shared/firework_burst_layer.dart';
import 'package:lcs1/presentation/shared/glowing_tree_layer.dart';
import 'package:lcs1/presentation/shared/lantern_drift_layer.dart';
import 'package:lcs1/presentation/shared/magic_dust_layer.dart';
import 'package:lcs1/presentation/shared/midnight_clockwork_layer.dart';
import 'package:lcs1/presentation/shared/meteor_shower_layer.dart';
import 'package:lcs1/presentation/shared/north_pole_mail_layer.dart';
import 'package:lcs1/presentation/shared/ribbon_portal_layer.dart';
import 'package:lcs1/presentation/shared/starry_village_layer.dart';
import 'package:lcs1/presentation/shared/snowfall_layer.dart';
import 'package:lcs1/presentation/shared/star_choir_layer.dart';
import 'package:lcs1/presentation/shared/toy_parade_layer.dart';
import 'package:lcs1/presentation/stage/controllers/countdown_provider.dart';
import 'package:lcs1/presentation/stage/controllers/stage_experience_controller.dart';
import 'package:lcs1/presentation/stage/controllers/scene_controller.dart';
import 'package:lcs1/presentation/stage/controllers/stage_performance_advisor.dart';
import 'package:lcs1/presentation/stage/controllers/device_capability_provider.dart';
import 'package:lcs1/presentation/stage/controllers/blessing_message_controller.dart';

class FestivalShowcasePage extends ConsumerStatefulWidget {
  const FestivalShowcasePage({super.key});

  @override
  ConsumerState<FestivalShowcasePage> createState() =>
      _FestivalShowcasePageState();
}

class _FestivalShowcasePageState extends ConsumerState<FestivalShowcasePage>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  final Set<int> _visitedTabs = {0};

  late final AnimationController _auroraController;
  late final Ticker _timeTicker;
  double _time = 0;
  double _deltaTime = 0;
  final List<FireworkSeed> _fireworks = [];
  final math.Random _random = math.Random();
  double _lastAutoFirework = 0;
  late final SceneController _sceneController;
  late final FestiveAudioController _audioController;
  StagePerformanceTier _performanceTier = StagePerformanceTier.high;
  double _smoothedFps = 60;
  String? _performanceNotice;
  ProviderSubscription<StagePerformanceSnapshot>? _performanceSubscription;
  ProviderSubscription<AsyncValue<StageDeviceCapability>>?
      _deviceCapabilitySubscription;
  StageDeviceCapability _deviceCapability = StageDeviceCapability.high;
  bool _performanceGuardEnabled = true;
  late final TextEditingController _blessingRecipientController;
  late final TextEditingController _blessingMessageController;
  late final TextEditingController _blessingSenderController;
  bool _isSubmittingBlessing = false;

  @override
  void initState() {
    super.initState();
    _blessingRecipientController = TextEditingController();
    _blessingMessageController = TextEditingController();
    _blessingSenderController = TextEditingController();
    _audioController = ref.read(festiveAudioControllerProvider);
    ref.read(interactionTriggerControllerProvider);
    final performanceSnapshot = ref.read(stagePerformanceAdvisorProvider);
    _performanceTier = performanceSnapshot.tier;
    _smoothedFps = performanceSnapshot.averageFps;
    _performanceNotice = performanceSnapshot.message;
    _performanceSubscription = ref.listenManual<StagePerformanceSnapshot>(
      stagePerformanceAdvisorProvider,
      (previous, next) => _handlePerformanceSnapshot(next),
    );
    _deviceCapabilitySubscription =
        ref.listenManual<AsyncValue<StageDeviceCapability>>(
          stageDeviceCapabilityProvider,
          (previous, next) {
            next.whenData((value) {
              if (!mounted || value == _deviceCapability) return;
              setState(() => _deviceCapability = value);
            });
          },
        );
    ref.read(stageDeviceCapabilityProvider);
    _sceneController = SceneController(
      plugins: [
        SceneLayerPlugin(
          id: 'aurora',
          useRepaintBoundary: true,
          isActive: (state) => state.auroraEnabled,
          builder:
              (context) => AuroraBackground(
                animation: context.auroraAnimation,
                enabled: context.state.auroraEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'aurora-trails',
          useRepaintBoundary: true,
          isActive: (state) => state.auroraTrailsEnabled,
          builder:
              (context) => AuroraTrailsLayer(
                time: context.time,
                enabled: context.state.auroraTrailsEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'village',
          useRepaintBoundary: true,
          isActive: (state) => state.villageEnabled,
          builder:
              (context) => StarryVillageLayer(
                time: context.time,
                enabled: context.state.villageEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'snow',
          useRepaintBoundary: true,
          isActive: (state) => state.snowEnabled,
          builder:
              (context) => SnowfallLayer(
                time: context.time,
                density: context.state.snowDensity,
                enabled: context.state.snowEnabled,
                wind: Offset(
                  context.state.windStrength * 2,
                  context.state.windStrength,
                ),
              ),
        ),
        SceneLayerPlugin(
          id: 'candy',
          useRepaintBoundary: true,
          isActive: (state) => state.candyCaneEnabled,
          builder:
              (context) => CandyCaneRainLayer(
                time: context.time,
                enabled: context.state.candyCaneEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'firework',
          useRepaintBoundary: true,
          builder:
              (context) => FireworkBurstLayer(
                time: context.time,
                seeds: context.fireworks,
              ),
        ),
        SceneLayerPlugin(
          id: 'frost-transition',
          useRepaintBoundary: true,
          isActive: (state) => state.frostTransitionEnabled,
          builder:
              (context) => FrostTransitionLayer(
                time: context.time,
                enabled: context.state.frostTransitionEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'glowing-tree',
          useRepaintBoundary: true,
          isActive: (state) => state.glowingTreeEnabled,
          builder:
              (context) => GlowingTreeLayer(
                time: context.time,
                enabled: context.state.glowingTreeEnabled,
                musicLevel: context.audioSnapshot.beatLevel,
              ),
        ),
        SceneLayerPlugin(
          id: 'lantern',
          useRepaintBoundary: true,
          isActive: (state) => state.lanternEnabled,
          builder:
              (context) => LanternDriftLayer(
                time: context.time,
                enabled: context.state.lanternEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'meteor',
          useRepaintBoundary: true,
          isActive: (state) => state.meteorEnabled,
          builder:
              (context) => MeteorShowerLayer(
                time: context.time,
                enabled: context.state.meteorEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'magic-dust',
          useRepaintBoundary: true,
          isActive: (state) => state.magicDustEnabled,
          builder:
              (context) => MagicDustLayer(
                time: context.time,
                enabled: context.state.magicDustEnabled,
                message: context.blessings.featured,
              ),
        ),
        SceneLayerPlugin(
          id: 'crystal',
          useRepaintBoundary: true,
          isActive: (state) => state.crystalEnabled,
          builder:
              (context) => CrystalParticleLayer(
                time: context.time,
                enabled: context.state.crystalEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'ribbon-portal',
          useRepaintBoundary: true,
          isActive: (state) => state.ribbonPortalEnabled,
          builder:
              (context) => RibbonPortalLayer(
                time: context.time,
                enabled: context.state.ribbonPortalEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'cookie-baking',
          useRepaintBoundary: true,
          isActive: (state) => state.cookieBakingEnabled,
          builder:
              (context) => CookieBakingLayer(
                time: context.time,
                enabled: context.state.cookieBakingEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'toy-parade',
          useRepaintBoundary: true,
          isActive: (state) => state.toyParadeEnabled,
          builder:
              (context) => ToyParadeLayer(
                time: context.time,
                enabled: context.state.toyParadeEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'midnight-clockwork',
          useRepaintBoundary: true,
          isActive: (state) => state.clockworkEnabled,
          builder:
              (context) => MidnightClockworkLayer(
                time: context.time,
                enabled: context.state.clockworkEnabled,
              ),
        ),
        SceneLayerPlugin(
          id: 'north-pole-mail',
          useRepaintBoundary: true,
          isActive: (state) => state.northPoleMailEnabled,
          builder:
              (context) => NorthPoleMailLayer(
                time: context.time,
                enabled: context.state.northPoleMailEnabled,
                messages: context.blessings.recent,
                featured: context.blessings.featured,
                messageRevision: context.blessings.revision,
              ),
        ),
        SceneLayerPlugin(
          id: 'bell-chime',
          useRepaintBoundary: true,
          isActive: (state) => state.bellChimeEnabled,
          builder:
              (context) => BellChimeLayer(
                time: context.time,
                enabled: context.state.bellChimeEnabled,
                musicLevel: context.audioSnapshot.beatLevel,
                accentLevel: context.audioSnapshot.accentLevel,
              ),
        ),
        SceneLayerPlugin(
          id: 'star-choir',
          useRepaintBoundary: true,
          isActive: (state) => state.starChoirEnabled,
          builder:
              (context) => StarChoirLayer(
                time: context.time,
                enabled: context.state.starChoirEnabled,
                intensity: context.audioSnapshot.beatLevel,
              ),
        ),
      ],
    );
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _timeTicker = createTicker((elapsed) {
      final seconds = elapsed.inMilliseconds / 1000;
      final delta = (seconds - _time).clamp(0.0, 0.5);
      setState(() {
        _deltaTime = delta.toDouble();
        _time = seconds;
      });
      _maybeAutoSpawnFirework();
    })..start();
  }

  Widget _buildImmersiveControls() {
    return SegmentedButton<SceneViewMode>(
      segments: const [
        ButtonSegment(
          value: SceneViewMode.info,
          icon: Icon(Icons.view_agenda),
          label: Text('信息面板'),
        ),
        ButtonSegment(
          value: SceneViewMode.immersive,
          icon: Icon(Icons.fullscreen),
          label: Text('沉浸视图'),
        ),
      ],
      selected: {ref.watch(_sceneViewModeProvider)},
      onSelectionChanged: (value) {
        if (value.isNotEmpty) {
          ref.read(_sceneViewModeProvider.notifier).state = value.first;
        }
      },
    );
  }

  Widget _buildAudioPanel(AudioReactiveSnapshot snapshot) {
    final playing = snapshot.playing;
    final readiness = snapshot.initialized;
    final accentValue = (snapshot.accentLevel * .8).clamp(0.0, 1.0);
    final theme = Theme.of(context);
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.music_note, color: Colors.pinkAccent.shade100),
              const SizedBox(width: 8),
              Text(
                '音乐状态',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                playing ? '雪夜乐章 · BPM 84' : '静音待命',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            minHeight: 4,
            value: playing ? accentValue : 0,
            color: Colors.pinkAccent,
            backgroundColor: Colors.white.withValues(alpha: .16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                readiness ? '背景乐' : '音频初始化中…',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Switch.adaptive(
                value: playing,
                onChanged: (value) => _handleBgmToggle(value, readiness),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleBgmToggle(bool desiredState, bool readiness) {
    if (readiness) {
      _audioController.setBgmEnabled(desiredState);
      return;
    }
    unawaited(_initializeAndEnable(desiredState));
  }

  Future<void> _initializeAndEnable(bool desiredState) async {
    await _audioController.initialize();
    await _audioController.setBgmEnabled(desiredState);
  }

  void _submitBlessing(BlessingMessageState state) {
    if (_isSubmittingBlessing) return;
    final content = _blessingMessageController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先写点什么再投递给北极邮局吧~')),
      );
      return;
    }
    setState(() => _isSubmittingBlessing = true);
    ref.read(blessingMessageProvider.notifier).addMessage(
          content: content,
          recipient: _blessingRecipientController.text,
          sender: _blessingSenderController.text,
        );
    _blessingMessageController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已写入 Magic Dust / North Pole Mail')),
    );
    setState(() => _isSubmittingBlessing = false);
  }

  void _applyBlessingSuggestion() {
    final suggestion =
        ref.read(blessingMessageProvider.notifier).randomSuggestion(
              recipient: _blessingRecipientController.text,
            );
    _blessingMessageController.text = suggestion;
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _timeTicker.dispose();
    _performanceSubscription?.close();
    _deviceCapabilitySubscription?.close();
    _blessingRecipientController.dispose();
    _blessingMessageController.dispose();
    _blessingSenderController.dispose();
    super.dispose();
  }

  CountdownSnapshot _fallbackCountdownSnapshot(CountdownTarget target) {
    final now = DateTime.now();
    final targetMoment = target.resolveNext(now);
    final remaining = targetMoment.difference(now);
    return CountdownSnapshot(target: target, remaining: remaining).clamp();
  }

  @override
  Widget build(BuildContext context) {
    _fireworks.removeWhere((seed) => _time - seed.startTime > 2.5);
    final stageState = ref.watch(stageExperienceProvider);
    final audioController = ref.watch(festiveAudioControllerProvider);
    final audioSnapshot = audioController.snapshot;
    final blessingState = ref.watch(blessingMessageProvider);
    final immersive =
        ref.watch(_sceneViewModeProvider) == SceneViewMode.immersive;
    final countdownAsync = ref.watch(countdownStreamProvider);
    final countdownSnapshot =
        countdownAsync.valueOrNull ??
        _fallbackCountdownSnapshot(stageState.target);
    final countdownUpdating =
        countdownAsync.isLoading && countdownAsync.valueOrNull == null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (_currentIndex == index) return;
          setState(() {
            _currentIndex = index;
            _visitedTabs.add(index);
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.vrpano_outlined),
            selectedIcon: Icon(Icons.vrpano),
            label: '舞台',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: '特效库',
          ),
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: '互动',
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _buildSceneCanvas(
              stageState,
              audioSnapshot,
              blessingState,
            ),
          ),
          if (!immersive)
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: [
                  _buildStageTab(
                    stageState: stageState,
                    countdown: countdownSnapshot,
                    countdownUpdating: countdownUpdating,
                    audioSnapshot: audioSnapshot,
                    blessingState: blessingState,
                  ),
                  _visitedTabs.contains(1)
                      ? _buildEffectsTab()
                      : const SizedBox.shrink(),
                  _visitedTabs.contains(2)
                      ? _buildInteractionTab()
                      : const SizedBox.shrink(),
                ],
              ),
            ),
          if (immersive)
            Positioned(
              left: 24,
              right: 24,
              bottom: 48,
              child: _ImmersiveHint(
                onExit: () {
                  ref.read(_sceneViewModeProvider.notifier).state =
                      SceneViewMode.info;
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _countdownTile(String label, int value) {
    return Expanded(
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withValues(alpha: .08),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value.toString().padLeft(2, '0'),
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildStageTab({
    required StageExperienceState stageState,
    required CountdownSnapshot countdown,
    required bool countdownUpdating,
    required AudioReactiveSnapshot audioSnapshot,
    required BlessingMessageState blessingState,
  }) {
    final triggerState = ref.watch(interactionTriggerControllerProvider);
    return DecoratedBox(
      key: const ValueKey('stage'),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: .35)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildExperienceBanner(stageState),
              const SizedBox(height: 12),
              _buildCountdown(
                stageState: stageState,
                countdown: countdown,
                isUpdating: countdownUpdating,
              ),
              const SizedBox(height: 16),
              _buildStageStatusRow(stageState, audioSnapshot),
              const SizedBox(height: 16),
              _buildInteractionTriggerPanel(triggerState),
              const SizedBox(height: 16),
              _buildImmersiveControls(),
              const SizedBox(height: 16),
              _buildControlPanel(context, stageState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSceneCanvas(
    StageExperienceState stageState,
    AudioReactiveSnapshot audioSnapshot,
    BlessingMessageState blessingState,
  ) {
    final triggerState = ref.watch(interactionTriggerControllerProvider);
    final triggerController =
        ref.read(interactionTriggerControllerProvider.notifier);
    final sceneLayers = _sceneController.buildLayers(
      SceneLayerContext(
        state: stageState,
        time: _time,
        deltaTime: _deltaTime,
        auroraAnimation: _auroraController,
        fireworks: List.unmodifiable(_fireworks),
        audioSnapshot: audioSnapshot,
        blessings: blessingState,
      ),
    );
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: triggerState.longPressEnabled
          ? triggerController.triggerLongPressEffect
          : null,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF030710), Color(0xFF0B213A), Color(0xFF09162A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            ...sceneLayers,
            IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: .1),
                      Colors.black.withValues(alpha: .2),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlessingComposer(BlessingMessageState blessingState) {
    final featured = blessingState.featured;
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.mail_outline),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '写一封暖心祝福',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'Magic Dust & North Pole Mail 会实时展示你选中的句子',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: '轮播下一条',
                onPressed: blessingState.entries.length > 1
                    ? () => ref
                        .read(blessingMessageProvider.notifier)
                        .cycleFeatured()
                    : null,
                icon: const Icon(Icons.shuffle),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _blessingRecipientController,
            decoration: const InputDecoration(
              labelText: '写给谁（可选）',
              hintText: 'Ta 的昵称或暗号',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _blessingMessageController,
            minLines: 2,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: '想说的话',
              hintText: '例如：愿你今晚和星星一起入睡…',
              suffixIcon: IconButton(
                tooltip: '灵感',
                icon: const Icon(Icons.lightbulb_outline),
                onPressed: () => _applyBlessingSuggestion(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _blessingSenderController,
            decoration: const InputDecoration(
              labelText: '署名（可选）',
              hintText: '来自谁',
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              FilledButton.icon(
                icon: _isSubmittingBlessing
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_fix_high),
                label: const Text('存入祝福 & 触发彩蛋'),
                onPressed: _isSubmittingBlessing
                    ? null
                    : () => _submitBlessing(blessingState),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                icon: const Icon(Icons.undo),
                label: const Text('清空输入'),
                onPressed: () {
                  _blessingMessageController.clear();
                  _blessingRecipientController.clear();
                  _blessingSenderController.clear();
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '已收藏祝福',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final entry in blessingState.recent)
                ChoiceChip(
                  label: Text(entry.preview),
                  selected: entry.id == featured.id,
                  onSelected: (_) {
                    ref
                        .read(blessingMessageProvider.notifier)
                        .setFeatured(entry.id);
                    if (_blessingMessageController.text.trim().isEmpty) {
                      _blessingMessageController.text = entry.content;
                    }
                    final entryRecipient = entry.recipient?.trim();
                    if ((entryRecipient?.isNotEmpty ?? false) &&
                        _blessingRecipientController.text.trim().isEmpty) {
                      _blessingRecipientController.text = entryRecipient!;
                    }
                    final entrySender = entry.sender?.trim();
                    if ((entrySender?.isNotEmpty ?? false) &&
                        _blessingSenderController.text.trim().isEmpty) {
                      _blessingSenderController.text = entrySender!;
                    }
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }


  void _triggerFirework() {
    final position = _random.nextDouble() * .6 + .2;
    final seed = FireworkSeed(startTime: _time, horizontalFactor: position);
    setState(() {
      _fireworks.add(seed);
      if (_fireworks.length > 6) {
        _fireworks.removeAt(0);
      }
    });
  }

  void _maybeAutoSpawnFirework() {
    final stageState = ref.read(stageExperienceProvider);
    if (!stageState.giftFireworksEnabled) return;
    if (_time - _lastAutoFirework < 1.2) return;
    _lastAutoFirework = _time;
    _triggerFirework();
  }

  void _handlePerformanceSnapshot(StagePerformanceSnapshot snapshot) {
    if (!mounted) return;
    setState(() {
      _performanceTier = snapshot.tier;
      _smoothedFps = snapshot.averageFps;
      _performanceNotice = snapshot.message;
      if (!_performanceGuardEnabled) {
        _performanceNotice ??=
            '性能守护已关闭，系统不会自动降级特效。';
      }
    });
    if (!_performanceGuardEnabled) {
      return;
    }
    ref.read(stageExperienceProvider.notifier).applyPerformanceTier(
          snapshot.tier,
        );
    _enforcePerformanceBudget();
    if (snapshot.message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(snapshot.message!)),
      );
    }
  }

  Widget _buildExperienceBanner(StageExperienceState stageState) {
    final activeLabels = _activeSimpleLabels(stageState);
    return FrostedCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '全屏特效画布',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text('简单特效随时开关（最多 3 个），较大特效进入“全屏预览”直达全屏体验。'),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: _triggerFirework,
                icon: const Icon(Icons.auto_fix_high),
                label: const Text('即刻触发烟花'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const _ViewModeHint(),
          const SizedBox(height: 12),
          const Text('提示：在特效卡片中点击“全屏预览”即可铺满屏幕体验该效果。'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              Chip(
                label: Text('已启用 ${activeLabels.length}/3'),
                avatar: const Icon(Icons.grid_view, size: 18),
              ),
              ...activeLabels.map((label) => Chip(label: Text(label))),
            ],
          ),
        ],
      ),
    );
  }

  List<String> _activeSimpleLabels(StageExperienceState state) {
    final labels = <String>[];
    if (state.auroraEnabled) labels.add('Aurora Sky');
    if (state.snowEnabled) labels.add('Snow Field');
    if (state.villageEnabled) labels.add('Starry Village');
    if (state.candyCaneEnabled) labels.add('Candy Cane Rain');
    if (state.lanternEnabled) labels.add('Lantern Drift');
    if (state.glowingTreeEnabled) labels.add('Glowing Tree');
    return labels;
  }

  Widget _buildCountdown({
    required StageExperienceState stageState,
    required CountdownSnapshot countdown,
    required bool isUpdating,
  }) {
    final (primaryTarget, secondaryTarget) =
        stageState.target == CountdownTarget.christmasEve
            ? ('延展极光层', 'Aurora Sky')
            : ('圣诞清晨焰火', 'Lantern Drift');
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.hourglass_bottom),
              const SizedBox(width: 8),
              Text(
                '节日倒计时',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Flexible(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SegmentedButton<CountdownTarget>(
                    segments: const [
                      ButtonSegment(
                        value: CountdownTarget.christmasEve,
                        label: Text('平安夜'),
                      ),
                      ButtonSegment(
                        value: CountdownTarget.christmasDay,
                        label: Text('圣诞日'),
                      ),
                    ],
                    showSelectedIcon: false,
                    selected: {stageState.target},
                    onSelectionChanged: (value) {
                      final target = value.isEmpty ? null : value.first;
                      if (target != null) {
                        ref
                            .read(stageExperienceProvider.notifier)
                            .setTarget(target);
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: isUpdating ? .6 : 1,
            child: Row(
              children: [
                _countdownTile('Days', countdown.days),
                const SizedBox(width: 12),
                _countdownTile('Hours', countdown.hours),
                const SizedBox(width: 12),
                _countdownTile('Minutes', countdown.minutes),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isUpdating)
            LinearProgressIndicator(
              minHeight: 2,
              color: Colors.white.withValues(alpha: .7),
              backgroundColor: Colors.white.withValues(alpha: .2),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '目标：$primaryTarget',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  secondaryTarget,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(
    BuildContext context,
    StageExperienceState stageState,
  ) {
    final controller = ref.read(stageExperienceProvider.notifier);
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune),
              const SizedBox(width: 8),
              Text(
                '氛围控制台（舞台核心）',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '舞台仅保留极光/飘雪/祝福等高频控制，其他互动彩蛋可在底部“互动”页切换。',
          ),
          const SizedBox(height: 16),
          _buildBasicControlsList(stageState, controller),
          const SizedBox(height: 20),
          _buildStageFeaturedAdvanced(stageState),
          const SizedBox(height: 12),
          Text(
            '更多互动彩蛋、传感器玩法请前往“互动”页管理。',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildStageStatusRow(
    StageExperienceState stageState,
    AudioReactiveSnapshot audioSnapshot,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final showStacked = constraints.maxWidth < 900;
        if (showStacked) {
          return Column(
            children: [
              _buildPerformanceSummary(stageState),
              const SizedBox(height: 12),
              _buildAudioPanel(audioSnapshot),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPerformanceSummary(stageState)),
            const SizedBox(width: 12),
            Expanded(child: _buildAudioPanel(audioSnapshot)),
          ],
        );
      },
    );
  }

  Widget _buildInteractionTriggerPanel(
    InteractionTriggerState triggerState,
  ) {
    final controller =
        ref.read(interactionTriggerControllerProvider.notifier);
    final theme = Theme.of(context);
    final micProgress = triggerState.voiceEnabled && triggerState.voiceListening
        ? (triggerState.micLevel / 100).clamp(0.0, 1.0)
        : 0.0;
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.sensors, color: Colors.tealAccent.shade100),
              const SizedBox(width: 8),
              Text(
                '互动触发器',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                triggerState.longPressEnabled
                    ? '手势 + 传感器可用'
                    : '长按已停用',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: micProgress,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha: .1),
            color: Colors.tealAccent,
          ),
          const SizedBox(height: 4),
          Text(
            '当前音量 ${triggerState.micLevel.toStringAsFixed(1)} dB',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
          if (!triggerState.microphoneGranted && triggerState.voiceEnabled)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '麦克风权限被拒绝，语音触发不可用，请在系统设置开启后重新授权。',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.orangeAccent),
              ),
            ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('语音触发 Magic Dust / Star Choir'),
            subtitle: Text(
              triggerState.voiceListening
                  ? '监听中，阈值 ${triggerState.voiceThreshold.toStringAsFixed(0)} dB'
                  : '关闭或等待权限后开启',
            ),
            value: triggerState.voiceEnabled,
            onChanged: (value) => controller.setVoiceEnabled(value),
          ),
          Slider(
            min: 45,
            max: 80,
            divisions: 7,
            value: triggerState.voiceThreshold,
            label: '${triggerState.voiceThreshold.toStringAsFixed(0)} dB',
            onChanged:
                triggerState.voiceEnabled ? controller.updateVoiceThreshold : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('晃动触发 Gift Fireworks / Meteor'),
            subtitle: Text(
              '灵敏度阈值 ${triggerState.shakeMagnitude.toStringAsFixed(0)}',
            ),
            value: triggerState.shakeEnabled,
            onChanged: controller.setShakeEnabled,
          ),
          Slider(
            min: 12,
            max: 26,
            divisions: 7,
            value: triggerState.shakeMagnitude,
            label: triggerState.shakeMagnitude.toStringAsFixed(0),
            onChanged:
                triggerState.shakeEnabled ? controller.updateShakeSensitivity : null,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('长按触发 Ribbon Portal / Aurora Trails'),
            value: triggerState.longPressEnabled,
            onChanged: controller.setLongPressEnabled,
          ),
          const SizedBox(height: 4),
          Text(
            '提示：语音触发需要真机 & 麦克风授权，晃动触发依赖设备加速度计；三者均会在短时间内自动恢复默认效果。',
            style:
                theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummary(StageExperienceState stageState) {
    final load = _calculateSceneLoad(stageState);
    final budget = _loadBudgetForTier(_performanceTier);
    final ratio = (load.total / budget.total).clamp(0.0, 1.0);
    final nearLimit = ratio > .85;
    final statusColor = switch (_performanceTier) {
      StagePerformanceTier.high => Colors.greenAccent,
      StagePerformanceTier.balanced => Colors.amberAccent,
      StagePerformanceTier.low => Colors.redAccent,
    };
    final notice = _performanceNotice ??
        (nearLimit ? '负载接近上限，可能需要关闭部分特效。' : null);
    final theme = Theme.of(context);
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: statusColor),
              const SizedBox(width: 8),
              Text(
                '性能状态',
                style: theme.textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '${_smoothedFps.toStringAsFixed(1)} fps',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(width: 8),
              Text(
                _performanceTier.label,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: ratio.toDouble(),
            minHeight: 4,
            color: statusColor,
            backgroundColor: Colors.white.withValues(alpha: .16),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text('简 ${load.simple}/${budget.simple}',
                  style: theme.textTheme.bodySmall),
              const SizedBox(width: 12),
              Text('特 ${load.advanced}/${budget.advanced}',
                  style: theme.textTheme.bodySmall),
              const SizedBox(width: 12),
              Text('杂 ${load.misc}/${budget.misc}',
                  style: theme.textTheme.bodySmall),
            ],
          ),
          if (notice != null) ...[
            const SizedBox(height: 4),
            Text(
              notice,
              style:
                  theme.textTheme.bodySmall?.copyWith(color: Colors.orangeAccent),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                '性能守护',
                style: theme.textTheme.bodySmall,
              ),
              if (_deviceCapability != StageDeviceCapability.high) ...[
                const SizedBox(width: 8),
                Text(
                  _deviceCapability.label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
              const Spacer(),
              Switch.adaptive(
                value: _performanceGuardEnabled,
                onChanged: (value) {
                  setState(() => _performanceGuardEnabled = value);
                  if (value) {
                    ref
                        .read(stageExperienceProvider.notifier)
                        .applyPerformanceTier(_performanceTier);
                    _enforcePerformanceBudget();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicControlsList(
    StageExperienceState stageState,
    StageExperienceController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('简单特效（Aurora/Snow 等）最多同时开启 3 个，其它可通过全屏预览体验。'),
        const SizedBox(height: 12),
        SwitchListTile(
          value: stageState.auroraEnabled,
          onChanged:
              (value) =>
                  _toggleSimpleEffect(_SimpleStageEffect.aurora, value),
          title: const Text('Aurora Sky'),
          subtitle: const Text('Shader 驱动的极光渐变'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: stageState.villageEnabled,
          onChanged:
              (value) =>
                  _toggleSimpleEffect(_SimpleStageEffect.village, value),
          title: const Text('Starry Village'),
          subtitle: const Text('远景灯光 + 烟囱蒸汽'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: stageState.snowEnabled,
          onChanged:
              (value) => _toggleSimpleEffect(_SimpleStageEffect.snow, value),
          title: const Text('Snow Field'),
          subtitle: const Text('粒子雪花 + 景深光晕'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: stageState.candyCaneEnabled,
          onChanged:
              (value) => _toggleSimpleEffect(_SimpleStageEffect.candy, value),
          title: const Text('Candy Cane Rain'),
          subtitle: const Text('糖果棒定时缓缓落下，附带渐隐光晕'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: stageState.lanternEnabled,
          onChanged:
              (value) =>
                  _toggleSimpleEffect(_SimpleStageEffect.lantern, value),
          title: const Text('Lantern Drift'),
          subtitle: const Text('纸灯漂浮轨迹'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 4),
        SwitchListTile(
          value: stageState.glowingTreeEnabled,
          onChanged:
              (value) =>
                  _toggleSimpleEffect(_SimpleStageEffect.glowingTree, value),
          title: const Text('Glowing Tree'),
          subtitle: const Text('音乐脉冲的灯串圣诞树'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 12),
        Text(
          '雪花密度 ${(stageState.snowDensity * 100).round()}%',
          style: textTheme.bodyLarge,
        ),
        Slider(
          value: stageState.snowDensity,
          onChanged: stageState.snowEnabled ? controller.setSnowDensity : null,
        ),
      ],
    );
  }

  Widget _buildStageFeaturedAdvanced(StageExperienceState stageState) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '舞台重点彩蛋',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        ..._stageQuickEffectSpecs.map((spec) {
          final enabled = _isAdvancedEffectEnabled(spec.effect, stageState);
          return SwitchListTile(
            value: enabled,
            onChanged: (value) =>
                _toggleAdvancedEffect(spec.effect, value),
            title: Text(spec.title),
            subtitle: Text(spec.subtitle),
            contentPadding: EdgeInsets.zero,
          );
        }),
      ],
    );
  }


  Widget _buildEffectsTab() {
    final feedState = ref.watch(effectFeedProvider);
    final controller = ref.read(effectFeedProvider.notifier);
    return DecoratedBox(
      key: const ValueKey('effects'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF070B12), Color(0xFF0E1422), Color(0xFF131C31)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            if (feedState.isLoadingInitial && feedState.effects.isEmpty) {
              return const _EffectSkeletonList();
            }
            if (feedState.error != null && feedState.effects.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: _buildErrorCard(
                  '特效数据加载失败：${feedState.error}',
                  onRetry: controller.retryInitial,
                ),
              );
            }
            return _EffectListView(
              state: feedState,
              controller: controller,
              onSelect: _handleEffectSelected,
            );
          },
        ),
      ),
    );
  }

  void _handleEffectSelected(FestiveEffect effect) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => _EffectDetailSheet(
            effect: effect,
            onApply: () {
              Navigator.of(context).pop();
              _applyEffect(effect);
            },
          ),
    );
  }

  void _applyEffect(FestiveEffect effect) {
    final matchedSimple = _matchSimpleEffects(effect).toList();
    final matchedAdvanced = _matchAdvancedEffects(effect).toList();
    if (matchedSimple.isEmpty && matchedAdvanced.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('请使用“全屏预览”体验 ${effect.name}')));
      return;
    }
    final desiredSet = matchedSimple.toSet();
    var applied = false;
    for (final simple in matchedSimple) {
      applied =
          _activateSimpleEffectWithReplacement(simple, desiredSet) || applied;
    }
    for (final advanced in matchedAdvanced) {
      applied = _activateAdvancedEffect(advanced) || applied;
    }
    final message =
        applied ? '已将 ${effect.name} 应用到画布' : '${effect.name} 已处于激活状态';
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildInteractionTab() {
    final ideasAsync = ref.watch(interactionIdeasProvider);
    final stageState = ref.watch(stageExperienceProvider);
    return DecoratedBox(
      key: const ValueKey('interaction'),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF080B15), Color(0xFF0E141E), Color(0xFF151D2C)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          children: [
            const ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                '互动与彩蛋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              subtitle: Text('在这里管理传感器触发、彩蛋使用教程与玩法细则。'),
            ),
            const SizedBox(height: 12),
            _buildBlessingComposer(ref.watch(blessingMessageProvider)),
            const SizedBox(height: 12),
            _buildInteractionAdvancedCard(stageState),
            const SizedBox(height: 12),
            ideasAsync.when(
              data: _buildInteractionIdeas,
              loading:
                  () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 64),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              error:
                  (error, _) => _buildErrorCard(
                    '互动创意加载失败：$error',
                    onRetry: () => ref.invalidate(interactionIdeasProvider),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionAdvancedCard(StageExperienceState stageState) {
    final controller = ref.read(stageExperienceProvider.notifier);
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.sports_esports),
              SizedBox(width: 8),
              Text(
                '互动特效遥控',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('以下彩蛋默认关闭，可在演出前预置，或现场快速切换。'),
          const SizedBox(height: 12),
          ..._interactionAdvancedEntries.map((entry) {
            final enabled = _isAdvancedEffectEnabled(entry.effect, stageState);
            return Column(
              children: [
                SwitchListTile(
                  value: enabled,
                  onChanged: (value) =>
                      _toggleAdvancedEffect(entry.effect, value),
                  title: Text(entry.title),
                  subtitle: Text(entry.subtitle),
                  contentPadding: EdgeInsets.zero,
                ),
                if (entry.effect == _AdvancedStageEffect.polarWind &&
                    stageState.polarWindEnabled)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 8, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '风力 ${(stageState.windStrength * 100).round()}%',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Slider(
                          value: stageState.windStrength,
                          min: -1,
                          max: 1,
                          onChanged: controller.setWindStrength,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInteractionIdeas(List<InteractionIdea> ideas) {
    const tutorialSteps = [
      (
        '舞台开场',
        '底部导航切到“舞台”，先确认倒计时目标，再依次开启 Aurora/Snow/Glowing Tree 等开关，必要时使用顶部模式切换器进入沉浸视图。'
      ),
      (
        '音乐与性能',
        '在舞台页右侧的音乐卡片点击播放按钮，待“音频驱动正常”后再打开开关；性能卡片可根据提示切换高性能/均衡模式，避免帧率骤降。'
      ),
      (
        '写祝福',
        '在舞台页的“写一封暖心祝福”卡片依次填写收件人、正文与署名，点击“存入祝福”后 Magic Dust 与 North Pole Mail 会立即展示该文案。'
      ),
      (
        '互动触发器',
        '切换到“互动”页，使用“互动特效遥控”中的开关勾选需要的彩蛋；Polar Wind 等需要额外参数的项目会在开关下方出现滑杆。'
      ),
      (
        '彩蛋排练',
        '继续向下查看“互动彩蛋使用教程”，按照步骤逐一尝试触摸屏幕、摇晃设备或通过麦克风/传感器触发效果，确保观众体验顺畅。'
      ),
      (
        '远程联动',
        '如需多设备同播，可在互动页的提示中根据文案准备 WebSocket/蓝牙连接脚本，让舞台端接受来自 PC/灯控的触发指令。'
      ),
    ];
    return FrostedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.menu_book),
              SizedBox(width: 8),
              Text(
                '互动彩蛋使用教程',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            '按照以下步骤部署彩蛋，演出前可通过“舞台/互动”页完成预设。',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          ...tutorialSteps.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final title = entry.value.$1;
            final description = entry.value.$2;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '$index',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message, {VoidCallback? onRetry}) {
    return FrostedCard(
      child: Row(
        children: [
          const Icon(Icons.error_outline),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('重新加载')),
        ],
      ),
    );
  }

  int _activeSimpleCount(StageExperienceState state) =>
      [
        state.auroraEnabled,
        state.snowEnabled,
        state.villageEnabled,
        state.candyCaneEnabled,
        state.lanternEnabled,
        state.glowingTreeEnabled,
      ].where((enabled) => enabled).length;

  bool _isLoadWithinBudget(
    SceneLoadEstimate load,
    SceneLoadBudget budget,
  ) {
    return load.simple <= budget.simple &&
        load.advanced <= budget.advanced &&
        load.misc <= budget.misc &&
        load.total <= budget.total;
  }

  bool _reduceMiscLoadIfNeeded(SceneLoadBudget budget) {
    var changed = false;
    final controller = ref.read(stageExperienceProvider.notifier);
    var state = ref.read(stageExperienceProvider);
    final snowLoad = (state.snowDensity * 8).round();
    if (snowLoad > budget.misc && state.snowDensity > .65) {
      controller.setSnowDensity(math.max(.5, state.snowDensity - .15));
      changed = true;
    }
    state = ref.read(stageExperienceProvider);
    if (state.polarWindEnabled) {
      final windLoad = (state.windStrength.abs() * 4).ceil();
      if (windLoad > budget.misc ~/ 2 && state.windStrength.abs() > .4) {
        controller.setWindStrength(state.windStrength.sign * .4);
        changed = true;
      }
    }
    return changed;
  }

  void _notifyReducedMisc() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已自动降低雪花/风力密度以腾出性能预算')),
    );
  }

  void _enforcePerformanceBudget({
    _SimpleStageEffect? preferredSimple,
    _AdvancedStageEffect? preferredAdvanced,
  }) {
    if (!_performanceGuardEnabled) return;
    final budget = _loadBudgetForTier(_performanceTier);
    var state = ref.read(stageExperienceProvider);
    var load = _calculateSceneLoad(state);
    if (_isLoadWithinBudget(load, budget)) return;
    final removed = <String>[];

    if (_reduceMiscLoadIfNeeded(budget)) {
      state = ref.read(stageExperienceProvider);
      load = _calculateSceneLoad(state);
      if (_isLoadWithinBudget(load, budget)) {
        _notifyReducedMisc();
        return;
      }
    }

    bool needsAdvancedReduction(SceneLoadEstimate load) =>
        load.advanced > budget.advanced || load.total > budget.total;
    bool needsSimpleReduction(SceneLoadEstimate load) =>
        load.simple > budget.simple || load.total > budget.total;

    if (needsAdvancedReduction(load)) {
      for (final effect in _loadSheddingAdvancedOrder) {
        if (effect == preferredAdvanced) continue;
        if (_isAdvancedEffectEnabled(effect, state)) {
          _setAdvancedEffectValue(effect, false);
          removed.add(_advancedEffectLabel(effect));
          state = ref.read(stageExperienceProvider);
          load = _calculateSceneLoad(state);
          if (!needsAdvancedReduction(load)) break;
        }
      }
    }

    if (needsSimpleReduction(load)) {
      for (final effect in _loadSheddingSimpleOrder) {
        if (effect == preferredSimple) continue;
        if (_isSimpleEffectEnabled(effect, state)) {
          _setSimpleEffectValue(effect, false);
          removed.add(_simpleEffectLabel(effect));
          state = ref.read(stageExperienceProvider);
          load = _calculateSceneLoad(state);
          if (!needsSimpleReduction(load)) break;
        }
      }
    }

    if (!_isLoadWithinBudget(load, budget) && preferredAdvanced != null) {
      if (_isAdvancedEffectEnabled(preferredAdvanced, state)) {
        _setAdvancedEffectValue(preferredAdvanced, false);
        removed.add(_advancedEffectLabel(preferredAdvanced));
        state = ref.read(stageExperienceProvider);
        load = _calculateSceneLoad(state);
      }
    }

    if (!_isLoadWithinBudget(load, budget) && preferredSimple != null) {
      if (_isSimpleEffectEnabled(preferredSimple, state)) {
        _setSimpleEffectValue(preferredSimple, false);
        removed.add(_simpleEffectLabel(preferredSimple));
        state = ref.read(stageExperienceProvider);
        load = _calculateSceneLoad(state);
      }
    }

    if (removed.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已暂停 ${removed.join('、')} 以保障帧率')),
      );
    } else if (!_isLoadWithinBudget(load, budget)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('当前负载过高，无法开启更多特效')),
      );
    }
  }

  bool _toggleSimpleEffect(_SimpleStageEffect effect, bool value) {
    final state = ref.read(stageExperienceProvider);
    final currently = _isSimpleEffectEnabled(effect, state);
    if (currently == value) return true;
    if (value && _activeSimpleCount(state) >= 3) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('简单特效最多同时开启 3 个')));
      return false;
    }
    _setSimpleEffectValue(effect, value);
    if (value) {
      _enforcePerformanceBudget(preferredSimple: effect);
    }
    return true;
  }

  void _toggleAdvancedEffect(_AdvancedStageEffect effect, bool value) {
    final state = ref.read(stageExperienceProvider);
    final currently = _isAdvancedEffectEnabled(effect, state);
    if (currently == value) return;
    _setAdvancedEffectValue(effect, value);
    if (value) {
      _enforcePerformanceBudget(preferredAdvanced: effect);
    }
  }

  bool _isSimpleEffectEnabled(
    _SimpleStageEffect effect,
    StageExperienceState state,
  ) {
    return switch (effect) {
      _SimpleStageEffect.aurora => state.auroraEnabled,
      _SimpleStageEffect.snow => state.snowEnabled,
      _SimpleStageEffect.village => state.villageEnabled,
      _SimpleStageEffect.candy => state.candyCaneEnabled,
      _SimpleStageEffect.lantern => state.lanternEnabled,
      _SimpleStageEffect.glowingTree => state.glowingTreeEnabled,
    };
  }

  Iterable<_SimpleStageEffect> _matchSimpleEffects(FestiveEffect effect) sync* {
    if (_matchesEffect(effect, const ['aurora', 'sky', '极光'])) {
      yield _SimpleStageEffect.aurora;
    }
    if (_matchesEffect(effect, const ['snow', 'winter', '雪'])) {
      yield _SimpleStageEffect.snow;
    }
    if (_matchesEffect(effect, const ['village', 'starry', '小镇'])) {
      yield _SimpleStageEffect.village;
    }
    if (_matchesEffect(effect, const ['candy', 'cane', '糖'])) {
      yield _SimpleStageEffect.candy;
    }
    if (_matchesEffect(effect, const ['lantern', '灯'])) {
      yield _SimpleStageEffect.lantern;
    }
    if (_matchesEffect(effect, const ['tree', 'glow', '树'])) {
      yield _SimpleStageEffect.glowingTree;
    }
  }

  Iterable<_AdvancedStageEffect> _matchAdvancedEffects(
    FestiveEffect effect,
  ) sync* {
    if (_matchesEffect(effect, const ['meteor', '流星'])) {
      yield _AdvancedStageEffect.meteor;
    }
    if (_matchesEffect(effect, const ['magic', 'dust', '彩粉', '文字'])) {
      yield _AdvancedStageEffect.magicDust;
    }
    if (_matchesEffect(effect, const ['crystal', '晶', '冰'])) {
      yield _AdvancedStageEffect.crystal;
    }
    if (_matchesEffect(effect, const ['ribbon', 'portal', '丝带', '传送'])) {
      yield _AdvancedStageEffect.ribbonPortal;
    }
    if (_matchesEffect(effect, const ['frost', '霜', '冰霜'])) {
      yield _AdvancedStageEffect.frost;
    }
    if (_matchesEffect(effect, const ['cookie', 'bake', '烘焙'])) {
      yield _AdvancedStageEffect.cookieBaking;
    }
    if (_matchesEffect(effect, const ['toy', 'parade', '玩具'])) {
      yield _AdvancedStageEffect.toyParade;
    }
    if (_matchesEffect(effect, const ['clock', 'gear', '钟', '齿轮'])) {
      yield _AdvancedStageEffect.clockwork;
    }
    if (_matchesEffect(effect, const ['mail', 'north', '信封'])) {
      yield _AdvancedStageEffect.northPoleMail;
    }
    if (_matchesEffect(effect, const ['polar', 'wind', '风'])) {
      yield _AdvancedStageEffect.polarWind;
    }
    if (_matchesEffect(effect, const ['bell', 'chime', '铃'])) {
      yield _AdvancedStageEffect.bellChime;
    }
    if (_matchesEffect(effect, const ['choir', 'star', '合唱'])) {
      yield _AdvancedStageEffect.starChoir;
    }
    if (_matchesEffect(effect, const ['aurora', 'trail', '廊道'])) {
      yield _AdvancedStageEffect.auroraTrails;
    }
    if (_matchesEffect(effect, const ['gift', 'firework', '礼物', '烟花'])) {
      yield _AdvancedStageEffect.giftFireworks;
    }
  }

  bool _activateAdvancedEffect(_AdvancedStageEffect effect) {
    final state = ref.read(stageExperienceProvider);
    if (_isAdvancedEffectEnabled(effect, state)) {
      return true;
    }
    _setAdvancedEffectValue(effect, true);
    _enforcePerformanceBudget(preferredAdvanced: effect);
    return true;
  }

  bool _matchesEffect(FestiveEffect effect, List<String> keywords) {
    final lowerName = effect.name.toLowerCase();
    final lowerTags = effect.tags.map((tag) => tag.toLowerCase()).toList();
    return keywords.any((key) {
      final lower = key.toLowerCase();
      return lowerName.contains(lower) ||
          lowerTags.any((tag) => tag.contains(lower));
    });
  }

  bool _isAdvancedEffectEnabled(
    _AdvancedStageEffect effect,
    StageExperienceState state,
  ) {
    return switch (effect) {
      _AdvancedStageEffect.meteor => state.meteorEnabled,
      _AdvancedStageEffect.magicDust => state.magicDustEnabled,
      _AdvancedStageEffect.crystal => state.crystalEnabled,
      _AdvancedStageEffect.ribbonPortal => state.ribbonPortalEnabled,
      _AdvancedStageEffect.frost => state.frostTransitionEnabled,
      _AdvancedStageEffect.cookieBaking => state.cookieBakingEnabled,
      _AdvancedStageEffect.toyParade => state.toyParadeEnabled,
      _AdvancedStageEffect.clockwork => state.clockworkEnabled,
      _AdvancedStageEffect.northPoleMail => state.northPoleMailEnabled,
      _AdvancedStageEffect.polarWind => state.polarWindEnabled,
      _AdvancedStageEffect.bellChime => state.bellChimeEnabled,
      _AdvancedStageEffect.starChoir => state.starChoirEnabled,
      _AdvancedStageEffect.auroraTrails => state.auroraTrailsEnabled,
      _AdvancedStageEffect.giftFireworks => state.giftFireworksEnabled,
    };
  }

  bool _activateSimpleEffectWithReplacement(
    _SimpleStageEffect effect,
    Set<_SimpleStageEffect> reserved,
  ) {
    var state = ref.read(stageExperienceProvider);
    if (_isSimpleEffectEnabled(effect, state)) {
      return true;
    }
    if (_activeSimpleCount(state) >= 3) {
      final replacement = _findReplacementTarget(reserved);
      if (replacement == null) {
        return false;
      }
      _setSimpleEffectValue(replacement, false);
      state = ref.read(stageExperienceProvider);
    }
    _setSimpleEffectValue(effect, true);
    _enforcePerformanceBudget(preferredSimple: effect);
    return true;
  }

  _SimpleStageEffect? _findReplacementTarget(Set<_SimpleStageEffect> reserved) {
    final state = ref.read(stageExperienceProvider);
    for (final candidate in _simpleEffectOrder) {
      if (_isSimpleEffectEnabled(candidate, state) &&
          !reserved.contains(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  void _setSimpleEffectValue(_SimpleStageEffect effect, bool value) {
    final controller = ref.read(stageExperienceProvider.notifier);
    switch (effect) {
      case _SimpleStageEffect.aurora:
        controller.toggleAurora(value);
        break;
      case _SimpleStageEffect.snow:
        controller.toggleSnow(value);
        break;
      case _SimpleStageEffect.village:
        controller.toggleVillage(value);
        break;
      case _SimpleStageEffect.candy:
        controller.toggleCandyCane(value);
        break;
      case _SimpleStageEffect.lantern:
        controller.toggleLantern(value);
        break;
      case _SimpleStageEffect.glowingTree:
        controller.toggleGlowingTree(value);
        break;
    }
  }

  void _setAdvancedEffectValue(_AdvancedStageEffect effect, bool value) {
    final controller = ref.read(stageExperienceProvider.notifier);
    switch (effect) {
      case _AdvancedStageEffect.meteor:
        controller.toggleMeteor(value);
        break;
      case _AdvancedStageEffect.magicDust:
        controller.toggleMagicDust(value);
        break;
      case _AdvancedStageEffect.crystal:
        controller.toggleCrystal(value);
        break;
      case _AdvancedStageEffect.ribbonPortal:
        controller.toggleRibbonPortal(value);
        break;
      case _AdvancedStageEffect.frost:
        controller.toggleFrostTransition(value);
        break;
      case _AdvancedStageEffect.cookieBaking:
        controller.toggleCookieBaking(value);
        break;
      case _AdvancedStageEffect.toyParade:
        controller.toggleToyParade(value);
        break;
      case _AdvancedStageEffect.clockwork:
        controller.toggleClockwork(value);
        break;
      case _AdvancedStageEffect.northPoleMail:
        controller.toggleNorthPoleMail(value);
        break;
      case _AdvancedStageEffect.polarWind:
        controller.togglePolarWind(value);
        break;
      case _AdvancedStageEffect.bellChime:
        controller.toggleBellChime(value);
        break;
      case _AdvancedStageEffect.starChoir:
        controller.toggleStarChoir(value);
        break;
      case _AdvancedStageEffect.auroraTrails:
        controller.toggleAuroraTrails(value);
        break;
      case _AdvancedStageEffect.giftFireworks:
        controller.toggleGiftFireworks(value);
        break;
    }
  }

  SceneLoadEstimate _calculateSceneLoad(StageExperienceState state) {
    var simpleLoad = 0;
    for (final entry in _simpleEffectLoad.entries) {
      if (_isSimpleEffectEnabled(entry.key, state)) {
        simpleLoad += entry.value;
      }
    }
    var advancedLoad = 0;
    for (final entry in _advancedEffectLoad.entries) {
      if (_isAdvancedEffectEnabled(entry.key, state)) {
        advancedLoad += entry.value;
      }
    }
    var misc = (state.snowDensity * 8).round();
    if (state.polarWindEnabled) {
      misc += (state.windStrength.abs() * 4).ceil();
    }
    return SceneLoadEstimate(
      simple: simpleLoad,
      advanced: advancedLoad,
      misc: misc,
    );
  }

  SceneLoadBudget _loadBudgetForTier(StagePerformanceTier tier) {
    final deviceMatrix =
        _capabilityBudgetMatrix[_deviceCapability] ??
        _capabilityBudgetMatrix[StageDeviceCapability.medium]!;
    return deviceMatrix[tier] ??
        const SceneLoadBudget(simple: 16, advanced: 15, misc: 7);
  }

  String _simpleEffectLabel(_SimpleStageEffect effect) => switch (effect) {
        _SimpleStageEffect.aurora => 'Aurora Sky',
        _SimpleStageEffect.snow => 'Snow Field',
        _SimpleStageEffect.village => 'Starry Village',
        _SimpleStageEffect.candy => 'Candy Cane Rain',
        _SimpleStageEffect.lantern => 'Lantern Drift',
        _SimpleStageEffect.glowingTree => 'Glowing Tree',
      };

  String _advancedEffectLabel(_AdvancedStageEffect effect) => switch (effect) {
        _AdvancedStageEffect.meteor => 'Meteor Shower',
        _AdvancedStageEffect.magicDust => 'Magic Dust',
        _AdvancedStageEffect.crystal => 'Crystal Particles',
        _AdvancedStageEffect.ribbonPortal => 'Ribbon Portal',
        _AdvancedStageEffect.frost => 'Frost Transition',
        _AdvancedStageEffect.cookieBaking => 'Cookie Baking',
        _AdvancedStageEffect.toyParade => 'Toy Parade',
        _AdvancedStageEffect.clockwork => 'Midnight Clockwork',
        _AdvancedStageEffect.northPoleMail => 'North Pole Mail',
        _AdvancedStageEffect.polarWind => 'Polar Wind',
        _AdvancedStageEffect.bellChime => 'Bell Chime',
        _AdvancedStageEffect.starChoir => 'Star Choir',
        _AdvancedStageEffect.auroraTrails => 'Aurora Trails',
        _AdvancedStageEffect.giftFireworks => 'Gift Fireworks',
      };
}

class _ViewModeHint extends ConsumerWidget {
  const _ViewModeHint();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(_sceneViewModeProvider);
    final text =
        mode == SceneViewMode.info
            ? '当前为信息面板模式，特效显示在内容下层。切换为沉浸视图可隐藏面板。'
            : '沉浸视图已开启，内容隐藏在特效背后。点击下方模式切换器即可恢复。';
    return Text(text);
  }
}

class _ImmersiveHint extends StatelessWidget {
  const _ImmersiveHint({required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: .6),
      borderRadius: BorderRadius.circular(32),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            const Icon(Icons.fullscreen, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                '沉浸视图已开启，若需查看面板请点击“退出沉浸”或使用模式切换器。',
                style: TextStyle(color: Colors.white),
              ),
            ),
            FilledButton(onPressed: onExit, child: const Text('退出沉浸')),
          ],
        ),
      ),
    );
  }
}

final _sceneViewModeProvider = StateProvider<SceneViewMode>(
  (ref) => SceneViewMode.info,
);

enum SceneViewMode { info, immersive }

enum _SimpleStageEffect { aurora, snow, village, candy, lantern, glowingTree }

enum _AdvancedStageEffect {
  meteor,
  magicDust,
  crystal,
  ribbonPortal,
  frost,
  cookieBaking,
  toyParade,
  clockwork,
  northPoleMail,
  polarWind,
  bellChime,
  starChoir,
  auroraTrails,
  giftFireworks,
}

const _simpleEffectOrder = [
  _SimpleStageEffect.aurora,
  _SimpleStageEffect.snow,
  _SimpleStageEffect.village,
  _SimpleStageEffect.candy,
  _SimpleStageEffect.lantern,
  _SimpleStageEffect.glowingTree,
];

const Map<_SimpleStageEffect, int> _simpleEffectLoad = {
  _SimpleStageEffect.aurora: 4,
  _SimpleStageEffect.snow: 5,
  _SimpleStageEffect.village: 3,
  _SimpleStageEffect.candy: 3,
  _SimpleStageEffect.lantern: 2,
  _SimpleStageEffect.glowingTree: 4,
};

const Map<_AdvancedStageEffect, int> _advancedEffectLoad = {
  _AdvancedStageEffect.meteor: 5,
  _AdvancedStageEffect.magicDust: 4,
  _AdvancedStageEffect.crystal: 3,
  _AdvancedStageEffect.ribbonPortal: 5,
  _AdvancedStageEffect.frost: 2,
  _AdvancedStageEffect.cookieBaking: 3,
  _AdvancedStageEffect.toyParade: 4,
  _AdvancedStageEffect.clockwork: 4,
  _AdvancedStageEffect.northPoleMail: 3,
  _AdvancedStageEffect.polarWind: 2,
  _AdvancedStageEffect.bellChime: 2,
  _AdvancedStageEffect.starChoir: 3,
  _AdvancedStageEffect.auroraTrails: 4,
  _AdvancedStageEffect.giftFireworks: 4,
};

const List<_AdvancedStageEffect> _loadSheddingAdvancedOrder = [
  _AdvancedStageEffect.magicDust,
  _AdvancedStageEffect.ribbonPortal,
  _AdvancedStageEffect.meteor,
  _AdvancedStageEffect.auroraTrails,
  _AdvancedStageEffect.giftFireworks,
  _AdvancedStageEffect.toyParade,
  _AdvancedStageEffect.clockwork,
  _AdvancedStageEffect.cookieBaking,
  _AdvancedStageEffect.crystal,
  _AdvancedStageEffect.starChoir,
  _AdvancedStageEffect.northPoleMail,
  _AdvancedStageEffect.bellChime,
  _AdvancedStageEffect.polarWind,
  _AdvancedStageEffect.frost,
];

const List<_SimpleStageEffect> _loadSheddingSimpleOrder = [
  _SimpleStageEffect.glowingTree,
  _SimpleStageEffect.candy,
  _SimpleStageEffect.aurora,
  _SimpleStageEffect.snow,
  _SimpleStageEffect.lantern,
  _SimpleStageEffect.village,
];

class SceneLoadEstimate {
  final int simple;
  final int advanced;
  final int misc;

  const SceneLoadEstimate({
    required this.simple,
    required this.advanced,
    required this.misc,
  });

  int get total => simple + advanced + misc;
}

class SceneLoadBudget {
  final int simple;
  final int advanced;
  final int misc;

  const SceneLoadBudget({
    required this.simple,
    required this.advanced,
    required this.misc,
  });

  int get total => simple + advanced + misc;
}

const _capabilityBudgetMatrix = {
  StageDeviceCapability.high: {
    StagePerformanceTier.high:
        SceneLoadBudget(simple: 20, advanced: 19, misc: 9),
    StagePerformanceTier.balanced:
        SceneLoadBudget(simple: 18, advanced: 17, misc: 8),
    StagePerformanceTier.low:
        SceneLoadBudget(simple: 15, advanced: 14, misc: 7),
  },
  StageDeviceCapability.medium: {
    StagePerformanceTier.high:
        SceneLoadBudget(simple: 18, advanced: 17, misc: 8),
    StagePerformanceTier.balanced:
        SceneLoadBudget(simple: 16, advanced: 15, misc: 7),
    StagePerformanceTier.low:
        SceneLoadBudget(simple: 13, advanced: 12, misc: 6),
  },
  StageDeviceCapability.low: {
    StagePerformanceTier.high:
        SceneLoadBudget(simple: 16, advanced: 15, misc: 7),
    StagePerformanceTier.balanced:
        SceneLoadBudget(simple: 13, advanced: 12, misc: 6),
    StagePerformanceTier.low:
        SceneLoadBudget(simple: 11, advanced: 10, misc: 5),
  },
};

class _StageQuickEffectSpec {
  final _AdvancedStageEffect effect;
  final String title;
  final String subtitle;

  const _StageQuickEffectSpec({
    required this.effect,
    required this.title,
    required this.subtitle,
  });
}

const List<_StageQuickEffectSpec> _stageQuickEffectSpecs = [
  _StageQuickEffectSpec(
    effect: _AdvancedStageEffect.magicDust,
    title: 'Magic Dust',
    subtitle: '与舞台祝福同步的粒子文字',
  ),
  _StageQuickEffectSpec(
    effect: _AdvancedStageEffect.northPoleMail,
    title: 'North Pole Mail',
    subtitle: '信封坠落 + 雪狐带来祝福',
  ),
  _StageQuickEffectSpec(
    effect: _AdvancedStageEffect.giftFireworks,
    title: 'Gift Fireworks',
    subtitle: '礼盒烟花自动触发',
  ),
  _StageQuickEffectSpec(
    effect: _AdvancedStageEffect.bellChime,
    title: 'Bell Chime',
    subtitle: '铃铛震动 + 音符光点',
  ),
];

class _InteractionAdvancedEntry {
  final _AdvancedStageEffect effect;
  final String title;
  final String subtitle;

  const _InteractionAdvancedEntry({
    required this.effect,
    required this.title,
    required this.subtitle,
  });
}

const List<_InteractionAdvancedEntry> _interactionAdvancedEntries = [
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.meteor,
    title: 'Meteor Shower',
    subtitle: '夜空流星与拖尾扫射',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.magicDust,
    title: 'Magic Dust',
    subtitle: '祝福粒子 + 语音触发',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.crystal,
    title: 'Crystal Particles',
    subtitle: 'Playground 拖拽生成晶体',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.ribbonPortal,
    title: 'Ribbon Portal',
    subtitle: '长按触发丝带传送门',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.frost,
    title: 'Frost Transition',
    subtitle: '切换页面的冰霜转场',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.cookieBaking,
    title: 'Cookie Baking',
    subtitle: '午夜烘焙蒸汽场景',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.polarWind,
    title: 'Polar Wind',
    subtitle: '设备摇晃/麦克风驱动风力',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.toyParade,
    title: 'Toy Parade',
    subtitle: '玩具巡游 + 粒子火花',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.clockwork,
    title: 'Midnight Clockwork',
    subtitle: '齿轮钟表仪式感',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.northPoleMail,
    title: 'North Pole Mail',
    subtitle: '信封坠落 + 雪狐',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.bellChime,
    title: 'Bell Chime',
    subtitle: '铃铛震动 + 音符光点',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.giftFireworks,
    title: 'Gift Fireworks',
    subtitle: '礼盒烟花定时触发',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.starChoir,
    title: 'Star Choir',
    subtitle: '音符光球响应音量',
  ),
  _InteractionAdvancedEntry(
    effect: _AdvancedStageEffect.auroraTrails,
    title: 'Aurora Trails',
    subtitle: '镜头移动产生极光拖尾',
  ),
];

class _EffectListView extends StatefulWidget {
  const _EffectListView({
    required this.state,
    required this.controller,
    required this.onSelect,
  });

  final EffectFeedState state;
  final EffectFeedController controller;
  final ValueChanged<FestiveEffect> onSelect;

  @override
  State<_EffectListView> createState() => _EffectListViewState();
}

class _EffectListViewState extends State<_EffectListView>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      widget.controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
      controller: _scrollController,
      key: const PageStorageKey('effects-scroll'),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: widget.state.effects.length + 2,
      itemBuilder: (context, index) {
        if (index == 0) {
          return const _EffectListHeader();
        }
        if (index == widget.state.effects.length + 1) {
          return _EffectListFooter(
            state: widget.state,
            onRetry: widget.controller.loadMore,
          );
        }
        final effect = widget.state.effects[index - 1];
        return RepaintBoundary(
          key: ValueKey(effect.name),
          child: _EffectListTile(
            effect: effect,
            onTap: () => widget.onSelect(effect),
          ),
        );
      },
    );
  }
}

class _EffectDetailSheet extends StatelessWidget {
  const _EffectDetailSheet({required this.effect, required this.onApply});

  final FestiveEffect effect;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: bottomPadding + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(effect.icon),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  effect.name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(effect.description),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children:
                effect.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                    )
                    .toList(),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    navigator.pop();
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => EffectPreviewPage(effect: effect),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                  icon: const Icon(Icons.fullscreen),
                  label: const Text('全屏预览'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onApply,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('应用到画布'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EffectSkeletonList extends StatelessWidget {
  const _EffectSkeletonList();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: 4,
      itemBuilder: (context, index) => const _EffectSkeletonTile(),
    );
  }
}

class _EffectSkeletonTile extends StatelessWidget {
  const _EffectSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: .06),
              Colors.white.withValues(alpha: .02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
    );
  }
}

class _EffectListHeader extends StatelessWidget {
  const _EffectListHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            '沉浸特效栈',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text('覆盖 Aurora Sky、Snow Field、Lantern Drift 等 20+ 模块。'),
        ],
      ),
    );
  }
}

class _EffectListFooter extends StatelessWidget {
  const _EffectListFooter({required this.state, required this.onRetry});

  final EffectFeedState state;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null && state.effects.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text('加载更多特效失败：${state.error}'),
            TextButton(onPressed: onRetry, child: const Text('重试加载')),
          ],
        ),
      );
    }
    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('已展示全部特效')),
      );
    }
    return const SizedBox(height: 48);
  }
}

class _EffectListTile extends StatelessWidget {
  const _EffectListTile({required this.effect, required this.onTap});

  final FestiveEffect effect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: .08)),
          color: Colors.white.withValues(alpha: .05),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(effect.icon),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      effect.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                effect.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    effect.tags
                        .map(
                          (tag) => Chip(
                            label: Text(tag),
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                          ),
                        )
                        .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

