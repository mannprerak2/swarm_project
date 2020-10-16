import 'package:engifest_scheduler/src/break_type.dart';
import 'package:engifest_scheduler/constants.dart';

class Event {
  static final RegExp _dayPreferencePattern = RegExp(r'^day(\d+)$');
  final String name;
  final Set<String> tags;
  final Set<String> avoid;
  final Set<String> seek;

  final int length;

  Event(this.name, this.length,
      {Iterable<String> tags = const [],
      Iterable<String> avoid = const [],
      Iterable<String> seek = const []})
      : tags = Set.from(tags),
        avoid = Set.from(avoid),
        seek = Set.from(seek);

  Event.defaultDayBreak()
      : this(printBreakType(BreakType.day), 0,
            tags: [day_break, break_], avoid: [break_]);

  Event.defaultExtendedLunch()
      : this(printBreakType(BreakType.lunch), 60 + 15,
            tags: [lunch, break_], avoid: [break_]);

  Event.defaultLunch()
      : this(printBreakType(BreakType.lunch), 60,
            tags: [lunch, break_], avoid: [break_]);

  Event.defaultShortBreak()
      : this(printBreakType(BreakType.short), 30,
            tags: [break_], avoid: [break_]);

  bool get isBreak => tags.contains(break_);

  bool get isDayBreak => tags.contains(day_break);

  /// Algorithm will try hard to put `day_end` talks at end of day. Use
  /// for things like wrap-ups or big events.
  bool get isDayEnd => tags.contains(day_end);

  /// Algorithm will try to schedule exciting talks after food (or at start
  /// of day) to get people going.
  bool get isEnergetic => tags.contains(energetic);

  /// Algorithm will try to schedule exciting talks at start of day so they're
  /// not wasted in the middle of unimpressive talks.
  bool get isExciting => tags.contains(exciting);

  /// Algorithm will try hard to put keynote at start of day 1 or at least
  /// at start of a day.
  bool get isInauguration => tags.contains(inauguration);

  bool get isLunch => tags.contains(lunch);

  /// Returns the preferred day as specified by a [tag] (like `day1` or `day2`).
  /// Returns `null` when no day is preferred.
  int get preferredDay {
    for (final tag in tags) {
      final match = _dayPreferencePattern.firstMatch(tag);
      if (match == null) continue;
      return int.parse(match.group(1));
    }
    return null;
  }

  @override
  String toString() => '$name ($length m)';
}
