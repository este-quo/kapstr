import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/modules/modules.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/place.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/models/table.dart';
import 'package:kapstr/services/api/api.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class RSVPController extends ChangeNotifier {
  List<RSVP> _rsvps = [];

  List<RSVP> get rsvps => _rsvps;

  void setRsvps(List<RSVP> rsvps) {
    _rsvps = rsvps;
    notifyListeners();
  }

  void updateRsvp(RSVP updatedRsvp) {
    int index = _rsvps.indexWhere((rsvp) => rsvp.moduleId == updatedRsvp.moduleId);
    if (index != -1) {
      _rsvps[index] = updatedRsvp;
      notifyListeners();
    }
  }

  RSVPController() {
    for (var rsvp in rsvps) {
      if (!rsvp.isAnswered) isAllAnswered = false;
    }
  }

  void clear() {
    _rsvps = [];
  }

  bool _isAllAnswered = true;

  bool get isAllAnswered => _isAllAnswered;

  set isAllAnswered(bool value) {
    _isAllAnswered = value;
    notifyListeners();
  }

  CollectionReference get _rsvpCollection => configuration.getCollectionPath('events').doc(Event.instance.id).collection('rsvps');

  Future<bool> checkIfRsvpExists(String guestId, String moduleId) async {
    try {
      QuerySnapshot querySnapshot =
          await _rsvpCollection
              .where('guest_id', isEqualTo: guestId)
              .where('module_id', isEqualTo: moduleId)
              .limit(1) // Limite pour optimiser les performances
              .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // Ajouter un nouveau RSVP
  Future<void> addRSVP(RSVP rsvp) async {
    await _rsvpCollection.add(rsvp.toMap());
  }

  // Obtenir un RSVP par ID
  Future<RSVP?> getRSVP(String rsvpId) async {
    DocumentSnapshot doc = await _rsvpCollection.doc(rsvpId).get();
    if (doc.exists) {
      return RSVP.fromMap(doc.data()! as Map<String, dynamic>, rsvpId);
    }
    return null;
  }

  RSVP? getRsvpByIds(String guestId, String moduleId) {
    try {
      return rsvps.firstWhere((rsvp) => rsvp.guestId == guestId && rsvp.moduleId == moduleId);
    } catch (e) {
      // Si une autre erreur survient, la journaliser et retourner null

      return null;
    }
  }

  // Mettre à jour un RSVP
  Future<void> updateRSVP(String? rsvpId, RSVP updatedRSVP) async {
    await _rsvpCollection.doc(rsvpId).update(updatedRSVP.toMap());
  }

  Future<void> cancelRSVP(String? rsvpId, RSVP updatedRSVP) async {
    await _rsvpCollection.doc(rsvpId).update(updatedRSVP.toMap());
  }

  // Supprimer un RSVP
  Future<void> deleteRSVP(String? rsvpId) async {
    await _rsvpCollection.doc(rsvpId).delete();
  }

  // Obtenir tous les RSVPs
  Future<List<RSVP>> getRSVPs() async {
    QuerySnapshot querySnapshot = await _rsvpCollection.get();
    return querySnapshot.docs.map((doc) => RSVP.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
  }

  Future<void> fetchAllRsvps() async {
    QuerySnapshot querySnapshot = await _rsvpCollection.get();
    List<RSVP> rsvps = querySnapshot.docs.map((doc) => RSVP.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    setRsvps(rsvps);
  }

  Future<void> fetchRsvps(String guestId, List<String> allowedModules) async {
    try {
      // Rafraîchir la liste complète des RSVPs
      QuerySnapshot updatedQuerySnapshot = await _rsvpCollection.where('guest_id', isEqualTo: guestId).where('module_id', whereIn: allowedModules).get();

      List<RSVP> updatedRsvps = updatedQuerySnapshot.docs.map((doc) => RSVP.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();

      setRsvps(updatedRsvps);
    } catch (e) {
      printOnDebug(e.toString());
    }
  }

  Future<void> createMissingRsvps(String guestId, List<String> allowedModules) async {
    try {
      // Obtenez les RSVPs existants pour cet invité
      QuerySnapshot existingRsvpSnapshot = await _rsvpCollection.where('guest_id', isEqualTo: guestId).get();
      List<String> existingModuleIds = existingRsvpSnapshot.docs.map((doc) => (doc.data()! as Map<String, dynamic>)['module_id'] as String).toList();

      // Filtrer les modules pour lesquels aucun RSVP n'existe encore
      List<String> missingModuleIds = allowedModules.where((moduleId) => !existingModuleIds.contains(moduleId)).toList();

      // Créez un RSVP pour chaque module manquant
      for (String moduleId in missingModuleIds) {
        final newRsvp = RSVP(guestId: guestId, moduleId: moduleId, isAllowed: true, response: 'En attente', adults: [], children: [], createdAt: DateTime.now(), isAnswered: false);

        await _rsvpCollection.add(newRsvp.toMap());
      }
    } catch (e) {
      printOnDebug(e.toString());
    }
  }

  // Obtenir tous les RSVPs d'un invité
  Future<List<RSVP>> getRSVPsByGuestId(String guestId, List<String> allowedModules) async {
    QuerySnapshot querySnapshot = await _rsvpCollection.where('guest_id', isEqualTo: guestId).where('module_id', whereIn: allowedModules).get();
    if (querySnapshot.docs.isEmpty) {
      return [];
    } else {
      return querySnapshot.docs.map((doc) => RSVP.fromMap(doc.data()! as Map<String, dynamic>, doc.id)).toList();
    }
  }

  // Obtenir tous les RSVPs d'un module
  Future<List<RSVP>> getRSVPsByModuleId(String moduleId) async {
    List<RSVP> filteredRSVPs = [];

    for (Guest guest in Event.instance.guests) {
      for (String guestModuleId in guest.allowedModules) {
        if (guestModuleId == moduleId) {
          List<RSVP>? rsvps = await getRSVPsByGuestId(guest.id, [moduleId]);
          filteredRSVPs.addAll(rsvps);
        }
      }
    }

    return filteredRSVPs;
  }

  //Accept RSVP
  Future<void> acceptRSVP(String? rsvpId, List<AddedGuest> children, List<AddedGuest> adults, BuildContext context) async {
    await _rsvpCollection.doc(rsvpId).update({'response': 'Accepté', 'children': children, 'adults': adults, 'is_answered': true});

    await checkRSVPs(context);
  }

  //Refuse RSVP
  Future<void> refuseRSVP(String? rsvpId, BuildContext context) async {
    await _rsvpCollection.doc(rsvpId).update({'response': 'Absent', 'children': [], 'adults': [], 'is_answered': true});

    await checkRSVPs(context);
  }

  Future<void> changePermissionRSVP(String? rsvpId, bool isAllowed) async {
    await _rsvpCollection.doc(rsvpId).update({'is_allowed': isAllowed});
  }

  Future<void> checkRSVPs(BuildContext context) async {
    // Fetch RSVPs for the guest

    List<RSVP> rsvps = await getRSVPsByGuestId(AppGuest.instance.id, AppGuest.instance.allowedModules);
    // Get current date without time for comparison
    DateTime today = DateTime.now();
    DateTime todayDate = DateTime(today.year, today.month, today.day);

    // Filter out RSVPs whose modules have already occurred
    List<RSVP> upcomingRsvps =
        rsvps.where((RSVP rsvp) {
          // Get the module associated with the RSVP
          Module module = context.read<ModulesController>().getModuleById(rsvp.moduleId);
          // Check if the module date is after today
          return module.date!.isAfter(todayDate);
        }).toList();

    // Now check if there are any pending responses among the filtered RSVPs
    await context.read<RSVPController>().checkIfNeedAnswer(upcomingRsvps);
  }

  Future<void> checkIfNeedAnswer(List<RSVP> rsvps) async {
    bool allAnswered = !rsvps.any((RSVP rsvp) => rsvp.response == 'En attente');

    if (isAllAnswered != allAnswered) {
      isAllAnswered = allAnswered;
    }
  }

  Future<void> createMissingRsvp(String guestId, String moduleId) async {
    try {
      final newRsvp = RSVP(guestId: guestId, moduleId: moduleId, isAllowed: true, response: 'En attente', adults: [], children: [], createdAt: DateTime.now(), isAnswered: false);

      await _rsvpCollection.add(newRsvp.toMap());
    } catch (e) {
      printOnDebug(e.toString());
    }
  }

  Future<List<Map<String, TableModel>>> getAllAdultsForMainEvent(String eventId, String guestId, BuildContext context) async {
    List<Module> modules = await context.read<ModulesController>().getModules(eventId);
    Module module = modules.firstWhere((element) => element.type == "wedding");

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).collection('rsvps').where("guest_id", isEqualTo: guestId).get();
      List<RSVP> rsvps = querySnapshot.docs.map((doc) => RSVP.fromMap(doc.data(), doc.id)).toList();

      List<Map<String, TableModel>> tables = [];
      for (RSVP rsvp in rsvps) {
        if (rsvp.moduleId == module.id) {
          for (AddedGuest adult in rsvp.adults) {
            Place? place = await Api().places.get(id: adult.id, eventId: eventId);
            TableModel? table = await Api().tables.get(id: place!.tableId, eventId: eventId);
            if (table != null) {
              tables.add({adult.name: table});
            }
          }
        }
      }

      return tables;
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, TableModel>>> getAllChildrenForMainEvent(String eventId, String guestId, BuildContext context) async {
    List<Module> modules = await context.read<ModulesController>().getModules(eventId);
    Module module = modules.firstWhere((element) => element.type == "wedding");

    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).collection('rsvps').where("guest_id", isEqualTo: guestId).get();
      List<RSVP> rsvps = querySnapshot.docs.map((doc) => RSVP.fromMap(doc.data(), doc.id)).toList();

      List<Map<String, TableModel>> tables = [];
      for (RSVP rsvp in rsvps) {
        if (rsvp.moduleId == module.id) {
          for (AddedGuest child in rsvp.children) {
            Place? place = await Api().places.get(id: child.id, eventId: eventId);
            TableModel? table = await Api().tables.get(id: place!.tableId, eventId: eventId);
            if (table != null) {
              tables.add({child.name: table});
            }
          }
        }
      }

      return tables;
    } catch (e) {
      return [];
    }
  }

  Future<String> getRSVPMainEvent(BuildContext context) async {
    List<Module> modules = await context.read<ModulesController>().getModules(Event.instance.id);
    Module module = modules.firstWhere((element) => element.type == "wedding");
    printOnDebug("Evenement principal : ");
    printOnDebug(module.id);
    return module.id;
  }
}
