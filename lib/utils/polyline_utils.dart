import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:wanderguard_patient_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_patient_app/models/patient.model.dart';

class PolylineUtils {
  final PolylinePoints polylinePoints = PolylinePoints();

  Future<void> drawPolylineToHome({
    required Position currentPosition,
    required Function(List<LatLng>) onPolylineGenerated,
  }) async {
    Patient? patient =
        PatientDataController.instance.patientModelNotifier.value;
    if (patient != null) {
      List<Location> locations = await locationFromAddress(patient.homeAddress);
      if (locations.isNotEmpty) {
        Location homeLocation = locations.first;
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: 'AIzaSyDOlsE9ugND1vY-T9oR91QyR86Sk_DrksY',
          request: PolylineRequest(
            origin: PointLatLng(
                currentPosition.latitude, currentPosition.longitude),
            destination:
                PointLatLng(homeLocation.latitude, homeLocation.longitude),
            mode: TravelMode.driving,
          ),
        );
        if (result.points.isNotEmpty) {
          List<LatLng> polylineCoordinates = [];
          result.points.forEach((PointLatLng point) {
            polylineCoordinates.add(LatLng(point.latitude, point.longitude));
          });
          onPolylineGenerated(polylineCoordinates);
        } else {
          print('Error: ${result.errorMessage}');
        }
      }
    }
  }
}
