import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/services/api/api.dart';

class TablesController extends ChangeNotifier {
  List<TableModel> tables = [];
  bool isLoading = false;

  /// Récuperation de toutes les tables via API
  Future getTables() async {
    try {
      isLoading = true;
      notifyListeners();
      tables = await Api().tables.getAll(eventId: Event.instance.id);
    } catch (e) {
      debugPrint("Erreur lors de la récupération des tables : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Suppression d'une table via API
  Future<void> removeTable(String id) async {
    try {
      isLoading = true;
      notifyListeners();
      await Api().tables.remove(id: id, eventId: Event.instance.id);
      tables.removeWhere((table) => table.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la suppression de la table : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Mise à jour d'une table via l'API
  Future<void> updateTable(TableModel table) async {
    try {
      isLoading = true;
      notifyListeners();
      final updatedTable = await Api().tables.update(table: table, eventId: Event.instance.id);
      tables.removeWhere((table) => table.id == updatedTable.id);
      tables.add(updatedTable);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour de la table : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Ajout d'une table via l'API
  Future<void> createTable(TableModel table) async {
    try {
      isLoading = true;
      notifyListeners();
      final createdTable = await Api().tables.create(table: table, eventId: Event.instance.id);
      tables.add(createdTable);
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la création de la table : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateShowTablesEarly(bool value) async {
    try {
      isLoading = true;
      notifyListeners();
      Event.instance.showTablesEarly = value;
      await Api().tables.show(event: Event.instance, eventId: Event.instance.id);
    } catch (e) {
      debugPrint("Erreur lors du changement de ShowTablesEarly : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
