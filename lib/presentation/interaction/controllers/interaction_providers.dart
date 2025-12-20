import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../domain/entities/interaction_idea.dart';

final interactionIdeasProvider = FutureProvider<List<InteractionIdea>>((
  ref,
) async {
  final repository = ref.watch(interactionRepositoryProvider);
  return repository.fetchIdeas();
});
