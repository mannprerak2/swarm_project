/// Schedule with exact times.
import 'dart:collection';

import 'package:engifest_scheduler/src/event.dart';

import '../engifest_scheduler.dart';

typedef StartTimeGenerator = DateTime Function(int dayNumber);

/// An unmodifiable instance of a scheduled day.
class BakedDay {
  final List<BakedEvent> _list = <BakedEvent>[];

  UnmodifiableListView<BakedEvent> _listView;

  BakedDay() {
    _listView = UnmodifiableListView<BakedEvent>(_list);
  }

  Duration get duration {
    final start = _list.first.time;
    return start.difference(end);
  }

  DateTime get end =>
      _list.last.time.add(Duration(minutes: _list.last.event.length));

  UnmodifiableListView<BakedEvent> get list => _listView;

  void _add(BakedEvent event) => _list.add(event);
}

/// An unmodifiable instance of schedule. This is used by evaluators instead
/// of the Schedule phenotype for convenience.
class BakedSchedule {
  final List<BakedEvent> _list = <BakedEvent>[];

  final Map<int, BakedDay> _days = <int, BakedDay>{};

  UnmodifiableListView<BakedEvent> _listView;

  UnmodifiableMapView<int, BakedDay> _unmodifiableDays;

  final StartTimeGenerator _startTimeGenerator;

  BakedSchedule(List<Event> ordered,
      {DateTime Function(int dayNumber) generateStartTime})
      : _startTimeGenerator = generateStartTime ?? _defaultGenerateStartTime {
    _fillList(ordered);
    _listView = UnmodifiableListView<BakedEvent>(_list);
    _unmodifiableDays = UnmodifiableMapView<int, BakedDay>(_days);
  }

  /// Can be seen as 1-based list of days (first day is `days[1]`).
  UnmodifiableMapView<int, BakedDay> get days => _unmodifiableDays;

  UnmodifiableListView<BakedEvent> get list => _listView;

  void _fillList(List<Event> ordered) {
    var dayNumber = 1;
    var time = _startTimeGenerator(dayNumber);
    for (final event in ordered) {
      final baked = BakedEvent(time, event);
      _list.add(baked);
      _days.putIfAbsent(dayNumber, () => BakedDay())._add(baked);
      time = time.add(Duration(minutes: event.length));
      if (event.isDayBreak) {
        dayNumber += 1;
        time = _startTimeGenerator(dayNumber);
      }
    }
  }

  /// Start at 10am by default. Use DartConf's date (we don't care about the
  /// date so it doesn't really matter yet).
  static DateTime _defaultGenerateStartTime(int dayNumber) {
    return DateTime.utc(2018, 1, 20 + dayNumber, 10);
  }
}

/// An unmodifiable instance of a scheduled event. Includes the [Event]
/// itself as well as the [time] for which it is scheduled.
class BakedEvent {
  final DateTime time;
  final Event event;

  BakedEvent(this.time, this.event);
}
