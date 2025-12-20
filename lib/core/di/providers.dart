import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/effect_repository.dart';
import '../../data/repositories/mock_experience_repository.dart';
import '../../domain/services/countdown_service.dart';

final countdownServiceProvider = Provider<CountdownService>(
  (ref) => CountdownService(),
);

final _mockExperienceRepositoryProvider = Provider<MockExperienceRepository>((
  ref,
) {
  return const MockExperienceRepository();
});

final effectRepositoryProvider = Provider<EffectRepository>(
  (ref) => ref.watch(_mockExperienceRepositoryProvider),
);

final interactionRepositoryProvider = Provider<InteractionRepository>(
  (ref) => ref.watch(_mockExperienceRepositoryProvider),
);
