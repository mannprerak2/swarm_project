import 'dart:math';
import 'package:engifest_scheduler/src/baked_schedule.dart';
import 'package:engifest_scheduler/src/evaluator.dart';
import 'package:engifest_scheduler/src/event.dart';
import 'package:darwin/darwin.dart';

/// Days in fest.
const days = 3;

class Schedule extends Phenotype<int, ScheduleEvaluatorPenalty> {
  final int eventCount;

  final int maxLunchBreaksCount;

  final int maxDayBreaksCount;

  final int orderRange;

  int _geneCount;

  final _random = Random();

  Schedule(List<Event> events)
      : eventCount = events.length,
        maxDayBreaksCount = days - 1,
        maxLunchBreaksCount = days,
        orderRange = events.length * 6 {
    _geneCount = eventCount + maxDayBreaksCount + maxLunchBreaksCount;
  }

  factory Schedule.random(List<Event> events) {
    final schedule = Schedule(events);
    schedule.genes = List<int>(schedule._geneCount);
    for (var i = 0; i < schedule._geneCount; i++) {
      schedule.genes[i] = schedule._random.nextInt(schedule.orderRange);
    }
    return schedule;
  }

  @override
  int get hashCode {
    return genes.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! Schedule) return false;
    return hashCode == other.hashCode;
  }

  @override
  num computeHammingDistance(Schedule other) {
    var aLast = -1;
    var bLast = -1;
    var differences = 0;
    bool aFound;
    bool bFound;
    do {
      aFound = false;
      bFound = false;
      var aBestCandidateValue = orderRange * 1000;
      var bBestCandidateValue = orderRange * 1000;
      int aBestCandidateIndex;
      int bBestCandidateIndex;
      // go through all genes and find the current lowest one
      for (var i = 0; i < _geneCount; i++) {
        final aCurrent = genes[i];
        if (aLast < aCurrent && aCurrent < aBestCandidateValue) {
          aBestCandidateValue = aCurrent;
          aBestCandidateIndex = i;
          aFound = true;
        }
        final bCurrent = other.genes[i];
        if (bLast < bCurrent && bCurrent < bBestCandidateValue) {
          bBestCandidateValue = bCurrent;
          bBestCandidateIndex = i;
          bFound = true;
        }
      }
      if (aFound || bFound) {
        if (aBestCandidateIndex != bBestCandidateIndex) {
          // Add a difference when the value was on a different index.
          differences += 1;
        }
        if (aFound) {
          aLast = aBestCandidateValue;
        }
        if (bFound) {
          bLast = bBestCandidateValue;
        }
      }
    } while (aFound || bFound);

    assert(differences <= _geneCount);

    return differences / _geneCount;
  }

  String generateSchedule(List<Event> events) {
    final ordered = getOrdered(events);
    final baked = BakedSchedule(ordered);
    final buf = StringBuffer();

    for (final slot in baked.list) {
      buf.write(''.padRight(2));
      final hour = slot.time.hour;
      final minute = slot.time.minute.toString().padLeft(2, '0');
      buf.write('$hour:$minute');
      buf.write(''.padRight(2));
      buf.write(slot.event.name.padRight(60));
      buf.write(''.padRight(2));
      buf.write(slot.event.length);
      buf.writeln();
    }
    return buf.toString();
  }

  Iterable<List<Event>> getBlocks(
      List<Event> ordered, List<Event> events) sync* {
    var block = <Event>[];
    for (final event in ordered) {
      if (event.isBreak) {
        yield block;
        block = <Event>[];
        continue;
      }
      block.add(event);
    }
    yield block;
  }

  Iterable<List<Event>> getBlocksBetweenLargeMeal(
      List<Event> ordered, List<Event> events) sync* {
    var block = <Event>[];
    for (final event in ordered) {
      if (event.isLunch || event.isDayBreak) {
        yield block;
        block = <Event>[];
        continue;
      }
      block.add(event);
    }
    yield block;
  }

  Iterable<List<Event>> getDays(List<Event> ordered, List<Event> events) sync* {
    var day = <Event>[];
    for (final event in ordered) {
      if (event.isDayBreak) {
        yield day;
        day = <Event>[];
        continue;
      }
      day.add(event);
    }
    yield day;
  }

  int getLength(Iterable<Event> events) {
    var length = 0;
    for (final event in events) {
      length += event.length;
    }
    return length;
  }

  List<Event> getOrdered(List<Event> original) {
    var geneIndex = 0;
    // Maps events to their order.
    final allEvents = <Event, int>{};
    for (var i = 0; i < original.length; i++) {
      allEvents[original[i]] = genes[geneIndex];
      geneIndex += 1;
    }

    for (var i = 0; i < maxLunchBreaksCount; i++) {
      final lunch = Event.defaultLunch();
      allEvents[lunch] = genes[geneIndex];
      geneIndex += 1;
    }

    for (var i = 0; i < maxDayBreaksCount; i++) {
      final dayBreak = Event.defaultDayBreak();
      allEvents[dayBreak] = genes[geneIndex];
      geneIndex += 1;
    }
    final ordered = List<Event>.from(allEvents.keys);
    ordered.sort((a, b) => allEvents[a].compareTo(allEvents[b]));
    return ordered;
  }

  /// Returns an iterable of doubles - events that are next to each
  /// other with no break between.
  Iterable<List<Event>> getTuples(
      List<Event> ordered, List<Event> events) sync* {
    for (var i = 1; i < ordered.length; i++) {
      final a = ordered[i - 1];
      final b = ordered[i];
      yield [a, b];
    }
  }

  @override
  int mutateGene(int gene, num strength) {
    var maxDiff = (orderRange * strength).round();
    var diff = _random.nextInt(maxDiff) - (orderRange ~/ 2);
    return (gene + diff) % orderRange;
  }
}
