import 'package:kapstr/models/place.dart';
import 'package:kapstr/themes/constants.dart';

class PlacesService {
  Future<Place?> get({required String id, required String eventId}) async {
    try {
      var document = await configuration.getCollectionPath("events/$eventId/places").doc(id).get();
      if (document.exists) {
        return Place.fromMap(document.data()! as Map<String, dynamic>, id);
      } else {
        throw Exception("API - No place found for ID: $id");
      }
    } on Exception catch (e) {
      throw Exception("API - Error getting place: $e");
    }
  }

  Future<List<Place>> getAll({required String eventId}) async {
    try {
      var collection = await configuration.getCollectionPath("events/$eventId/places").get();
      return collection.docs.map((doc) => Place.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } on Exception catch (e) {
      throw Exception("API - Error getting places: $e");
    }
  }

  Future<Place> updatePlace({required Place place, required String eventId}) async {
    try {
      await configuration.getCollectionPath("events/$eventId/places").doc(place.id).update(place.toMap());
      return place;
    } on Exception catch (e) {
      throw Exception("API - Error updating Place: $e");
    }
  }

  Future<List<Place>> updateAllPlaces({required List<Place> places, required String eventId}) async {
    try {
      var collectionPath = configuration.getCollectionPath("events/$eventId/places");

      // Delete all existing documents in the collection
      var collection = await collectionPath.get();
      for (var doc in collection.docs) {
        await collectionPath.doc(doc.id).delete();
      }

      // Add new documents for each Place
      for (var place in places) {
        await collectionPath.doc(place.id).set(place.toMap());
      }

      return places;
    } on Exception catch (e) {
      throw Exception("API - Error updating all places: $e");
    }
  }
}
