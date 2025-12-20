enum CountdownTarget { christmasEve, christmasDay }

extension CountdownTargetX on CountdownTarget {
  int get day => switch (this) {
    CountdownTarget.christmasEve => 24,
    CountdownTarget.christmasDay => 25,
  };

  int get activationHour => switch (this) {
    CountdownTarget.christmasEve => 18,
    CountdownTarget.christmasDay => 0,
  };

  String get label => switch (this) {
    CountdownTarget.christmasEve => '平安夜',
    CountdownTarget.christmasDay => '圣诞日',
  };

  DateTime scheduleForYear(int year) => DateTime(year, 12, day, activationHour);

  DateTime resolveNext(DateTime now) {
    final scheduled = scheduleForYear(now.year);
    if (scheduled.isAfter(now)) {
      return scheduled;
    }
    return scheduleForYear(now.year + 1);
  }
}
