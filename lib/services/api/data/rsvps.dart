import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/themes/constants.dart';

class RsvpsService {
  Future<List<RSVP>> getAll({required String eventId}) async {
    try {
      var collection = await configuration.getCollectionPath("events/$eventId/rsvps").get();
      return collection.docs.map((doc) => RSVP.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } on Exception catch (e) {
      throw Exception("API - Error getting rsvps: $e");
    }
  }

  Future<List<RSVP>> getMainEventRsvps({required String eventId, required String moduleId}) async {
    try {
      var collection = await configuration.getCollectionPath("events/$eventId/rsvps").where('module_id', isEqualTo: moduleId).get();
      return collection.docs.map((doc) => RSVP.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } on Exception catch (e) {
      throw Exception("API - Error getting rsvps: $e");
    }
  }
}
