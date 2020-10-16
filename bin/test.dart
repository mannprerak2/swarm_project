import 'package:engifest_scheduler/events.dart';

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
  print('length(min): ' +
      length.toString() +
      ', hours: ' +
      (length / 60).toString());
}
