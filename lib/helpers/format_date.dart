import 'package:intl/intl.dart';

int daysBetween(DateTime date) {
  var from = DateTime.now();
  var to = date;
  var diff = (to.difference(from).inHours / 24).round();
  return diff;
}

String minutesBetween(DateTime date) {
  var from = DateTime.now();
  var to = date;
  var diff = (to.difference(from).inMinutes % 60).round();

  return diff.toString();
}

String hoursBetween(DateTime date) {
  var from = DateTime.now();
  var to = date;
  var diff = (to.difference(from).inHours % 24).round();

  return diff.toString();
}

String formatDate(String dateStr) {
  DateTime parsedDate = DateTime.parse(dateStr);
  String monthName = DateFormat('MMMM', 'fr_FR').format(parsedDate);
  return "${parsedDate.day.toString().padLeft(2, '0')} $monthName ${parsedDate.year}";
}
