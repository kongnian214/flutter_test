import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/value_objects/countdown_snapshot.dart';
import '../../../domain/value_objects/countdown_target.dart';
import 'stage_experience_controller.dart';

final countdownStreamProvider = StreamProvider.autoDispose<CountdownSnapshot>((
  ref,
) {
  final CountdownTarget target = ref.watch(
    stageExperienceProvider.select((s) => s.target),
  );
  final service = ref.watch(countdownServiceProvider);
  return service.watch(target);
});
