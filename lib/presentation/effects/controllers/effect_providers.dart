import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/festive_effect.dart';
import '../../../data/repositories/effect_repository.dart';

class EffectFeedState {
  final List<FestiveEffect> effects;
  final bool isLoadingInitial;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;

  const EffectFeedState({
    required this.effects,
    required this.isLoadingInitial,
    required this.isLoadingMore,
    required this.hasMore,
    this.error,
  });

  factory EffectFeedState.initial() => const EffectFeedState(
    effects: [],
    isLoadingInitial: true,
    isLoadingMore: false,
    hasMore: true,
    error: null,
  );

  EffectFeedState copyWith({
    List<FestiveEffect>? effects,
    bool? isLoadingInitial,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return EffectFeedState(
      effects: effects ?? this.effects,
      isLoadingInitial: isLoadingInitial ?? this.isLoadingInitial,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

class EffectFeedController extends StateNotifier<EffectFeedState> {
  EffectFeedController(this._repository) : super(EffectFeedState.initial()) {
    loadInitial();
  }

  static const _pageSize = 6;
  final EffectRepository _repository;
  bool _initialRequested = false;

  Future<void> loadInitial() async {
    if (_initialRequested && !state.isLoadingInitial) return;
    _initialRequested = true;
    state = state.copyWith(isLoadingInitial: true, error: null);
    try {
      final page = await _repository.fetchEffects(offset: 0, limit: _pageSize);
      state = EffectFeedState(
        effects: page.items,
        isLoadingInitial: false,
        isLoadingMore: false,
        hasMore: page.hasMore,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoadingInitial: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoadingInitial || !state.hasMore) {
      return;
    }
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      final page = await _repository.fetchEffects(
        offset: state.effects.length,
        limit: _pageSize,
      );
      state = state.copyWith(
        effects: [...state.effects, ...page.items],
        isLoadingMore: false,
        hasMore: page.hasMore,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> retryInitial() async {
    _initialRequested = false;
    await loadInitial();
  }
}

final effectFeedProvider =
    StateNotifierProvider<EffectFeedController, EffectFeedState>((ref) {
      final repository = ref.watch(effectRepositoryProvider);
      return EffectFeedController(repository);
    });
