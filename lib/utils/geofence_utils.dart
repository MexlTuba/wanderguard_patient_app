import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
import 'package:wanderguard_patient_app/models/geofence.model.dart';
import 'package:wanderguard_patient_app/screens/home_screen.dart';

void drawGeofence(HomeScreenState homeScreenState, Geofence? geofence) {
  if (geofence != null) {
    final center = LatLng(geofence.center.latitude, geofence.center.longitude);
    final radius = geofence.radius;

    final circle = Circle(
      circleId: CircleId(
          'geofence_${geofence.center.latitude}_${geofence.center.longitude}'),
      center: center,
      radius: radius,
      fillColor: Colors.deepPurpleAccent.withOpacity(0.2),
      strokeColor: Colors.deepPurpleAccent,
      strokeWidth: 2,
    );

    homeScreenState.addCircle(circle);
  }
}
