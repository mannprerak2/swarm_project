import 'package:engifest_scheduler/engifest_scheduler.dart';
import 'package:engifest_scheduler/events.dart';

void main() async {
  // Init a Random first generation.
  final firstGeneration = Generation<Schedule, int, ScheduleEvaluatorPenalty>()
    ..members.addAll(List.generate(200, (_) => Schedule.random(events)));

  final evaluator = ScheduleEvaluator(events, [engifestEvaluators]);

  final breeder = GenerationBreeder<Schedule, int, ScheduleEvaluatorPenalty>(
      () => Schedule(events))
    ..fitnessSharingRadius = 0.5
    ..elitismCount = 1;

  // Create the algo object.
  final algo = GeneticAlgorithm<Schedule, int, ScheduleEvaluatorPenalty>(
      firstGeneration, evaluator, breeder,
      printf: (_) {})
    ..MAX_EXPERIMENTS = 100000
    ..THRESHOLD_RESULT = ScheduleEvaluatorPenalty();

  // Set progress listener.
  algo.onGenerationEvaluated.listen((gen) {
    if (algo.currentGeneration == 0) return;
    if (algo.currentGeneration % 100 != 0) return;

    printResults(gen, events);
  });

  await algo.runUntilDone();

  // Print final results.
  printResults(algo.generations.last, events);
}

void engifestEvaluators(
    BakedSchedule schedule, ScheduleEvaluatorPenalty penalty) {
  final firstDay = schedule.days[1];
  if (firstDay != null) {
    // Penalize for not ending first day at 6pm.
    final firstDayTargetEnd = DateTime.utc(
        firstDay.end.year, firstDay.end.month, firstDay.end.day, 18);
    penalty.constraints +=
        firstDay.end.difference(firstDayTargetEnd).inMinutes.abs() / 10;

    // Penalize for too much Flutter in the first block.
    final firstBlock = firstDay.list.takeWhile((s) => !s.event.isBreak);
    if (firstBlock.every((s) => s.event.tags.contains('flutter'))) {
      penalty.repetitiveness += 0.5;
    }
  }
}

void printResults(Generation<Schedule, int, ScheduleEvaluatorPenalty> gen,
    List<Event> events) {
  final lastGeneration = List<Schedule>.from(gen.members);
  lastGeneration.sort();
  for (var i = 0; i < lastGeneration.length; i++) {
    final specimen = lastGeneration[i];
    print('======= Winner $i ('
        'pareto rank ${specimen.result.paretoRank} '
        'fitness ${specimen.result.evaluate().toStringAsFixed(2)} '
        'shared ${specimen.resultWithFitnessSharingApplied.toStringAsFixed(2)} '
        ') ====');
    print('${specimen.genesAsString}');
    print(specimen.generateSchedule(events));
  }
}
