import 'engifest_scheduler.dart';
import 'constants.dart';

final events = <Event>[
  Event('Let’s live code in Flutter', 30,
      tags: [flutter, energetic, demo, exciting, flutter_main],
      avoid: [demo],
      seek: []),
  Event('Flutter / Angular code sharing deep dive', 30, tags: [
    flutter,
    angulardart,
    platform,
    deepdive,
    after_flutter_main,
    after_angulardart_main,
    codeshare,
    after_apptree
  ], avoid: [
    deepdive,
    codeshare
  ], seek: []),
  Event('How to build good packages and plugins ', 30,
      tags: [platform], avoid: [], seek: []),
  Event('Keynote ', 45,
      tags: [keynote, platform, energetic, exciting, day1],
      avoid: [deepdive],
      seek: []),
  Event('Unconference ', 120, tags: [day_end, day2], avoid: [], seek: []),
  Event(
      'Faisal Abid: From Zero to One - Building a real world Flutter Application',
      30,
      tags: [
        flutter,
        architecture,
        third_party,
        after_flutter_main,
        after_angulardart_main
      ],
      avoid: [
        keynote
      ],
      seek: [
        flutter
      ]),
  Event('Making Dart fast on mobile', 30,
      tags: [platform, flutter, deepdive, flutter_fast, after_dart_main],
      avoid: [deepdive],
      seek: [flutter]),
  Event('AngularDart: architecting for size and speed ', 30, tags: [
    angulardart,
    architecture,
    deepdive,
    angulardart_main,
    after_dart_main
  ], avoid: [
    architecture,
    deepdive
  ], seek: []),
  Event('Brian Egan: Keep it Simple, State: Architecture for Flutter Apps', 30,
      tags: [
        flutter,
        architecture,
        third_party,
        deepdive,
        after_flutter_main,
        after_flutter_fast
      ],
      avoid: [
        architecture,
        third_party,
        deepdive
      ],
      seek: [
        flutter
      ]),
  Event('Dart language — what we’re working on right now ', 30,
      tags: [platform, exciting, day1, dart_main], avoid: [], seek: [platform]),
  Event('Effective Dart + IntelliJ ', 30,
      tags: [platform, tooling], avoid: [keynote], seek: []),
  Event('TrustWave: Power of AngularDart and Trustwave’s Customer Portal', 30,
      tags: [angulardart, third_party, after_angulardart_main],
      avoid: [keynote],
      seek: [angulardart]),
  Event('Flutter Inspector ', 30,
      tags: [flutter, tooling, exciting, after_flutter_main],
      avoid: [],
      seek: []),
  Event('Lightning talks ', 90, tags: [day_end, day1], avoid: [], seek: []),
  Event('Eugenio: Save/restore library', 30, tags: [
    flutter,
    architecture,
    deepdive,
    third_party,
    after_flutter_main,
    after_flutter_fast,
    after_dart_main
  ], avoid: [
    architecture,
    third_party,
    keynote
  ], seek: [
    flutter
  ]),
  Event('AppTree: Flutter & Web - Unite your code and your teams.', 30, tags: [
    flutter,
    architecture,
    codeshare,
    third_party,
    after_flutter_main,
    after_dart_main,
    apptree
  ], avoid: [
    architecture,
    third_party,
    keynote,
    codeshare
  ], seek: [
    flutter,
    platform
  ]),
];
