import 'dart:async';
import 'dart:math';
import 'package:engifest_scheduler/src/baked_schedule.dart';
import 'package:engifest_scheduler/src/schedule_phenotype.dart';
import 'package:engifest_scheduler/src/event.dart';
import 'package:darwin/darwin.dart';

class ScheduleEvaluator
    extends PhenotypeEvaluator<Schedule, int, ScheduleEvaluatorPenalty> {
  static const _lunchHourMin = 12;

  static const _lunchHourMax = 13;

  final List<Event> events;

  final int targetDays = 2;

  final List<CustomEvaluator> _customEvaluators;

  /// Minimal amount of time between breaks.
  final int minBlockLength = 90;

  final int maxMinutesWithoutBreak = 90;

  final int maxMinutesWithoutLargeMeal = 5 * 60;

  final int maxMinutesInDay = 8 * 60;

  final int targetLunchesPerDay = 1;

  ScheduleEvaluator(this.events, this._customEvaluators);

  @override
  Future<ScheduleEvaluatorPenalty> evaluate(Schedule phenotype) {
    return Future.value(internalEvaluate(phenotype));
  }

  ScheduleEvaluatorPenalty internalEvaluate(Schedule phenotype) {
    final penalty = ScheduleEvaluatorPenalty();

    final ordered = phenotype.getOrdered(events);

    for (final event in events) {
      if (!ordered.contains(event)) {
        // A event was left out of the program entirely.
        penalty.constraints += 50.0;
      }
    }

    if (ordered.any((s) => s.isKeynote)) {
      // There should be a keynote early on day 1.
      final firstKeynote = ordered.firstWhere((s) => s.isKeynote);
      penalty.constraints += ordered.indexOf(firstKeynote).toDouble();
    }

    for (var i = 0; i < ordered.length; i++) {
      for (var j = i + 1; j < ordered.length; j++) {
        final first = ordered[i];
        final second = ordered[j];
        if (first.shouldComeAfter(second)) {
          penalty.constraints += 10.0 + (j - i) / 20;
        }
      }
    }

    final days = phenotype.getDays(ordered, events).toList(growable: false);
    penalty.constraints += (targetDays - days.length).abs() * 10.0;

    var dayNumber = 0;
    for (final day in days) {
      dayNumber += 1;
      if (day.isEmpty) {
        penalty.cultural += 1.0;
        continue;
      }
      for (final keynoteEvent in day.where((s) => s.isKeynote)) {
        // Keynotes should start days.
        penalty.cultural += day.indexOf(keynoteEvent) * 2.0;
      }
      for (final excitingEvent in day.where((s) => s.isExciting)) {
        penalty.awareness += day.indexOf(excitingEvent) / 2;
      }
      for (final dayEndEvent in day.where((s) => s.isDayEnd)) {
        // end_day events should end the day.
        penalty.constraints +=
            (day.length - day.indexOf(dayEndEvent) - 1) * 2.0;
      }
      for (final _ in day.where(
          (s) => s.preferredDay != null && s.preferredDay != dayNumber)) {
        // Events should be scheduled for days they were tagged with (`day2`).
        penalty.constraints += 10.0;
      }
      // Only this many lunches per day. (Normally 1.)
      penalty.cultural +=
          (targetLunchesPerDay - day.where((s) => s.isLunch).length).abs() *
              10.0;
      // Keep the days not too long.
      penalty.awareness +=
          max(0, phenotype.getLength(day) - maxMinutesInDay) / 30;
    }

    for (final noFoodBlock
        in phenotype.getBlocksBetweenLargeMeal(ordered, events)) {
      if (noFoodBlock.isEmpty) continue;
      for (final energeticEvent in noFoodBlock.where((s) => s.isEnergetic)) {
        // Energetic events should be just after food.
        penalty.awareness += noFoodBlock.indexOf(energeticEvent) / 2;
      }
      penalty.hunger += max(0,
              phenotype.getLength(noFoodBlock) - maxMinutesWithoutLargeMeal) /
          20;
    }

    void penalizeSeekAvoid(Event a, Event b) {
      const denominator = 2;
      // Avoid according to tags.
      penalty.repetitiveness +=
          a.tags.where((tag) => b.avoid.contains(tag)).length / denominator;
      penalty.repetitiveness +=
          b.tags.where((tag) => a.avoid.contains(tag)).length / denominator;
      // Seek according to tags.
      penalty.harmony -=
          a.tags.where((tag) => b.seek.contains(tag)).length / denominator;
      penalty.harmony -=
          b.tags.where((tag) => a.seek.contains(tag)).length / denominator;
    }

    for (final block in phenotype.getBlocks(ordered, events)) {
      final blockLength = phenotype.getLength(block);
      // Avoid blocks that are too long.
      if (blockLength > maxMinutesWithoutBreak * 1.5) {
        // Block is way too long.
        penalty.awareness += blockLength - maxMinutesWithoutBreak;
      }
      penalty.awareness += max(0, blockLength - maxMinutesWithoutBreak) / 10;
      // Avoid blocks that are too short.
      penalty.cultural += max(0, minBlockLength - blockLength) / 10;
      for (final a in block) {
        for (final b in block) {
          if (a == b) continue;
          penalizeSeekAvoid(a, b);
        }
      }
    }

    for (final tuple in phenotype.getTuples(ordered, events)) {
      final a = tuple[0];
      final b = tuple[1];

      penalizeSeekAvoid(a, b);
    }

    // For two similar schedules, the one that needs less slots should win.
    penalty.awareness += phenotype.getLength(ordered) / 100;

    final baked = BakedSchedule(ordered);
    // Penalize when last day is longer than previous days.
    final lastDay = baked.days[baked.days.length];
    for (var i = 1; i < baked.days.length; i++) {
      final diff = (baked.days[i].duration - lastDay.duration).inMinutes;
      if (diff > 0) {
        penalty.cultural += diff / 10;
      }
    }

    // Lunch hour should start at a culturally appropriate time.
    for (final bakedDay in baked.days.values) {
      for (final baked in bakedDay.list) {
        if (!baked.event.isLunch) continue;
        final distance = _getDistanceFromLunchHour(baked.time);
        penalty.cultural += distance.inMinutes.abs() / 20;
      }
    }

    // Penalize "hairy" event times (13:45 instead of 14:00).
    for (final day in baked.days.values) {
      for (final event in day.list) {
        if (event.time.minute % 30 != 0) {
          penalty.cultural += 0.01;
        }
      }
    }

    final usedOrderIndexes = <int>{};
    for (final order in phenotype.genes) {
      if (usedOrderIndexes.contains(order)) {
        // One index used multiple times.
        penalty.dna += 0.1;
      }
      usedOrderIndexes.add(order);
    }

    for (final evaluator in _customEvaluators) {
      evaluator(baked, penalty);
    }

    return penalty;
  }

  static Duration _getDistanceFromLunchHour(DateTime time) {
    final lunchTimeMin =
        DateTime.utc(time.year, time.month, time.day, _lunchHourMin);
    final lunchTimeMax =
        DateTime.utc(time.year, time.month, time.day, _lunchHourMax);
    if (time.isAfter(lunchTimeMin) && time.isBefore(lunchTimeMax) ||
        time == lunchTimeMin ||
        time == lunchTimeMax) {
      // Inside range.
      return const Duration();
    }
    if (time.isBefore(lunchTimeMin)) {
      return lunchTimeMin.difference(time);
    }
    if (time.isAfter(lunchTimeMax)) {
      return lunchTimeMax.difference(time);
    }
    throw StateError('time has undefined relationship to lunchTimeMin'
        ' and lunchTimeMax');
  }
}

