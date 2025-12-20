import 'countdown_target.dart';

class CountdownSnapshot {
  final CountdownTarget target;
  final Duration remaining;

  const CountdownSnapshot({required this.target, required this.remaining});

  int get days => remaining.inDays;

  int get hours => remaining.inHours % 24;

  int get minutes => remaining.inMinutes % 60;

  bool get completed => remaining <= Duration.zero;

  CountdownSnapshot clamp() =>
      completed
          ? CountdownSnapshot(target: target, remaining: Duration.zero)
          : this;
}
