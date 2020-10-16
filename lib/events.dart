import 'engifest_scheduler.dart';
import 'constants.dart';

final events = <Event>[
  /// Event inauguration and ending.
  Event(
    'Inauguration - lighting the lamp',
    60,
    tags: [inauguration, day1],
    seek: [exciting],
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
    seek: [sponsor],
    avoid: [],
  ),
  Event(
    'Vibe - dance society DTU',
    45,
    tags: [dance],
    seek: [],
    avoid: [],
  ),
  Event(
    'Anusthaan - solo/duet dance',
    120,
    tags: [dance],
    seek: [],
    avoid: [],
  ),

  /// Standup Comedy events.
  Event(
    'Rahul Dua - standup comedy',
    60,
    tags: [comedy],
    seek: [sponsor],
    avoid: [],
  ),
  Event(
    'Anubhav Singh Bassi - Standup Comedy',
    90,
    tags: [comedy, day_end],
    seek: [sponsor],
    avoid: [],
  ),

  /// Sponsors events.
  Event(
    'Sponsors word - Resso App',
    30,
    tags: [sponsor],
    seek: [],
    avoid: [break_, sponsor],
  ),
  Event(
    'Sponsors Word - Pepsi Co.',
    30,
    tags: [sponsor],
    seek: [],
    avoid: [break_, sponsor],
  ),
  Event(
    'Sponsors Word - Ballebazi App',
    30,
    tags: [sponsor],
    seek: [],
    avoid: [break_, sponsor],
  ),
  Event(
    'Sponsors Word - Nestle',
    30,
    tags: [sponsor],
    seek: [],
    avoid: [break_, sponsor],
  ),

  /// Theatre and Acting.
  Event(
    'Nukkad Natak - live theatre',
    45,
    tags: [theatre],
    seek: [],
    avoid: [exciting],
  ),
  Event(
    'Pratibimb Natya - live theatre',
    45,
    tags: [theatre],
    seek: [],
    avoid: [exciting],
  ),

  /// Music Events.
  Event(
    'Music Fest - Rooh Band',
    120,
    tags: [music],
    seek: [],
    avoid: [music],
  ),
  Event(
    'Madhurima - music society DTU',
    45,
    tags: [music],
    seek: [music],
    avoid: [],
  ),
  Event(
    'Engi Idol - Indian solo singing',
    90,
    tags: [music],
    seek: [music],
    avoid: [],
  ),

  /// Misclelanous
  Event(
    'Interactive Talent show - live audience talent hunt',
    45,
    tags: [misc],
    seek: [],
    avoid: [],
  ),
  Event(
    'Youtube Fiesta - Meet the stars',
    45,
    tags: [misc],
    seek: [],
    avoid: [],
  ),
  Event(
    'TVF - cast meet and greet',
    60,
    tags: [misc],
    seek: [],
    avoid: [],
  ),
];
