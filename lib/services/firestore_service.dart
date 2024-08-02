import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
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
    print("Fetching companion with ID: $companionAcctId");
    final companionRef = _db.collection('companions').doc(companionAcctId);
    print("Companion ref: $companionRef");
    final doc = await companionRef.get();
    print("Companion doc: $doc");
    if (doc.exists) {
      print("SUCCESS: Companion found!");
      return Companion.fromFirestore(doc);
    } else {
      print("ERROR: Companion not found!");
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
}
