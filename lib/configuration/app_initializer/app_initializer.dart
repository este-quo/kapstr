import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/events.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/helpers/rsvp.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/app_guest.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/models/guest.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:provider/provider.dart';
import 'package:kapstr/services/firebase/cloud_firestore/cloud_firestore.dart' as cloud_firestore;

class AppInitializer {
  final GuestsController _guestsController = GuestsController(Event.instance);

  Future<bool> initOrganiser(String eventId, BuildContext context) async {
    try {
      final eventsController = context.read<EventsController>();

      // Fetch event and organizer data in parallel
      final eventFuture = eventsController.getEvent(eventId);
      final organiserFuture = eventsController.getEventOrganiser(eventId);

      final List<dynamic> results = await Future.wait([eventFuture, organiserFuture]);

      final Map<String, dynamic>? event = results[0];
      final QueryDocumentSnapshot? organiser = results[1];

      if (event == null || organiser == null) {
        printOnDebug(event == null ? "Event not found" : "Organizer not found");
        return false;
      }

      // Fetch modules and guests in parallel
      final modulesFuture = cloud_firestore.getAllModulesFromEvent(eventId);
      final guestsFuture = _guestsController.getGuests(eventId);

      final List<dynamic> eventDetails = await Future.wait([modulesFuture, guestsFuture]);

      final List<Module> modules = eventDetails[0];
      final List<Guest> guests = eventDetails[1];

      // Initialize AppOrganizer and Event instances
      AppOrganizer(organiser.data() as Map<String, dynamic>, organiser.id);
      Event(event, eventId, modules, guests);

      // Update the event in the controller
      eventsController.updateEvent(Event.instance);

      printOnDebug('Event and organizer initialization completed');
      return true;
    } catch (e) {
      printOnDebug("Error initializing organizer: $e");
      return false;
    }
  }

  Future<bool> initGuest(String eventId, String phone, BuildContext context) async {
    printOnDebug("[initGuest] Start for eventId: $eventId");
    try {
      printOnDebug("Initializing guest with phone: $phone for : $eventId");
      final eventsController = context.read<EventsController>();

      // Fetch event and organizer data in parallel
      final eventFuture = eventsController.getEvent(eventId);
      final organiserFuture = eventsController.getEventOrganiser(eventId);

      final List<dynamic> results = await Future.wait([eventFuture, organiserFuture]);
      printOnDebug("[initGuest] Event and organiser fetched");

      final Map<String, dynamic>? eventData = results[0];
      final QueryDocumentSnapshot? organiserDoc = results[1];

      if (eventData == null || organiserDoc == null) {
        printOnDebug(eventData == null ? "Event not found" : "Organizer not found");
        return false;
      }

      AppOrganizer(organiserDoc.data() as Map<String, dynamic>, organiserDoc.id);
      printOnDebug("[initGuest] AppOrganizer initialized with id: ${organiserDoc.id}");

      // Set guest
      _guestsController.setGuest(eventId, phone);

      // Fetch guest, modules and all guests in parallel
      printOnDebug("Fetching guest, modules and all guests in parallel");
      printOnDebug("[initGuest] Starting parallel fetch of guest, modules, and guests");
      final guestFuture = _guestsController.currentGuest(eventId, phone);
      final modulesFuture = cloud_firestore.getAllModulesFromEvent(eventId);
      final guestsFuture = _guestsController.getGuests(eventId);

      final List<dynamic> eventDetails = await Future.wait([guestFuture, modulesFuture, guestsFuture]);
      printOnDebug("[initGuest] Parallel fetch completed");

      printOnDebug("Fetching guest, modules and all guests in parallel completed");
      final QuerySnapshot guestSnapshot = eventDetails[0];
      final List<Module> modules = eventDetails[1];
      final List<Guest> guests = eventDetails[2];

      if (guestSnapshot.docs.isEmpty) {
        printOnDebug("Guest not found with phone: $phone for event ID: $eventId");
        return false;
      }
      printOnDebug("Guest found with phone: $phone for event ID: $eventId");
      printOnDebug("[initGuest] Guest data loaded, ID: ${guestSnapshot.docs.first.id}");
      AppGuest(guestSnapshot.docs.first.data() as Map<String, dynamic>, guestSnapshot.docs.first.id);
      printOnDebug("Allowed modules appguest : ${AppGuest.instance.allowedModules} and guest id : ${AppGuest.instance.id}");

      // Initialisation de l'évènement
      printOnDebug("[initGuest] Initializing Event with ID: $eventId and ${modules.length} modules, ${guests.length} guests");
      Event(eventData, eventId, modules, guests);
      printOnDebug("[initGuest] Event.instance initialized: ${Event.instance.id}");
      await createRsvpsForGuest(AppGuest.instance.id, AppGuest.instance.name, context);

      // Update the event in the controller
      eventsController.updateEvent(Event.instance);
      printOnDebug("[initGuest] Event instance updated in EventsController with ID: ${Event.instance.id}");

      printOnDebug('Event and guest initialization completed successfully');
      return true;
    } catch (e) {
      printOnDebug("Error initializing guest: $e");
      return false;
    }
  }

  Future<bool> initVisitor(String eventId, BuildContext context) async {
    try {
      final eventsController = context.read<EventsController>();

      // Fetch event and organizer data in parallel
      final eventFuture = eventsController.getEvent(eventId);
      final organiserFuture = eventsController.getEventOrganiser(eventId);

      final List<dynamic> results = await Future.wait([eventFuture, organiserFuture]);

      final Map<String, dynamic>? eventData = results[0];
      final QueryDocumentSnapshot? organiserDoc = results[1];

      if (eventData == null || organiserDoc == null) {
        printOnDebug(eventData == null ? "Event not found" : "Organizer not found");
        return false;
      }

      AppOrganizer(organiserDoc.data() as Map<String, dynamic>, organiserDoc.id);

      // Fetch guest, modules and all guests in parallel
      final modulesFuture = cloud_firestore.getAllModulesFromEvent(eventId);
      final guestsFuture = _guestsController.getGuests(eventId);

      final List<dynamic> eventDetails = await Future.wait([modulesFuture, guestsFuture]);

      final List<Module> modules = eventDetails[0];
      final List<Guest> guests = eventDetails[1];

      // Initialize Event instance
      Event(eventData, eventId, modules, guests);

      // Update the event in the controller
      eventsController.updateEvent(Event.instance);

      printOnDebug('Event and guest initialization completed successfully');
      return true;
    } catch (e) {
      printOnDebug("Error initializing guest: $e");
      return false;
    }
  }
}
