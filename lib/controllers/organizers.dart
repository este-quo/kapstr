import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:kapstr/models/app_organizer.dart';
import 'package:kapstr/themes/constants.dart';

class OrganizersController extends ChangeNotifier {
  CollectionReference get _organizersCollection => configuration.getCollectionPath('organisers');

  // Update Organizer
  Future<void> updateOrganizer(String organizerId, AppOrganizer updatedOrganizer) async {
    printOnDebug(organizerId);
    await _organizersCollection.doc(organizerId).update(updatedOrganizer.toMap());
  }
}
