import 'dart:async';

import '../value_objects/countdown_snapshot.dart';
import '../value_objects/countdown_target.dart';

class CountdownService {
  CountdownSnapshot snapshot({required CountdownTarget target, DateTime? now}) {
    final anchor = now ?? DateTime.now();
    final targetMoment = target.resolveNext(anchor);
    final remaining = targetMoment.difference(anchor);
    return CountdownSnapshot(target: target, remaining: remaining).clamp();
  }

  Stream<CountdownSnapshot> watch(CountdownTarget target) async* {
    yield snapshot(target: target);
    yield* Stream.periodic(
      const Duration(seconds: 1),
      (_) => snapshot(target: target),
    );
  }
}
