import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/themes/constants.dart';

class TableService {
  Future<TableModel?> get({required String id, required String eventId}) async {
    try {
      var document = await configuration.getCollectionPath("events/$eventId/tables").doc(id).get();
      if (document.exists) {
        return TableModel.fromMap(document.data()! as Map<String, dynamic>, id);
      } else {
        throw Exception("API - No table found for ID: $id");
      }
    } on Exception catch (e) {
      throw Exception("API - Error getting table: $e");
    }
  }

  Future<List<TableModel>> getAll({required String eventId}) async {
    try {
      var collection = await configuration.getCollectionPath("events/$eventId/tables").get();
      return collection.docs.map((doc) => TableModel.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    } on Exception catch (e) {
      throw Exception("API - Error getting tables: $e");
    }
  }

  Future<TableModel> update({required TableModel table, required String eventId}) async {
    try {
      await configuration.getCollectionPath("events/$eventId/tables").doc(table.id).update(table.toMap());
      return table;
    } on Exception catch (e) {
      throw Exception("API - Error updating table: $e");
    }
  }

  Future<void> remove({required String id, required String eventId}) async {
    try {
      await configuration.getCollectionPath("events/$eventId/tables").doc(id).delete();
    } on Exception catch (e) {
      throw Exception("API - Error removing table: $e");
    }
  }

  Future<TableModel> create({required TableModel table, required String eventId}) async {
    try {
      var docRef = await configuration.getCollectionPath("events/$eventId/tables").add(table.toMap());
      return TableModel.fromMap(table.toMap(), docRef.id);
    } on Exception catch (e) {
      throw Exception("API - Error creating table: $e");
    }
  }

  Future<void> show({required Event event, required String eventId}) async {
    try {
      await configuration.getCollectionPath("events").doc(eventId).update(event.toMap());
    } on Exception catch (e) {
      throw Exception("API - Error updating table: $e");
    }
  }
}
