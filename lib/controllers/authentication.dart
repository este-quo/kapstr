import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/controllers/places.dart';
import 'package:kapstr/controllers/rsvps.dart';
import 'package:kapstr/controllers/users.dart';
import 'package:kapstr/services/firebase/authentication/auth_google.dart' as google_auth;
import 'package:kapstr/services/firebase/authentication/auth_apple.dart' as apple_auth;
import 'package:kapstr/services/firebase/authentication/auth_email.dart' as email_auth;
import 'package:provider/provider.dart';

/// Contrôleur d'authentification centralisé et optimisé
class AuthenticationController extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  User? _user;
  bool isPendingConnection = false;

  User? get user => _user;

  AuthenticationController() {
    _firebaseAuth.authStateChanges().listen(_onAuthStateChanged);
  }

  void setPendingConnection(bool value) {
    if (isPendingConnection != value) {
      isPendingConnection = value;
      notifyListeners();
    }
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    notifyListeners();
  }

  /// Méthode utilitaire pour gérer les erreurs et notifier
  Future<void> _runAuthAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    await _runAuthAction(() => google_auth.signInGoogle(context));
  }

  Future<void> signInWithApple(BuildContext context) async {
    await _runAuthAction(() => apple_auth.signInWithAppleAndFirebase(context));
  }

  /// Connexion avec email et mot de passe
  Future<void> signInWithEmail(String email, String password) async {
    await _runAuthAction(() => email_auth.signInWithEmailAndPassword(email, password));
  }

  /// Inscription avec email
  Future<void> registerWithEmail(String email, String password, String firstName, String lastName) async {
    await _runAuthAction(() => email_auth.registerWithEmailAndPassword(email, password, firstName, lastName));
  }

  /// Suppression de l'utilisateur courant
  Future<void> deleteUser(BuildContext context) async {
    await _runAuthAction(() async {
      await _firebaseAuth.currentUser?.delete();
      await logout(context);
    });
  }

  /// Déconnexion complète et nettoyage du contexte
  Future<void> logout(BuildContext context) async {
    if (_user == null) return;
    await _runAuthAction(() async {
      await apple_auth.signOut();
      await google_auth.signOut();
      await _firebaseAuth.signOut();
      await _onAuthStateChanged(null);
      // Nettoyage des contrôleurs liés à l'utilisateur
      context.read<UsersController>().clear();
      context.read<RSVPController>().clear();
      context.read<PlacesController>().clear();
      setPendingConnection(false);
    });
  }
}
