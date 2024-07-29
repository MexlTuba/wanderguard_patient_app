import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderguard_patient_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_patient_app/models/patient.model.dart';
import 'package:wanderguard_patient_app/services/firestore_service.dart';

import '../enum/account_type.enum.dart';
import '../enum/auth_state.enum.dart';
import '../models/companion.model.dart';
import 'companion_data_controller.dart';

class AuthController with ChangeNotifier {
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  static void initialize() {
    GetIt.instance.registerSingleton<AuthController>(AuthController());
  }

  static AuthController get instance => GetIt.instance<AuthController>();

  late StreamSubscription<User?> currentAuthedUser;

  AuthState state = AuthState.unauthenticated;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  listen() {
    currentAuthedUser = _auth.authStateChanges().listen(handleUserChanges);
  }

  void handleUserChanges(User? user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user == null) {
      state = AuthState.unauthenticated;
      await prefs.remove('companionAcctId');
    } else {
      state = AuthState.authenticated;
      await prefs.setString('companionAcctId', user.uid);
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final auth.UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user == null) {
        throw Exception('User credential is null');
      }

      final String userId = userCredential.user!.uid;
      if (userId.isEmpty) {
        throw Exception('User ID is empty');
      }

      print('User ID: ${userId.runtimeType}: $userId');

      final Patient? patient =
          await FirestoreService.instance.getPatient(userId);
      print("getPatient Success");
      print('Patient data: $patient');

      if (patient == null) {
        throw Exception('Patient data is null');
      } else {
        print('HELLO PATIENT');
      }

      PatientDataController.instance.setPatient(patient);
    } catch (e, stacktrace) {
      print('Error logging in user: $e');
      print('Stacktrace: $stacktrace');
      throw Exception('Failed to log in');
    }
  }

  signInWithGoogle() async {
    GoogleSignInAccount? gSign = await _googleSignIn.signIn();
    if (gSign == null) throw Exception("No Signed in account");
    GoogleSignInAuthentication googleAuth = await gSign.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> register(
      String email,
      String password,
      String firstName,
      String lastName,
      String contactNo,
      String address,
      GeoPoint currentLocation) async {
    try {
      final auth.UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final Companion newCompanion = Companion(
        companionAcctId: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        email: email,
        address: address,
        currentLocation: currentLocation,
        contactNo: contactNo,
        photoUrl: '',
        acctType: AccountType.primaryCompanion,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirestoreService.instance.addOrUpdateCompanion(newCompanion);
      CompanionDataController.instance.setCompanion(newCompanion);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<void> logout() async {
    if (_googleSignIn.currentUser != null) {
      _googleSignIn.signOut();
    }
    await _auth.signOut();
    CompanionDataController.instance.setCompanion(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('companionAcctId');
  }

  Future<void> loadSession() async {
    listen();
    final prefs = await SharedPreferences.getInstance();
    String? companionAcctId = prefs.getString('companionAcctId');
    if (companionAcctId != null) {
      try {
        final Companion? companion =
            await FirestoreService.instance.getCompanion(companionAcctId);
        CompanionDataController.instance.setCompanion(companion);
        handleUserChanges(FirebaseAuth.instance.currentUser);
      } catch (e) {
        print('Error loading user session: $e');
        handleUserChanges(null);
      }
    } else {
      handleUserChanges(null);
    }
  }
}
