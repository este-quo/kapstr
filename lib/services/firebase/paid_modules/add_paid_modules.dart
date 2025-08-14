import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapstr/helpers/capitalize.dart';

import 'package:kapstr/helpers/module_data.dart' as module_data;
import 'package:kapstr/themes/constants.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
const int timeout = 60;

Future<void> addModuleWeddingToEvent(String eventId, String weddignName, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.weddingModule(capitalize(weddignName), eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addCustomEventToEvent(String eventId, String moduleName, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.eventModule(eventType, moduleName));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addInvitationCardToEvent(String eventId, String manFirstName, String womanFirstName, String introduction, String conclusion, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.invitationCardModule(womanFirstName, manFirstName, introduction, conclusion, eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addMairieToEvent(String eventId, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.mairieModule(eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addGoldenBookToEvent(String eventId, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.goldenBookModule(eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addAboutToEvent(String eventId, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.aboutModule(eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addCagnotteToEvent(String eventId, String moduleName, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.cagnotteModule(moduleName, eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addAlbumPhotoToEvent(String eventId, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.albumModule(eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}

Future<void> addMediaModule(String eventId, String moduleName, String eventType) async {
  DocumentReference docRef = await configuration.getCollectionPath('events').doc(eventId).collection('modules').add(module_data.mediaModule(moduleName, eventType));

  String moduleId = docRef.id;

  await configuration.getCollectionPath('events').doc(eventId).update({
    'modules_order': FieldValue.arrayUnion([moduleId]),
  });
}
