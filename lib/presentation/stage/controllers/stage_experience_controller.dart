import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/value_objects/countdown_target.dart';
import 'stage_performance_advisor.dart';

class StageExperienceState {
  final CountdownTarget target;
  final bool snowEnabled;
  final bool auroraEnabled;
  final bool lanternEnabled;
  final bool villageEnabled;
  final bool candyCaneEnabled;
  final bool glowingTreeEnabled;
  final bool meteorEnabled;
  final bool magicDustEnabled;
  final bool crystalEnabled;
  final bool ribbonPortalEnabled;
  final bool frostTransitionEnabled;
  final bool cookieBakingEnabled;
  final bool toyParadeEnabled;
  final bool clockworkEnabled;
  final bool northPoleMailEnabled;
  final bool polarWindEnabled;
  final bool bellChimeEnabled;
  final bool starChoirEnabled;
  final bool auroraTrailsEnabled;
  final bool giftFireworksEnabled;
  final double windStrength;
  final double snowDensity;

  const StageExperienceState({
    required this.target,
    required this.snowEnabled,
    required this.auroraEnabled,
    required this.lanternEnabled,
    required this.villageEnabled,
    required this.candyCaneEnabled,
    required this.glowingTreeEnabled,
    required this.meteorEnabled,
    required this.magicDustEnabled,
    required this.crystalEnabled,
    required this.ribbonPortalEnabled,
    required this.frostTransitionEnabled,
    required this.cookieBakingEnabled,
    required this.toyParadeEnabled,
    required this.clockworkEnabled,
    required this.northPoleMailEnabled,
    required this.polarWindEnabled,
    required this.bellChimeEnabled,
    required this.starChoirEnabled,
    required this.auroraTrailsEnabled,
    required this.giftFireworksEnabled,
    required this.windStrength,
    required this.snowDensity,
  });

  factory StageExperienceState.initial() => const StageExperienceState(
    target: CountdownTarget.christmasEve,
    snowEnabled: true,
    auroraEnabled: true,
    lanternEnabled: false,
    villageEnabled: true,
    candyCaneEnabled: false,
    glowingTreeEnabled: false,
    meteorEnabled: false,
    magicDustEnabled: false,
    crystalEnabled: false,
    ribbonPortalEnabled: false,
    frostTransitionEnabled: false,
    cookieBakingEnabled: false,
    toyParadeEnabled: false,
    clockworkEnabled: false,
    northPoleMailEnabled: false,
    polarWindEnabled: false,
    bellChimeEnabled: false,
    starChoirEnabled: false,
    auroraTrailsEnabled: false,
    giftFireworksEnabled: false,
    windStrength: 0,
    snowDensity: .75,
  );

  StageExperienceState copyWith({
    CountdownTarget? target,
    bool? snowEnabled,
    bool? auroraEnabled,
    bool? lanternEnabled,
    bool? villageEnabled,
    bool? candyCaneEnabled,
    bool? glowingTreeEnabled,
    bool? meteorEnabled,
    bool? magicDustEnabled,
    bool? crystalEnabled,
    bool? ribbonPortalEnabled,
    bool? frostTransitionEnabled,
    bool? cookieBakingEnabled,
    bool? toyParadeEnabled,
    bool? clockworkEnabled,
    bool? northPoleMailEnabled,
    bool? polarWindEnabled,
    bool? bellChimeEnabled,
    bool? starChoirEnabled,
    bool? auroraTrailsEnabled,
    bool? giftFireworksEnabled,
    double? snowDensity,
    double? windStrength,
  }) {
    return StageExperienceState(
      target: target ?? this.target,
      snowEnabled: snowEnabled ?? this.snowEnabled,
      auroraEnabled: auroraEnabled ?? this.auroraEnabled,
      lanternEnabled: lanternEnabled ?? this.lanternEnabled,
      villageEnabled: villageEnabled ?? this.villageEnabled,
      candyCaneEnabled: candyCaneEnabled ?? this.candyCaneEnabled,
      glowingTreeEnabled: glowingTreeEnabled ?? this.glowingTreeEnabled,
      meteorEnabled: meteorEnabled ?? this.meteorEnabled,
      magicDustEnabled: magicDustEnabled ?? this.magicDustEnabled,
      crystalEnabled: crystalEnabled ?? this.crystalEnabled,
      ribbonPortalEnabled: ribbonPortalEnabled ?? this.ribbonPortalEnabled,
      frostTransitionEnabled:
          frostTransitionEnabled ?? this.frostTransitionEnabled,
      cookieBakingEnabled: cookieBakingEnabled ?? this.cookieBakingEnabled,
      toyParadeEnabled: toyParadeEnabled ?? this.toyParadeEnabled,
      clockworkEnabled: clockworkEnabled ?? this.clockworkEnabled,
      northPoleMailEnabled: northPoleMailEnabled ?? this.northPoleMailEnabled,
      polarWindEnabled: polarWindEnabled ?? this.polarWindEnabled,
      bellChimeEnabled: bellChimeEnabled ?? this.bellChimeEnabled,
      starChoirEnabled: starChoirEnabled ?? this.starChoirEnabled,
      auroraTrailsEnabled: auroraTrailsEnabled ?? this.auroraTrailsEnabled,
      giftFireworksEnabled: giftFireworksEnabled ?? this.giftFireworksEnabled,
      snowDensity: snowDensity ?? this.snowDensity,
      windStrength: windStrength ?? this.windStrength,
    );
  }
}

