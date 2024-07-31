import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
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
      await prefs.remove('patientAcctId');
    } else {
      state = AuthState.authenticated;
      await prefs.setString('patientAcctId', user.uid);
      final service = FlutterBackgroundService();
      service.invoke('setPatientId', {'patientId': user.uid});
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

      // Start the background service and set the patient ID
      final service = FlutterBackgroundService();
      print('Starting Background Service...');
      await service.startService();
      await Future.delayed(
          Duration(seconds: 2)); // Ensure the service is started
      print('Invoking Background setPatientId...');
      service.invoke('setPatientId', {'patientId': userId});

      print('Setting Patient...');
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

  Future<void> logout() async {
    try {
      // Stop the background service
      final service = FlutterBackgroundService();
      service.invoke("stopService");

      // Sign out from Google if signed in
      if (_googleSignIn.currentUser != null) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _auth.signOut();

      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('patientAcctId');

      // Reset patient data
      PatientDataController.instance.setPatient(null);

      // Notify listeners to update UI
      state = AuthState.unauthenticated;
      notifyListeners();

      print('Successfully logged out and reset state');
    } catch (e) {
      print('Error during logout: $e');
      throw Exception('Failed to log out');
    }
  }

  Future<void> loadSession() async {
    listen();
    final prefs = await SharedPreferences.getInstance();
    String? patientAcctId = prefs.getString('patientAcctId');
    if (patientAcctId != null) {
      try {
        final Patient? patient =
            await FirestoreService.instance.getPatient(patientAcctId);
        PatientDataController.instance.setPatient(patient);
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
