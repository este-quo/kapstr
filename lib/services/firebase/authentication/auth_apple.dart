import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kapstr/configuration/navigation/app_router.dart';
import 'package:kapstr/helpers/debug_helper.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<User> signInWithAppleAndFirebase(BuildContext context) async {
  final rawNonce = generateNonce();
  final nonce = sha256ofString(rawNonce);

  AuthorizationCredentialAppleID appleIdCredential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName], nonce: nonce);

  final oAuthProvider = OAuthProvider('apple.com');
  final credential = oAuthProvider.credential(idToken: appleIdCredential.identityToken, accessToken: appleIdCredential.authorizationCode, rawNonce: rawNonce);

  final userCredential = await _auth.signInWithCredential(credential);
  final firebaseUser = userCredential.user!;

  if (appleIdCredential.givenName != "" && appleIdCredential.givenName != null) {
    await firebaseUser.updateDisplayName(appleIdCredential.givenName);
  }

  if (appleIdCredential.email != "" && appleIdCredential.email != null) {
    await firebaseUser.verifyBeforeUpdateEmail(appleIdCredential.email!);
  }

  // After sign-in, navigate to AppRouter to handle user data
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const AppRouter()));

  return firebaseUser;
}

Future<void> signOut() async {
  await _auth.signOut();
}

/// Generates a cryptographically secure random nonce, to be included in a
/// credential request.
String generateNonce([int length = 32]) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

/// Returns the sha256 hash of [input] in hex notation.
String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
