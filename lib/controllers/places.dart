import 'package:flutter/material.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/place.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/services/api/api.dart';
import 'package:provider/provider.dart';

class PlacesController extends ChangeNotifier {
  bool isLoading = false;
  TableModel? table;
  List<Place> places = [];
  String searchQuery = "";

  void clear() {
    isLoading = false;
    table = null;
    places = [];
    searchQuery = "";
  }

  void setIsLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> refreshPlaces(BuildContext context) async {
    try {
      places = [];
      isLoading = true;
      notifyListeners();
      String moduleId = await context.read<RSVPController>().getRSVPMainEvent(context);
      List<RSVP> rsvps = await Api().rsvps.getMainEventRsvps(eventId: Event.instance.id, moduleId: moduleId);
      List<Place> savedPlaces = await Api().places.getAll(eventId: Event.instance.id);
      List<AddedGuest> addeds = getAllAddedsFromRsvps(rsvps);
      List<String> placesIds = getIdsFromPlaces(savedPlaces);

      for (AddedGuest added in addeds) {
        if (!placesIds.contains(added.id)) {
          places.add(Place(id: added.id, tableId: "", guestId: added.id, guestName: added.name));
        } else {
          Place toAdd = savedPlaces.firstWhere((place) => place.id == added.id);
          toAdd.guestName = added.name;

          places.add(toAdd);
        }
      }
      await Api().places.updateAllPlaces(places: places, eventId: Event.instance.id);
    } catch (e) {
      debugPrint("Erreur lors de la récupération des tables : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Récuperation de toutes les places d'un Event via API
  Future getPlaces() async {
    try {
      isLoading = true;
      notifyListeners();
      places = await Api().places.getAll(eventId: Event.instance.id);
    } catch (e) {
      debugPrint("Erreur lors de la récupération des places : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future updatePlaces() async {
    try {
      isLoading = true;
      notifyListeners();
      places = await Api().places.updateAllPlaces(places: places, eventId: Event.instance.id);
    } catch (e) {
      debugPrint("Erreur lors de la récupération des places : $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Récuperation de toutes les places d'un Event via API
  Future<List<Place>> getFilteredPlacesByTable(List<Place> places) async {
    List<Place> filteredPlaces = places.where((e) => e.tableId == table!.id) as List<Place>;
    return filteredPlaces;
  }

  Future updatePlace(Place place) async {
    try {
      isLoading = true;
      notifyListeners();
      places.removeWhere((removed) => removed.id == place.id);
      places.add(place);
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour de la place: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
