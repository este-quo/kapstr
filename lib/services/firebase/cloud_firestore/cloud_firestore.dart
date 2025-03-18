import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/themes/constants.dart';

import 'package:kapstr/models/modules/module.dart';
import 'package:kapstr/helpers/string_to_type.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
const int timeout = 60;

Stream streamUserWithAuthToken(String authToken) {
  return configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: authToken).snapshots().handleError((error, stackTrace) {
    printOnDebug("Une erreur s'est produite lors de la récupération du document: $error");
  });
}

Stream streamEventByOrganiserId(String organiserId) {
  return configuration.getCollectionPath('events').where('organiser_auth_id', isEqualTo: organiserId).snapshots();
}

Future<List<Module>> getAllModulesFromEvent(String eventId) async {
  try {
    var modulesQuery = await configuration.getCollectionPath('events').doc(eventId).collection('modules').get();

    return modulesQuery.docs.map((e) {
      return Module.fromMap(e.id, e.data(), stringToType(e.data()['type']));
    }).toList();
  } catch (e) {
    // Handle the error appropriately here
    printOnDebug('Error fetching modules: $e');
    return []; // Return an empty list or handle the error in another way
  }
}

Future<bool> isPhoneNumberRegistered(String? phoneNumber) async {
  final usersCollection = configuration.getCollectionPath('users');
  final snapshot = await usersCollection.where('phone', isEqualTo: phoneNumber).get();
  if (snapshot.docs.isNotEmpty) {
    return true;
  }
  return false;
}

Future<void> createUser(Map<String, dynamic> map) async {
  await configuration.getCollectionPath('users').add(map).timeout(const Duration(seconds: timeout));
}

Future<bool> updateUserField(String id, var value, String key) async {
  bool success = true;

  try {
    await configuration.getCollectionPath('users').doc(id).update({key: value}).timeout(const Duration(seconds: timeout));
  } catch (exception) {
    success = false;
    printOnDebug('Erreur lors de la mise à jour de l\'utilisateur: $exception');
  }

  return success;
}

Future<DocumentReference<Map<String, dynamic>>> createEvent(Map<String, dynamic> map) async {
  return await configuration.getCollectionPath('events').add(map) as DocumentReference<Map<String, dynamic>>;
}

Future<void> addOrganisers(Map<String, dynamic> map, String eventId, String organiserId) async {
  await configuration.getCollectionPath('organisers').add(map);
}
