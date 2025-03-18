import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/format_phone_number.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/modules/table.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/models/user.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/models/guest.dart';
import 'package:provider/provider.dart';

class GuestsController extends ChangeNotifier {
  Event _event;

  GuestsController(Event event) : _event = event;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  set isLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  List<Guest> get eventGuests => _event.guests;
  List<Guest> get selectedGuests {
    List<Guest> selectedGuests = [];
    for (var guest in _event.guests) {
      if (guest.isSelected) {
        selectedGuests.add(guest);
      }
    }
    return selectedGuests;
  }

  bool areAllSelected(List<Guest> guests) {
    for (var guest in _event.guests) {
      if (!guest.isSelected) {
        return false;
      }
    }
    return true;
  }

  Future<UniqueTable?> getGuestTable(String guestId) async {
    final guest = _event.guests.firstWhere((element) => element.id == guestId);
    if (guest.tableId.isEmpty) {
      return null;
    }

    String tableId = guest.tableId;
    return await configuration.getCollectionPath('events').doc(Event.instance.id).collection('tables').doc(tableId).get().then((value) => UniqueTable.fromMap(tableId, value.data() as Map<String, dynamic>));
  }

  Future<void> addGuestsToEvent(List<Guest> guests, BuildContext context) async {
    Set<String> existingPhones = eventGuests.map((g) => g.phone).toSet();
    List<Guest> newGuests = guests.where((guest) => !existingPhones.contains(guest.phone)).toList();

    List<Module> modules = Event.instance.modules;

    List<String> excludedModules = kNonEventModules;

    List<Future<void>> tasks = [];

    for (Guest guest in newGuests) {
      guest.allowedModules = []; // Initialize allowedModules for the guest
      for (Module module in modules) {
        await context.read<GuestsController>().allowModule(guest.id, module.id);
        guest.allowedModules.add(module.id); // Add module to the guest's allowedModules
      }
    }

    for (Guest guest in newGuests) {
      printOnDebug('guest : ${guest.name}');

      await createRsvpsForGuest(guest.id, guest.name, context);
    }

    try {
      await Future.wait(tasks);
    } catch (e) {
      printOnDebug("Error adding RSVPs: $e");
    }

    _event.guests.addAll(newGuests); // Ensure the event's guests list is updated
    notifyListeners();

    _isLoading = false;
    notifyListeners();
  }

  //Update guest
  Future<void> updateGuest(Map<String, dynamic> updatedValues, String guestID) async {
    Guest guest = eventGuests.firstWhere((element) => element.id == guestID);
    guest.update(updatedValues);

    notifyListeners();
  }

  void selectAllGuest() {
    for (var guest in eventGuests) {
      guest.isSelected = true;
    }
    notifyListeners();
  }

  void unselectAllGuest() {
    for (var guest in eventGuests) {
      guest.isSelected = false;
    }
    notifyListeners();
  }

  void toggleGuest(String guestID) {
    Guest guest = eventGuests.firstWhere((element) => element.id == guestID);
    guest.isSelected = !guest.isSelected;
    notifyListeners();
  }

  bool hasAtLeastOneSelected() {
    for (var guest in eventGuests) {
      if (guest.isSelected) {
        return true;
      }
    }
    return false;
  }

  Future<void> createGuestFromUser(User user, String eventId) async {
    _isLoading = true;
    notifyListeners();

    List<String> allowedModules = [];

    var eventModulesIds = await configuration.getCollectionPath('events').doc(eventId).collection('modules').get();

    for (var module in eventModulesIds.docs) {
      allowedModules.add(module.id);
    }

    var firestore = FirebaseFirestore.instance;

    var allGuestsSnapshot = await configuration.getCollectionPath('events').doc(eventId).collection('guests').get();

    var existingPhones =
        allGuestsSnapshot.docs.map((doc) {
          var data = doc.data();
          var guest = Guest.fromMap(data, doc.id);
          return guest.phone;
        }).toSet();

    int counter = 0;
    var batch = firestore.batch();

    try {
      String? phone = user.phone;

      String? formattedPhone = await formatPhoneNumber(phone!);

      if (!existingPhones.contains(formattedPhone)) {
        var guestDocRef = configuration.getCollectionPath('events').doc(eventId).collection('guests').doc();
        batch.set(guestDocRef, {
          'user_id': user.id,
          'name': user.name,
          'phone': formattedPhone,
          'posted_pictures': [],
          'table_id': '',
          'image_url': user.imageUrl,
          'children': [],
          'adults': [
            {'name': user.name},
          ],
          'has_joined': false,
          'event_id': eventId,
          'allowed_modules': allowedModules,
        });
      } else {
        var guestDocRef = allGuestsSnapshot.docs.firstWhere((doc) => (doc.data())['phone'] == formattedPhone).reference;

        batch.update(guestDocRef, {'name': user.name});
      }

      counter++;

      // Commit every 500 operations and start a new batch
      if (counter % 500 == 0) {
        await batch.commit();
        batch = firestore.batch();
      }
    } catch (e) {
      throw Exception(e);
    }

    if (counter % 500 != 0) {
      await batch.commit(); // Commit any remaining operations in the batch
    }
  }

