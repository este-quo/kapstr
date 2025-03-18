import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
const int timeout = 60;

Future<bool> signOut() async {
  await _firebaseAuth.signOut().timeout(const Duration(seconds: timeout));
  return true;
}

String getAuthId() {
  return _firebaseAuth.currentUser!.uid;
}
