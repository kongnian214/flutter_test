import '../../domain/entities/festive_effect.dart';
import '../../domain/entities/interaction_idea.dart';

class EffectPage {
  final List<FestiveEffect> items;
  final bool hasMore;

  const EffectPage({required this.items, required this.hasMore});
}

abstract class EffectRepository {
  Future<EffectPage> fetchEffects({required int offset, required int limit});
}

abstract class InteractionRepository {
  Future<List<InteractionIdea>> fetchIdeas();
}
