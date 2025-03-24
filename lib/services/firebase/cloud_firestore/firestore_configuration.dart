import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _fireStore = FirebaseFirestore.instance;

class FirestoreConfiguration {
  CollectionReference getCollectionPath(String collection) {
    return _fireStore.collection(collection);
  }
}
