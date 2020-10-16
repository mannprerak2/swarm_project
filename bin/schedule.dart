import 'package:engifest_scheduler/engifest_scheduler.dart';
import 'package:engifest_scheduler/events.dart';

/// Number of members in a generation.
const generationMemberCount = 200;

/// Number of generations to breed.
const generationExperiments = 3000;
void main(List<String> args) async {
  // Init a Random first generation.
  final firstGeneration = Generation<Schedule, int, ScheduleEvaluatorPenalty>()
    ..members.addAll(
        List.generate(generationMemberCount, (_) => Schedule.random(events)));

  final evaluator = ScheduleEvaluator(events, [engifestEvaluator]);

  final breeder = GenerationBreeder<Schedule, int, ScheduleEvaluatorPenalty>(
      () => Schedule(events))
    ..fitnessSharingRadius = 0.6
    ..elitismCount = 1;

  // Create the algo object.
  final algo = GeneticAlgorithm<Schedule, int, ScheduleEvaluatorPenalty>(
      firstGeneration, evaluator, breeder,
      printf: (_) {}, statusf: (_) {
    if (args.contains('--verbose') || args.contains('-v')) {
      print(_);
    }
  })
    ..MAX_EXPERIMENTS = generationMemberCount * generationExperiments
    ..THRESHOLD_RESULT = ScheduleEvaluatorPenalty();

  // Set progress listener.
  algo.onGenerationEvaluated.listen((gen) {
    if (algo.currentGeneration == 0) return;
    if (algo.currentGeneration % 100 != 0) return;

    printResults(gen, events, algo.currentGeneration);
  });

  await algo.runUntilDone();

  // Print final results.
  printResults(algo.generations.last, events, algo.currentGeneration);
}

void engifestEvaluator(
    BakedSchedule schedule, ScheduleEvaluatorPenalty penalty) {
  for (final day in schedule.days.values) {
    /// Penalty for ending day after 6 pm.
    if (day.end.hour > 18 || day.end.hour < 12) {
      penalty.constraints += 50;
    }

    /// Penalty for ending day after 7 pm.
    if (day.end.hour > 19 || day.end.hour < 12) {
      penalty.constraints += 200;
    }
  }
}

void printResults(Generation<Schedule, int, ScheduleEvaluatorPenalty> gen,
    List<Event> events, int generationNumber) {
  final lastGeneration = List<Schedule>.from(gen.members);
  lastGeneration.sort();
  final specimen = lastGeneration[0];
  print('======= Generation#$generationNumber Winner ('
      'pareto rank ${specimen.result.paretoRank} '
      'fitness ${specimen.result.evaluate().toStringAsFixed(2)} '
      'shared ${specimen.resultWithFitnessSharingApplied.toStringAsFixed(2)} '
      ') ====');
  print('Genes (${specimen.genes.length}): ${specimen.genesAsString}');
  print(specimen.generateSchedule(events));
}