class StageExperienceController extends StateNotifier<StageExperienceState> {
  StageExperienceController() : super(StageExperienceState.initial());

  StagePerformanceTier _lastAppliedTier = StagePerformanceTier.high;

  void setTarget(CountdownTarget target) {
    state = state.copyWith(target: target);
  }

  void toggleSnow(bool value) {
    state = state.copyWith(snowEnabled: value);
  }

  void toggleAurora(bool value) {
    state = state.copyWith(auroraEnabled: value);
  }

  void toggleLantern(bool value) {
    state = state.copyWith(lanternEnabled: value);
  }

  void toggleVillage(bool value) {
    state = state.copyWith(villageEnabled: value);
  }

  void toggleCandyCane(bool value) {
    state = state.copyWith(candyCaneEnabled: value);
  }

  void toggleGlowingTree(bool value) {
    state = state.copyWith(glowingTreeEnabled: value);
  }

  void toggleMeteor(bool value) {
    state = state.copyWith(meteorEnabled: value);
  }

  void toggleMagicDust(bool value) {
    state = state.copyWith(magicDustEnabled: value);
  }

  void toggleCrystal(bool value) {
    state = state.copyWith(crystalEnabled: value);
  }

  void toggleRibbonPortal(bool value) {
    state = state.copyWith(ribbonPortalEnabled: value);
  }

  void toggleFrostTransition(bool value) {
    state = state.copyWith(frostTransitionEnabled: value);
  }

  void toggleCookieBaking(bool value) {
    state = state.copyWith(cookieBakingEnabled: value);
  }

  void toggleToyParade(bool value) {
    state = state.copyWith(toyParadeEnabled: value);
  }

  void toggleClockwork(bool value) {
    state = state.copyWith(clockworkEnabled: value);
  }

  void toggleNorthPoleMail(bool value) {
    state = state.copyWith(northPoleMailEnabled: value);
  }

  void togglePolarWind(bool value) {
    state = state.copyWith(
      polarWindEnabled: value,
      windStrength: value ? state.windStrength : 0,
    );
  }

  void toggleBellChime(bool value) {
    state = state.copyWith(bellChimeEnabled: value);
  }

  void toggleStarChoir(bool value) {
    state = state.copyWith(starChoirEnabled: value);
  }

  void toggleAuroraTrails(bool value) {
    state = state.copyWith(auroraTrailsEnabled: value);
  }

  void toggleGiftFireworks(bool value) {
    state = state.copyWith(giftFireworksEnabled: value);
  }

  void setSnowDensity(double value) {
    state = state.copyWith(snowDensity: value.clamp(0, 1));
  }

  void setWindStrength(double value) {
    state = state.copyWith(windStrength: value.clamp(-1, 1));
  }

  void applyPerformanceTier(StagePerformanceTier tier) {
    if (_lastAppliedTier == tier) return;
    _lastAppliedTier = tier;
    var next = state;
    var changed = false;
    void update(StageExperienceState updated) {
      next = updated;
      changed = true;
    }

    switch (tier) {
      case StagePerformanceTier.high:
        break;
      case StagePerformanceTier.balanced:
        if (next.snowDensity > .75) {
          update(next.copyWith(snowDensity: .75));
        }
        break;
      case StagePerformanceTier.low:
        if (next.snowDensity > .6) {
          update(next.copyWith(snowDensity: .6));
        }
        if (next.meteorEnabled) {
          update(next.copyWith(meteorEnabled: false));
        }
        if (next.magicDustEnabled) {
          update(next.copyWith(magicDustEnabled: false));
        }
        if (next.ribbonPortalEnabled) {
          update(next.copyWith(ribbonPortalEnabled: false));
        }
        if (next.auroraTrailsEnabled) {
          update(next.copyWith(auroraTrailsEnabled: false));
        }
        if (next.giftFireworksEnabled) {
          update(next.copyWith(giftFireworksEnabled: false));
        }
        break;
    }

    if (changed && state != next) {
      state = next;
    }
  }
}

final stageExperienceProvider =
    StateNotifierProvider<StageExperienceController, StageExperienceState>(
      (ref) => StageExperienceController(),
    );