class ScheduleEvaluatorPenalty extends FitnessResult {
  /// Penalty for breaking expectations, like lunch at 12pm.
  double cultural = 0.0;

  /// Penalty for breaking constraints, like "end first day at 6pm".
  double constraints = 0.0;

  double hunger = 0.0;

  double repetitiveness = 0.0;

  /// Mostly bonus (negative values) for things like event of the same
  /// theme appearing after each other.
  double harmony = 0.0;

  /// Penalty for straining audience focus, like "not starting with exciting
  /// event after lunch".
  double awareness = 0.0;

  /// Penalty for ambivalence or other problems in the chromosome.
  double dna = 0.0;

  /// Used for debugging only.
  // ignore: unused_field
  double _cachedEvaluate;

  @override
  bool dominates(ScheduleEvaluatorPenalty other) {
    return cultural < other.cultural &&
        constraints < other.constraints &&
        hunger < other.hunger &&
        repetitiveness < other.repetitiveness &&
        harmony < other.harmony &&
        awareness < other.awareness &&
        dna < other.dna;
  }

  @override
  double evaluate() {
    var result = 0.0;
    result += cultural;
    result += constraints;
    result += hunger;
    result += repetitiveness;
    result += harmony;
    result += awareness;
    result += dna;
    _cachedEvaluate = result;
    return result;
  }
}

/// A function that takes a [schedule] and modifies the [penalty].
///
/// These are used for specific rules pertaining to only one conference but
/// not generally applicable, such as that a particular conference's first day
/// must end as close to 6pm as possible.
typedef CustomEvaluator = void Function(
    BakedSchedule schedule, ScheduleEvaluatorPenalty penalty);
