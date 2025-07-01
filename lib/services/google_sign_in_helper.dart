

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<UserCredential?> signInWithGoogle() async {
  debugPrint("Google sign-in started");

  final GoogleSignIn googleSignIn = GoogleSignIn();

  // Ensure the user is signed out to force the account selection
  await googleSignIn.signOut();
  debugPrint("Google sign-out completed");

  // Trigger Google Sign-In flow
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  debugPrint("Google sign-in flow completed");

  if (googleUser == null) return null; // User canceled sign-in

  // Obtain authentication details
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
  debugPrint("Google authentication details obtained");

  // Create a credential
  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );
  debugPrint("Firebase credential created");

  // Sign in with Firebase
  try {
    final UserCredential userCredential =
    await FirebaseAuth.instance.signInWithCredential(credential);
    debugPrint("Firebase sign-in completed");
    return userCredential;
  } catch (e, stackTrace) {
    debugPrint("Firebase sign-in failed: $e",);
    return null;
  }
}

Future<void> signOut() async {
  debugPrint("Sign out started");
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
  debugPrint("Sign out completed");
}