import '../../domain/entities/interaction_idea.dart';
import '../sources/mock_experience_data.dart';
import 'effect_repository.dart';

class MockExperienceRepository
    implements EffectRepository, InteractionRepository {
  const MockExperienceRepository();

  @override
  Future<EffectPage> fetchEffects({
    required int offset,
    required int limit,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final slice = mockEffects.skip(offset).take(limit).toList();
    final hasMore = offset + slice.length < mockEffects.length;
    return EffectPage(items: slice, hasMore: hasMore);
  }

  @override
  Future<List<InteractionIdea>> fetchIdeas() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return List<InteractionIdea>.unmodifiable(mockInteractionIdeas);
  }
}
