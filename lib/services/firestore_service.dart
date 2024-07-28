import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:get_it/get_it.dart';

import '../enum/account_status.enum.dart';
import '../enum/account_type.enum.dart';
import '../models/companion.model.dart';
import '../models/patient.model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static FirestoreService get instance => GetIt.instance<FirestoreService>();

  static void initialize() {
    GetIt.instance.registerSingleton<FirestoreService>(FirestoreService());
  }

  Future<void> addOrUpdateCompanion(Companion companion) async {
    final companionRef =
        _db.collection('companions').doc(companion.companionAcctId);
    await companionRef.set(companion.toFirestore());
  }

  Future<Companion?> getCompanion(String companionAcctId) async {
    final companionRef = _db.collection('companions').doc(companionAcctId);
    final doc = await companionRef.get();
    if (doc.exists) {
      return Companion.fromFirestore(doc);
    }
    return null;
  }

  Future<void> deleteCompanion(String companionAcctId) async {
    final companionRef = _db.collection('companions').doc(companionAcctId);
    await companionRef.delete();
  }

  Future<void> addOrUpdatePatient(Patient patient) async {
    final patientRef = _db.collection('patients').doc(patient.patientAcctId);
    await patientRef.set(patient.toFirestore());
  }

  Future<Patient?> getPatient(String patientAcctId) async {
    print("Getting patient with ID: $patientAcctId");
    final patientRef = _db.collection('patients').doc(patientAcctId);
    print("Patient ref: $patientRef");
    final doc = await patientRef.get();
    print("Patient doc: $doc");
    if (doc.exists) {
      print("SUCCESS: Patient found!");
      return Patient.fromFirestore(doc);
    } else {
      print("ERROR: Patient not found!");
    }
    return null;
  }

  Future<void> addPatient(Patient patient) async {
    final User? companionUser = _auth.currentUser;
    if (companionUser != null) {
      try {
        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: patient.email,
          password: patient.password,
        );

        String patientUid = userCredential.user!.uid;

        final Patient newPatient = Patient(
          patientAcctId: patientUid,
          firstName: patient.firstName,
          lastName: patient.lastName,
          email: patient.email,
          password: patient.password,
          homeAddress: patient.homeAddress,
          contactNo: patient.contactNo,
          dateOfBirth: patient.dateOfBirth,
          photoUrl: '',
          acctType: AccountType.patient,
          acctStatus: AccountStatus.offline,
          lastLocTracked: GeoPoint(0, 0),
          lastLocUpdated: DateTime.now(),
          defaultGeofence: patient.defaultGeofence,
          geofences: patient.geofences,
          emergencyContacts: patient.emergencyContacts,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          companionAcctId: companionUser.uid,
        );

        final DocumentReference docRef =
            _db.collection('patients').doc(patientUid);
        await docRef.set(newPatient.toFirestore());
      } catch (e) {
        throw Exception("Error registering patient: $e");
      }
    } else {
      throw Exception("No user is currently logged in.");
    }
  }
}
