import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/configuration/in_app_purchase_service.dart';
import 'package:kapstr/controllers/guests.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/services/firebase/authentication/auth_google.dart' as google_auth;
import 'package:kapstr/services/firebase/authentication/auth_apple.dart' as apple_auth;
import 'package:kapstr/services/firebase/authentication/auth_email.dart' as email_auth;
import 'package:provider/provider.dart';

class AuthenticationController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  bool isPendingConnection = false;

  User? get user => _user;

  AuthenticationController() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  void setPendingConnection(bool value) {
    isPendingConnection = value;
    notifyListeners();
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await google_auth.signInGoogle(context);
  }

  Future<void> signInWithApple(BuildContext context) async {
    await apple_auth.signInWithAppleAndFirebase(context);
  }

  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await email_auth.signInWithEmailAndPassword(email, password);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> registerWithEmail(String email, String password, String firstName, String lastName) async {
    await email_auth.registerWithEmailAndPassword(email, password, firstName, lastName);
  }

  Future<void> deleteUser(BuildContext context) async {
    await _firebaseAuth.currentUser!.delete();
    await logout(context);
  }

  Future<void> logout(BuildContext context) async {
    if (_user != null) {
      await apple_auth.signOut();
      await google_auth.signOut();
      await _firebaseAuth.signOut();
      _onAuthStateChanged(null);
      context.read<UsersController>().clear();
      context.read<RSVPController>().clear();
      context.read<PlacesController>().clear();

      context.read<AuthenticationController>().setPendingConnection(false);

      notifyListeners();
    }
  }
}
