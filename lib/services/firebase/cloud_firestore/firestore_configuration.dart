import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kapstr/configuration/app_configuration/app_configuration.dart';
import 'package:kapstr/configuration/app_configuration/models/configuration_mode.dart';

final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

class FirestoreConfiguration {
  CollectionReference getCollectionPath(String collection) {
    return _fireStore.collection(collection);
  }
}
