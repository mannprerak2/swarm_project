import 'package:engifest_scheduler/events.dart';

/// Simple program to count the time duration of all events combined.
void main() {
  var count = 0;
  var length = 0;
  for (final e in events) {
    if (e.length != null) {
      count++;
      length += e.length;
    }
  }

  print('Count: ' + count.toString());
  print('length: ' +
      length.toString() +
      ' min (' +
      (length / 60).toString() +
      ' hr)');
}
