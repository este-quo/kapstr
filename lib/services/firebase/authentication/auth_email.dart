import 'package:firebase_auth/firebase_auth.dart';
import 'package:kapstr/helpers/debug_helper.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signInWithEmailAndPassword(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (error) {
    printOnDebug("Error registering with email: $error");
    rethrow;
  }
}

Future<User?> registerWithEmailAndPassword(String email, String password, String firstName, String lastName) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    await userCredential.user!.updateDisplayName("$firstName $lastName");
    return userCredential.user;
  } catch (error) {
    printOnDebug("Error registering with email: $error");
    rethrow;
  }
}

Future<bool> signOut() async {
  try {
    await _auth.signOut();
    return true;
  } catch (error) {
    printOnDebug("Error signing out: $error");
    return false;
  }
}
