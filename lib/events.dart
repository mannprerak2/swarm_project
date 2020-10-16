import 'engifest_scheduler.dart';
import 'constants.dart';

final events = <Event>[
  /// Event inauguration and ending.
  Event(
    'Inauguration - lighting the lamp',
    60,
    tags: [inauguration, day1],
    seek: [],
    avoid: [],
  ),
  Event(
    'Wrap Up - Concluding the fest',
    30,
    tags: [day3, day_end],
    seek: [],
    avoid: [],
  ),

  /// Dance events.
  Event(
    'Spandan - group dance',
    180,
    tags: [dance, exciting],
    seek: [],
    avoid: [dance],
  ),
  Event(
    'Anusthaan - solo/duet dance',
    120,
    tags: [dance],
    seek: [],
    avoid: [dance],
  ),
  Event(
    'Vibe - dance society DTU',
    45,
    tags: [],
    seek: [],
    avoid: [],
  ),

  /// Standup Comedy events.
  Event(
    'Rahul Dua - standup comedy',
    60,
    tags: [comedy, day_end],
    seek: [],
    avoid: [],
  ),
  Event(
    'Anubhav Singh Bassi - Standup Comedy',
    90,
    tags: [comedy, day_end],
    seek: [],
    avoid: [],
  ),

  /// Sponsors events.
  Event(
    'Sponsors word - Resso App',
    30,
    tags: [sponsor],
    seek: [exciting],
    avoid: [break_, sponsor],
  ),
  Event(
    'Sponsors Word - Pepsi Co.',
    30,
    tags: [sponsor],
    seek: [exciting],
    avoid: [break_, sponsor],
  ),
  Event(
    'Sponsors Word - Ballebazi App',
    30,
    tags: [sponsor],
    seek: [exciting],
    avoid: [break_, sponsor],
  ),
  Event(
    'Sponsors Word - Nestle',
    30,
    tags: [sponsor],
    seek: [exciting],
    avoid: [break_, sponsor],
  ),

  /// Theatre and Acting.
  Event(
    'Nukkad Natak - live theatre',
    45,
    tags: [theatre],
    seek: [break_],
    avoid: [],
  ),
  Event(
    'Nukkad Natak - live theatre',
    45,
    tags: [theatre],
    seek: [break_],
    avoid: [],
  ),

  /// Music Events.
  Event(
    'Music Fest - Rooh Band',
    120,
    tags: [music, exciting],
    seek: [],
    avoid: [music, break_],
  ),
  Event(
    'Madhurima - music society DTU',
    45,
    tags: [music, exciting],
    seek: [music],
    avoid: [break_],
  ),
  Event(
    'Engi Idol - Indian solo singing',
    120,
    tags: [],
    seek: [music, break_],
    avoid: [],
  ),

  /// Misclelanous
  Event(
    'Interactive Talent show - live audience talent hunt',
    60,
    tags: [misc],
    seek: [break_],
    avoid: [],
  ),
  Event(
    'Youtube Fiesta - Meet the stars',
    60,
    tags: [misc],
    seek: [break_],
    avoid: [],
  ),
  Event(
    'TVF - cast meet and greet',
    60,
    tags: [misc],
    seek: [break_],
    avoid: [],
  ),
];
