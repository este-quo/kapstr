import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kapstr/configuration/navigation/app_router.dart';
import 'package:kapstr/helpers/debug_helper.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = GoogleSignIn();

Future<User?> signInGoogle(BuildContext context) async {
  try {
    GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      printOnDebug("Can't reach Google sign-in services");
      return null;
    }

    GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    final User? user = (await _auth.signInWithCredential(credential)).user;

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppRouter()));

    return user!;
  } catch (error) {
    printOnDebug("Error signing in: $error");
    // Display error message to user or handle it appropriately
    rethrow; // Re-throwing the error to handle it in the UI
  }
}

Future<void> signOut() async {
  await _googleSignIn.signOut();
  await _auth.signOut();
}
