import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/authentication.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/user.dart';
import 'package:kapstr/themes/constants.dart';
import 'package:provider/provider.dart';

class UsersController extends ChangeNotifier {
  User? user;
  String lastEventId = '';
  String onboardingFirstName = '';
  String onboardingLastName = '';

  void updateOnboardingFirstName(String firstName) {
    onboardingFirstName = firstName;
    notifyListeners();
  }

  void updateOnboardingLastName(String lastName) {
    onboardingLastName = lastName;
    notifyListeners();
  }

  void updateLastEventId(String eventId) {
    lastEventId = eventId;
    notifyListeners();
  }

  void updateJoinedEvents(List<String> newEvents) {
    user!.joinedEvents = newEvents;
    notifyListeners();
  }

  void updateCreatedEvents(List<String> newEvents) {
    user!.createdEvents = newEvents;
    notifyListeners();
  }

  Future<void> initUser() async {
    QuerySnapshot userDocs = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();

    if (userDocs.docs.isNotEmpty) {
      Map<String, dynamic> userDocData = userDocs.docs.first.data() as Map<String, dynamic>;
      user = User.fromMap(userDocData, userDocs.docs.first.id);
    }

    printOnDebug('User initialized: $user');
    notifyListeners();
  }

  Future<List<String>> getUserEvents() async {
    List<String> userEventsIds = [];

    QuerySnapshot userDocs = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();

    if (userDocs.docs.isNotEmpty) {
      Map<String, dynamic> userDocData = userDocs.docs.first.data() as Map<String, dynamic>;
      List<String>? userEvents = userDocData['created_events']?.cast<String>();

      if (userEvents != null && userEvents.isNotEmpty) {
        userEventsIds = userEvents;
      }
    }

    return userEventsIds;
  }

  Future<void> updateUserFields(Map<String, dynamic> updates) async {
    if (user == null) {
      printOnDebug('Error: User is null, cannot update fields.');
      return;
    }

    updates.forEach((key, value) {
      user!.updateField(key, value);
    });

    try {
      await saveUser();
      printOnDebug('User updated successfully.');
    } catch (e) {
      printOnDebug('Error updating user: $e');
    }

    notifyListeners();
  }

  Future<void> saveUser() async {
    printOnDebug('User to save: ${user!.toMap()}');
    try {
      await configuration.getCollectionPath('users').doc(user!.id).update(user!.toMap());
    } catch (e) {
      printOnDebug(e.toString());
    }
  }

  Future<List<String>> getUserJoinedEvents() async {
    List<String> userEventsIds = [];

    QuerySnapshot userDocs = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();

    if (userDocs.docs.isNotEmpty) {
      Map<String, dynamic> userDocData = userDocs.docs.first.data() as Map<String, dynamic>;
      List<String>? userEvents = userDocData['joined_events']?.cast<String>();

      if (userEvents != null && userEvents.isNotEmpty) {
        userEventsIds = userEvents;
      }
    }

    return userEventsIds;
  }

  Future<void> addEventToUser(String eventId, BuildContext context, {required bool isCreatedEvent}) async {
    var userDoc = await configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();

    if (userDoc.docs.isEmpty) return;

    Map<String, dynamic> userDocData = userDoc.docs.first.data() as Map<String, dynamic>;
    String eventField = isCreatedEvent ? 'created_events' : 'joined_events';
    List<String>? userEvents = userDocData[eventField]?.cast<String>();

    if (userEvents?.contains(eventId) ?? false) return;

    userEvents = userEvents != null ? [...userEvents, eventId] : [eventId];

    if (isCreatedEvent) {
      context.read<UsersController>().updateCreatedEvents(userEvents);
    } else {
      context.read<UsersController>().updateJoinedEvents(userEvents);
    }

    await configuration.getCollectionPath('users').doc(userDoc.docs.first.id).update({eventField: userEvents});
  }

  Future<void> addNewEvent(String eventId, BuildContext context) async {
    await addEventToUser(eventId, context, isCreatedEvent: true);
  }

  Future<void> addNewJoinedEvent(String eventId, BuildContext context) async {
    await addEventToUser(eventId, context, isCreatedEvent: false);
  }

  Future<QuerySnapshot> currentUser() {
    return configuration.getCollectionPath('users').where('id_auth_token', isEqualTo: firebaseAuth.currentUser!.uid).get();
  }

  Future<void> deleteUser(String userId, BuildContext context) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).delete();
    await context.read<AuthenticationController>().deleteUser(context);
  }

  void clear() {
    user = null;
    lastEventId = '';
    onboardingFirstName = '';
    onboardingLastName = '';
    notifyListeners();
  }
}