  Future<void> createGuest(List<Contact> newGuests, List<String> allowedModules) async {
    _isLoading = true;
    notifyListeners();

    var firestore = FirebaseFirestore.instance;

    // Step 1: Fetch existing phone numbers in one go
    var allGuestsSnapshot = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').get();

    var existingPhones =
        allGuestsSnapshot.docs.map((doc) {
          var data = doc.data();
          var guest = Guest.fromMap(data, doc.id);
          return guest.phone;
        }).toSet();

    // Step 2: Prepare the batches
    int counter = 0;
    var batch = firestore.batch();

    for (var guest in newGuests) {
      try {
        String? phone = guest.phones!.first.value;

        String? formattedPhone = await formatPhoneNumber(phone!);

        // Check against local collection
        if (!existingPhones.contains(formattedPhone)) {
          var guestDocRef = configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc();
          batch.set(guestDocRef, {'user_id': '', 'name': guest.displayName, 'phone': formattedPhone, 'posted_pictures': [], 'table_id': '', 'image_url': '', 'children': 0, 'adults': 1, 'has_joined': false, 'event_id': Event.instance.id, 'allowed_modules': allowedModules});
        } else {
          var guestDocRef = allGuestsSnapshot.docs.firstWhere((doc) => (doc.data())['phone'] == formattedPhone).reference;

          batch.update(guestDocRef, {'name': guest.displayName});
        }

        counter++;

        // Commit every 500 operations and start a new batch
        if (counter % 500 == 0) {
          await batch.commit();
          batch = firestore.batch();
        }
      } catch (e) {
        throw Exception(e);
      }
    }

    if (counter % 500 != 0) {
      await batch.commit(); // Commit any remaining operations in the batch
    }
  }

  Future<void> setGuest(String eventId, String phone) async {
    QuerySnapshot currentUser = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();

    // get User id
    String userId = currentUser.docs.first.id;

    await configuration
        .getCollectionPath('events')
        .doc(eventId)
        .collection('guests')
        .where('event_id', isEqualTo: eventId)
        .where('phone', isEqualTo: phone)
        .get()
        .then(
          (value) => value.docs.forEach((element) {
            element.reference.update({'user_id': userId, 'has_joined': true});
          }),
        );
  }

  Future<List<Guest>> getGuests(String eventId) async {
    try {
      // Fetch guests for the event
      var guestDocs = await configuration.getCollectionPath('events').doc(eventId).collection('guests').get();

      // Initialize an empty list of guests
      List<Guest> guests = [];

      // Iterate through each guest document
      for (var doc in guestDocs.docs) {
        var guestData = doc.data();
        var guest = Guest.fromMap(guestData, doc.id);

        // Check if the guest has joined
        if (guestData['has_joined'] == true) {
          // Fetch user details using the user_id from the guest data
          var userData = await getUserDetails(guestData['user_id']);
          if (userData != null) {
            // Update the guest object with user details if needed
            guest.name = userData.name;
            guest.imageUrl = userData.imageUrl;
            guest.phone = userData.phone;
          }
        }

        // Add the guest to the list
        guests.add(guest);
      }

      return guests;
    } catch (e) {
      // Handle the error appropriately here
      printOnDebug('Error fetching guests: $e');
      return []; // Return an empty list or handle the error in another way
    }
  }

  Future<User?> getUserDetails(String userId) async {
    try {
      // Fetch user details by user_id
      var userDoc = await configuration.getCollectionPath('users').doc(userId).get();

      if (userDoc.exists) {
        // Convert the user document to a User object and return it
        return User.fromMap(userDoc.data() as Map<String, dynamic>, userDoc.id);
      }

      // Return null if the user document does not exist
      return null;
    } catch (e) {
      // Handle the error appropriately here
      printOnDebug('Error fetching user details for userId $userId: $e');
      return null; // Return null or handle the error in another way
    }
  }

