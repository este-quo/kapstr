import 'package:kapstr/services/api/data/added.dart';
import 'package:kapstr/services/api/data/places.dart';
import 'package:kapstr/services/api/data/rsvps.dart';
import 'package:kapstr/services/api/data/tables.dart';

class Api {
  static final Api _instance = Api._internal();

  factory Api() {
    return _instance;
  }

  final String version = "2.2.0";

  // Services
  final TableService tables = TableService();
  final AddedService addeds = AddedService();
  final PlacesService places = PlacesService();
  final RsvpsService rsvps = RsvpsService();

  Api._internal();
}
