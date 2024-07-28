import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderguard_patient_app/services/firestore_service.dart';
import '../models/patient.model.dart';

class PatientDataController with ChangeNotifier {
  ValueNotifier<Patient?> patientModelNotifier = ValueNotifier(null);
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? patientStream;

  static void initialize() {
    GetIt.instance
        .registerSingleton<PatientDataController>(PatientDataController());
  }

  static PatientDataController get instance =>
      GetIt.instance<PatientDataController>();

  void setPatient(Patient? patient) {
    patientModelNotifier.value = patient;
    notifyListeners();
    if (patient != null) {
      listenToPatientChanges(patient.patientAcctId);
    } else {
      patientStream?.cancel();
      patientStream = null;
    }
  }

  void listenToPatientChanges(String patientAcctId) {
    patientStream?.cancel();
    patientStream = FirebaseFirestore.instance
        .collection("patients")
        .doc(patientAcctId)
        .snapshots()
        .listen(onPatientDataChange);
  }

  void onPatientDataChange(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (snapshot.exists) {
      final data = snapshot.data();
      if (data != null) {
        final patient = Patient.fromFirestore(snapshot);
        patientModelNotifier.value = patient;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    patientStream?.cancel();
    super.dispose();
  }
}