  Future<void> deleteGuest(String guestId) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guestId).delete();
    } catch (e) {
      throw Exception(e);
    }

    eventGuests.removeWhere((element) => element.id == guestId);
    notifyListeners();
  }

  Future<QuerySnapshot?> currentGuest(String eventId, String phone) async {
    try {
      return await configuration.getCollectionPath('events').doc(eventId).collection('guests').where('event_id', isEqualTo: eventId).where('phone', isEqualTo: phone).get();
    } catch (e) {
      // Handle the error appropriately here
      printOnDebug('Error fetching current guest: $e');
      return null; // or rethrow the exception, or return an empty QuerySnapshot
    }
  }

  Future<Map<String, dynamic>> getGlobalGuestById(String id, String eventId) async {
    var guest = await configuration.getCollectionPath('events').doc(eventId).collection('globalGuests').doc(id).get();
    return guest.data()!;
  }

  Future<void> updateGlobalGuestInfos({required String guestId, required String guestName, required String guestPhone, required String newGuestPhone, required List<String> allowedModules}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guestId).update({'name': guestName, 'phone': newGuestPhone, 'allowed_modules': allowedModules});
    } catch (e) {
      throw Exception(e);
    }
  }

  // Future<void> addModuletoAllGuests({required String moduleId}) async {
  //   try {
  //     var guestsSnapshot = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').get();

  //     // Check if there are no guests
  //     if (guestsSnapshot.docs.isEmpty) {
  //       printOnDebug('No guests found for the event');
  //       return;
  //     }

  //     for (var guest in guestsSnapshot.docs) {
  //       var currentAllowedModules = guest.data()['allowed_modules'] as Map<String, dynamic>;

  //       // Check if the module doesn't exist
  //       if (!currentAllowedModules.containsKey(moduleId)) {
  //         currentAllowedModules[moduleId] = "En attente";
  //         await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guest.id).update({
  //           'allowed_modules': currentAllowedModules,
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     printOnDebug('Error updating module permissions: $e');
  //     throw Exception(e);
  //   }
  // }

  Future<void> updateGlobalGuestInfosAsAGuest({required String guestId, required Map<String, dynamic> allowedModules}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('globalGuests').doc(guestId).update({'allowed_modules': allowedModules});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getGlobalGuestByPhone(String guestPhone) {
    return configuration.getCollectionPath('events').doc(Event.instance.id).collection('globalGuests').where("phone", isEqualTo: guestPhone).get();
  }

  Future<void> updateGlobalGuestModules({required String guestPhone, required String moduleId}) async {
    try {
      var guest = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('globalGuests').where("phone", isEqualTo: guestPhone).get();
      var currentAllowedModules = guest.docs.first.data()['allowed_modules'];
      var newModule = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(moduleId).get();
      currentAllowedModules[newModule["name"]] = "En attente";
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('globalGuests').doc(guest.docs.first.id).update({'allowed_modules': currentAllowedModules});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateGlobalGuestPresence(String moduleId, String guestId, Map<String, dynamic> allowedModules) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('globalGuests').doc(guestId).update({'allowed_modules': allowedModules});
    } catch (e) {
      throw Exception(e);
    }
  }

  //get all global guest and return a List of them
  Future<Guest> getCurrentGuest(String eventId) {
    //get guest from a module document
    return configuration.getCollectionPath('events').doc(eventId).collection('globalGuests').doc(AppOrganizer.instance.id).get().then((value) => Guest.fromMap(value.data() as Map<String, dynamic>, value.id));
  }

  Future<void> addTableToGuests(String guestId, String tableId) async {
    await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guestId).update({'table_id': tableId});
  }

  Future<void> removeTableFromGuests(String guestId) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guestId).update({'table_id': ''});
    } catch (e) {
      printOnDebug('Failed to remove table from guest: $e');
      throw Exception('Failed to remove table from guest: $e');
    }
  }

  Future<void> allowModule(String guestId, String moduleId) async {
    print("Allow Module :");
    print(Event.instance.id);
    print(moduleId);
    print(guestId);
    try {
      // Vérifier si Event.instance est null
      if (Event.instance.id == null) {
        throw Exception('L\'ID de l\'événement est null.');
      }

      // Vérifier si guestId ou moduleId est null
      if (guestId.isEmpty || moduleId.isEmpty) {
        throw Exception('guestId ou moduleId ne peut pas être vide.');
      }

      print("2");

      // Ajouter le module dans Firestore
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guestId).update({
        'allowed_modules': FieldValue.arrayUnion([moduleId]),
      });

      print("3");

      // Vérifier si le guest existe dans la liste en mémoire
      final Guest? guest = _event.guests.firstWhere((element) => element.id == guestId);

      print("Guest:");

      print(guest);

      if (guest != null) {
        guest.allowedModules.add(moduleId);
        notifyListeners();
      } else {
        throw Exception('Guest non trouvé en mémoire avec l\'ID: $guestId');
      }
    } catch (e) {
      print('Erreur dans allowModule: $e');
    }
  }

  Future<void> disallowModule(String guestId, String moduleId) async {
    try {
      // Remove the module id from the allowed_modules list of ids
      await configuration.getCollectionPath('events').doc(Event.instance.id).collection('guests').doc(guestId).update({
        'allowed_modules': FieldValue.arrayRemove([moduleId]),
      });

      _event.guests.firstWhere((element) => element.id == guestId).allowedModules.remove(moduleId);
      notifyListeners();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> setEvent(String eventId) async {
    try {
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance.collection('events').doc(eventId).get();

      if (!eventSnapshot.exists) {
        throw Exception("Event not found for id: $eventId");
      }

      // Construire un AppEvent à partir des données Firestore
      Map<String, dynamic> eventData = eventSnapshot.data() as Map<String, dynamic>;
      print("Event Data :");
      print(eventData);

      // Notifier les listeners que l'événement a été mis à jour
      notifyListeners();
    } catch (e) {
      throw Exception("Error setting event: $e");
    }
  }
}
