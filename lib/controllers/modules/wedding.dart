import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/models/app_event.dart';
import 'package:kapstr/models/modules/wedding.dart';
import 'package:kapstr/themes/constants.dart';

class WeddingController extends ChangeNotifier {
  Future<WeddingModule?> getWeddingByID(String partyId) async {
    DocumentSnapshot doc = await configuration.getCollectionPath('events').doc(Event.instance.id).collection('modules').doc(partyId).get();

    if (doc.exists) {
      return WeddingModule.fromMap(doc.id, doc.data()! as Map<String, dynamic>);
    }
    return null;
  }
}
