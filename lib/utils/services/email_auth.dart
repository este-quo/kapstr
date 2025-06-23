import 'package:firebase_auth/firebase_auth.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User?> signInWithEmail(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (error) {
    throw Exception("Connexion avec email impossible");
  }
}

Future<User?> registerWithEmail(String email, String password) async {
  try {
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } catch (error) {
    throw Exception("Inscription avec email impossible");
  }
}

Future<bool> signOut() async {
  try {
    await _auth.signOut();
    return true;
  } catch (error) {
    throw Exception("Déconnexion impossible");
  }
}
