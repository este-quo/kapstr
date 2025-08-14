import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/added_guest.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/models/place.dart';
import 'package:kapstr/models/rsvp.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

Future<void> createRsvpsForGuest(String guestID, String guestName, BuildContext context) async {
  printOnDebug('Starting RSVP creation for guest: $guestName');

  try {
    // Récupération des modules de l'événement
    List<Module> modules = Event.instance.modules;

    // Modules à exclure
    List<String> excludedModules = kNonEventModules;

    // Liste des tâches pour la création de RSVPs
    List<Future<void>> tasks = [];

    // Contrôleur RSVP
    final rsvpController = context.read<RSVPController>();

    for (var module in modules) {
      // Ignorer les modules exclus
      if (excludedModules.contains(module.type)) {
        continue;
      }

      // Vérifier dans la base de données si un RSVP existe déjà
      bool rsvpExists = await rsvpController.checkIfRsvpExists(guestID, module.id);

      if (rsvpExists) {
        printOnDebug('RSVP already exists for guest: $guestName, module: ${module.id}');
        continue; // Passer au module suivant
      }

      // Créer un nouveau RSVP
      RSVP newRsvp = RSVP(guestId: guestID, moduleId: module.id, isAllowed: true, adults: [AddedGuest(id: generateRandomId(), name: guestName)], children: [], response: 'En attente', createdAt: DateTime.now(), isAnswered: false);

      // Ajouter la tâche de création du RSVP
      tasks.add(rsvpController.addRSVP(newRsvp));

      printOnDebug('RSVP created for guest: $guestName, module: ${module.id}');
    }

    // Attendre la fin de toutes les tâches
    await Future.wait(tasks);

    printOnDebug('RSVP creation completed for guest: $guestName');
  } catch (e) {
    // Gérer les erreurs lors de la création des RSVPs
    printOnDebug('Error creating RSVPs for guest $guestName: $e');
  }
}

String generateRandomId() {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  final random = Random();
  return List.generate(10, (index) => characters[random.nextInt(characters.length)]).join();
}

List<AddedGuest> getAllAddedsFromRsvps(List<RSVP> rsvps) {
  List<AddedGuest> addeds = [];
  for (var rsvp in rsvps) {
    addeds.insertAll(0, rsvp.adults);
    addeds.insertAll(0, rsvp.children);
  }

  final seenIds = <String>{};
  addeds =
      addeds.where((added) {
        if (!seenIds.contains(added.id)) {
          seenIds.add(added.id);
          return true;
        }
        return false;
      }).toList();

  return addeds;
}

List<String> getIdsFromPlaces(List<Place> places) {
  // Récupérer uniquement les identifiants non-nuls de la liste de places
  return places.where((place) => place.id != "").map((place) => place.id).toList();
}
