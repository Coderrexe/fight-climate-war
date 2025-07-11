import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fight_climate_war/models/user.dart';

// Methods for authenticating users on Firebase.
class AuthMethods {
  // Entry point to the Firebase Authentication SDK.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Entry point to the Firebase Cloud Firestore database.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function for retrieving user information of the current user.
  Future<AppUser> getUserDetails() async {
    User currentUser = _auth.currentUser!;
    // User data represented in a snapshot.
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(currentUser.uid).get();
    // Return an instance of AppUser model with user data.
    return AppUser.fromSnapshot(snapshot);
  }

  // Function for creating a new user account with email and password.
  Future<Object> signUpWithEmail({
    required String username,
    required String email,
    required String password,
    required String bio,
    Uint8List? profilePicture,
  }) async {
    try {
      // Wait for Firebase to create the user.
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = credential.user!;

      // Add user to our database.
      AppUser appUser = AppUser(
        username: username,
        uid: credential.user!.uid,
        email: email,
        bio: bio,
        followers: [],
        following: [],
      );
      _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(appUser.toJson());
      return user;
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }

  // Function for logging in a user with email and password.
  Future<Object> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = credential.user!;
      return user;
    } catch (e) {
      print(e.toString());
      return e.toString();
    }
  }
}
