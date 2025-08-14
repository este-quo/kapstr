import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/tmp/customization.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:provider/provider.dart';

class EventsController extends ChangeNotifier {
  Event _event;
  bool isGuestPreview = false;
  EventsController(this._event, {this.isGuestPreview = false});
  bool isLoading = false;
  bool isOrganizerCodeEntered = false;

  Event get event => _event;

  Future initOrganizer(String? phone, BuildContext context) async {
    if (phone == null) {
      isOrganizerCodeEntered = true;
    } else {
      Event.instance.addOrganizer(phone);

      await context.read<EventsController>().updateEventField(key: 'organizer_added', value: Event.instance.organizerAdded);

      await context.read<EventsController>().updateEventField(key: 'organizer_to_add', value: Event.instance.organizerAdded);
    }
  }

  void changeGuestPreview() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      isGuestPreview = !isGuestPreview;
      notifyListeners();
    });
  }

  void disableGuestPreview() {
    // Use addPostFrameCallback to defer the state change
    SchedulerBinding.instance.addPostFrameCallback((_) {
      isGuestPreview = false;
      notifyListeners();
    });
  }

  void updateModule(Module updatedModule) {
    // Find the index of the module to be updated
    int index = _event.modules.indexWhere((module) => module.id == updatedModule.id);

    // Check if the module was found
    if (index != -1) {
      // Replace the old module with the updated one
      _event.modules[index] = updatedModule;

      // Clear the image cache to ensure images are reloaded
      PaintingBinding.instance.imageCache.clear();

      notifyListeners();
    }
  }

  void updateModuleCustomization({required String moduleId, required Customization customization}) {
    int index = _event.modules.indexWhere((module) => module.id == moduleId);

    if (index != -1) {
      _event.modules[index].textColor = customization.textColor;
      _event.modules[index].colorFilter = customization.backgroundColor;
      _event.modules[index].fontType = customization.fontName;
      _event.modules[index].textSize = customization.fontSize;

      PaintingBinding.instance.imageCache.clear();

      notifyListeners();
    }
  }

  void updateEvent(Event newEvent) async {
    _event = newEvent;
    notifyListeners();
  }

  Future<void> confirmGuestAddition(String eventId, String phone, String userId) async {
    printOnDebug('Confirming guest addition with phone: $phone');
    printOnDebug('Event ID: $eventId');
    try {
      await configuration.getCollectionPath('events').doc(eventId).collection('guests').where('phone', isEqualTo: phone).get().then((value) {
        value.docs.first.reference.update({"user_id": userId, 'has_joined': true});
      });
    } catch (e) {
      printOnDebug('Error confirming guest addition: $e');
      throw Exception(e);
    }
  }

  Future<void> removeCustomTheme(String themeUrl) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).update({
        'custom_theme_urls': FieldValue.arrayRemove([themeUrl]),
      });
    } catch (e) {
      throw Exception(e);
    }

    Event.instance.customThemeUrls.remove(themeUrl);
    updateEvent(Event.instance);
    notifyListeners();
  }

  Future<void> updateEventTheme(String rowResThemeUrl, String fullResThemeUrl, double themeOpacity, String themeType, String themeName, List<String> themeColors) async {
    _event.lowResThemeUrl = rowResThemeUrl;
    _event.fullResThemeUrl = fullResThemeUrl;
    _event.themeOpacity = themeOpacity;
    _event.themeType = themeType;
    _event.themeName = themeName;
    _event.themeColors = themeColors;
    notifyListeners();
  }

  Future<void> updateModules(List<Module> newModules) async {
    _event.modules = newModules;
    notifyListeners();
    Event.instance.modules = newModules;
  }

  // NEW VERSION

  Future<void> updateModulesOrder() async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).update({'modules_order': Event.instance.modulesOrder});
    } catch (e) {
      printOnDebug('Error updating modules order: $e');
      throw Exception('Failed to update modules order in Firestore.');
    }
  }

  Future<void> updateSaveTheDateThumbnail({required String url}) {
    return configuration.getCollectionPath('events').doc(Event.instance.id).update({'save_the_date_thumbnail': url});
  }

  Future<void> updateSaveTheDateThumbnailFromId({required String url, required String eventId}) {
    return configuration.getCollectionPath('events').doc(eventId).update({'save_the_date_thumbnail': url});
  }

  Future<void> updateFavoriteColors({required String color}) async {
    try {
      await configuration.getCollectionPath('events').doc(Event.instance.id).update({
        'favorite_colors': FieldValue.arrayUnion([color]),
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateEventName(String eventId, String eventName) {
    return configuration.getCollectionPath('events').doc(eventId).update({'event_name': eventName});
  }

  Future<void> updateEventLogo(String eventId, String url) async {
    try {
      await configuration.getCollectionPath('events').doc(eventId).update({'event_logo_url': url});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateEventField<T>({required String key, required T value}) async {
    try {
      // Ensure the value is either String or List<String>

      await configuration.getCollectionPath('events').doc(Event.instance.id).update({key: value});
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateEventFields({required Map<String, dynamic> fieldsToUpdate, required String eventId}) async {
    try {
      await configuration.getCollectionPath('events').doc(eventId).update(fieldsToUpdate);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteEvent(String eventId, BuildContext context) async {
    final WriteBatch batch = FirebaseFirestore.instance.batch();

    try {
      // Get all event guests
      final QuerySnapshot guestsSnapshot = await configuration.getCollectionPath('events').doc(eventId).collection('guests').get();

      // Get all event organisers
      final QuerySnapshot organisersSnapshot = await configuration.getCollectionPath('organisers').where('event_id', isEqualTo: eventId).get();

      // Add delete event operation to batch
      batch.delete(configuration.getCollectionPath('events').doc(eventId));

      // Remove event from user's created events (assuming only one user can create an event)
      final QuerySnapshot userSnapshot = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();
      if (userSnapshot.docs.isNotEmpty) {
        batch.update(userSnapshot.docs.first.reference, {
          'created_events': FieldValue.arrayRemove([eventId]),
        });
      }

      // Remove event from users' joined events and organisers' created events, ensuring 'user_id' is not empty
      for (var guest in guestsSnapshot.docs) {
        final String? userId = guest['user_id'];
        if (userId != null && userId.isNotEmpty) {
          batch.update(configuration.getCollectionPath('users').doc(userId), {
            'joined_events': FieldValue.arrayRemove([eventId]),
          });
        }
      }

      for (var organiser in organisersSnapshot.docs) {
        final String? userId = organiser['user_id'];
        if (userId != null && userId.isNotEmpty) {
          batch.update(configuration.getCollectionPath('users').doc(userId), {
            'created_events': FieldValue.arrayRemove([eventId]),
          });
        }
      }

      // Delete organisers and tables related to the event
      for (var doc in organisersSnapshot.docs) {
        batch.delete(doc.reference);
      }
      final QuerySnapshot tablesSnapshot = await configuration.getCollectionPath('tables').where('event_id', isEqualTo: eventId).get();
      for (var doc in tablesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      context.read<UsersController>().user!.createdEvents.remove(eventId);
      // Commit the batch
      await batch.commit();
    } on FirebaseException catch (e) {
      printOnDebug(e.code);

      rethrow;
    } catch (e) {
      // Handle any other errors

      throw Exception("Failed to delete event: $e");
    }
  }

  Future<void> leaveEvent(String eventId, BuildContext context) async {
    try {
      // get current user
      QuerySnapshot<Object?> user = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();

      //  get event guest
      QuerySnapshot<Object?> guest = await configuration.getCollectionPath('events').doc(eventId).collection('guests').where('user_id', isEqualTo: user.docs.first.id).get();

      // remove event from user joined events
      await configuration.getCollectionPath('users').doc(user.docs.first.id).update({
        'joined_events': FieldValue.arrayRemove([eventId]),
      });

      // update status of guest to false
      await configuration.getCollectionPath('events').doc(eventId).collection('guests').doc(guest.docs.first.id).update({'has_joined': false});

      context.read<UsersController>().user!.joinedEvents.remove(eventId);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPaidModules() async {
    try {
      final result = await configuration.getCollectionPath('paid_modules').get();
      return result as QuerySnapshot<Map<String, dynamic>>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getEvent(String eventId) async {
    DocumentSnapshot<Object?> event = await configuration.getCollectionPath('events').doc(eventId).get();

    return event.data() as Map<String, dynamic>;
  }

  Future<QueryDocumentSnapshot> getEventOrganiser(String eventId) async {
    QuerySnapshot<Object?> organiser = await configuration.getCollectionPath('organisers').where('event_id', isEqualTo: eventId).get();
    if (organiser.docs.isEmpty) {
      throw Exception('No organiser found for this event');
    }

    return organiser.docs.first;
  }

  Future<QueryDocumentSnapshot> getJoinedEventOrganiser(String eventId) async {
    QuerySnapshot<Object?> organiser = await configuration.getCollectionPath('organisers').where('event_id', isEqualTo: eventId).get();
    if (organiser.docs.isEmpty) {
      throw Exception('No organiser found for this event');
    }

    return organiser.docs.first;
  }

  Future<QuerySnapshot<Object?>> checkIfEventExistWithCode(String code) async {
    return await configuration.getCollectionPath('events').where('code', isEqualTo: code).get();
  }

  Future<bool> isOrganizer(BuildContext context, String code) async {
    String userId = context.read<UsersController>().user!.id;
    QuerySnapshot<Object?> organiser = await configuration.getCollectionPath('organisers').where('event_id', isEqualTo: context.read<EventsController>()._event.id).get();
    String eventOrganiszerId = organiser.docs.first["user_id"];
    return userId == eventOrganiszerId;
  }

  Future<bool> checkIfGuestIsAllowed(String eventId, String code, String guestPhone, String eventVisibility) async {
    bool isGuestAllowed = false;

    if (eventVisibility == "public") {
      isGuestAllowed = true;
    } else {
      QuerySnapshot guest = await configuration.getCollectionPath('events').doc(eventId).collection('guests').where('event_id', isEqualTo: eventId).where('phone', isEqualTo: guestPhone).get();
      if (guest.docs.isNotEmpty) {
        printOnDebug('Guest found: ${guest.docs.first.data()}');
        isGuestAllowed = true;
      }
    }

    printOnDebug('Is guest allowed: $isGuestAllowed');

    return isGuestAllowed;
  }

  Future<List<Guest>> getEventGuests(String eventId) async {
    QuerySnapshot<Object?> guests = await configuration.getCollectionPath('events').doc(eventId).collection('guests').get();

    List<Guest> eventGuests = [];

    for (var guest in guests.docs) {
      eventGuests.add(Guest.fromMap(guest.data() as Map<String, dynamic>, guest.id));
    }

    return eventGuests;
  }

  Future<void> joinedToCreatedEvent(String eventId) async {
    try {
      await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get().then((value) {
        value.docs.first.reference.update({
          'joined_events': FieldValue.arrayRemove([eventId]),
          'created_events': FieldValue.arrayUnion([eventId]),
        });
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> createdToJoinedEvent(String eventId) async {
    try {
      await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get().then((value) {
        value.docs.first.reference.update({
          'created_events': FieldValue.arrayRemove([eventId]),
          'joined_events': FieldValue.arrayUnion([eventId]),
        });
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> confirmOrganizerAddition(String eventId, String guestPhone) async {
    try {
      await configuration.getCollectionPath('events').doc(eventId).update({
        'organizer_added': FieldValue.arrayUnion([guestPhone]),
        'organizer_to_add': FieldValue.arrayRemove([guestPhone]),
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> removeOrganizer(String eventId, String guestPhone) async {
    try {
      await configuration.getCollectionPath('events').doc(eventId).update({
        'organizer_added': FieldValue.arrayRemove([guestPhone]),
      });

      await configuration.getCollectionPath('organisers').where('phone', isEqualTo: guestPhone).where('event_id', isEqualTo: eventId).get().then((value) {
        value.docs.first.reference.delete();
      });

      await configuration.getCollectionPath('users').where('phone', isEqualTo: guestPhone).get().then((value) {
        value.docs.first.reference.update({
          'created_events': FieldValue.arrayRemove([eventId]),
        });
        value.docs.first.reference.update({
          'joined_events': FieldValue.arrayUnion([eventId]),
        });
      });
    } catch (e) {
      throw Exception(e);
    }
  }

  String getFileNameWithExtension(String url) {
    // Décoder l'URL
    String decodedUrl = Uri.decodeFull(url);

    // Extraire le chemin du fichier
    String filePath = Uri.parse(decodedUrl).path;

    // Séparer les segments de chemin
    List<String> pathSegments = filePath.split('/');

    // Prendre le dernier segment (nom du fichier avec extension)
    return pathSegments.isNotEmpty ? pathSegments.last : '';
  }
}
