import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient.model.dart';

class LocationService {
  StreamSubscription<Position>? positionStream;

  LocationService() {
    print('LocationService initialized');
  }

  Future<void> requestPermission() async {
    print('Requesting permissions...');
    try {
      var locationStatus = await Permission.locationWhenInUse.request();
      print('Foreground location permission status: $locationStatus');

      if (locationStatus.isGranted) {
        var backgroundStatus = await Permission.locationAlways.request();
        print('Background location permission status: $backgroundStatus');

        if (backgroundStatus.isGranted) {
          print('Background location permission granted');
        } else if (backgroundStatus.isDenied) {
          print('Background location permission denied');
        } else if (backgroundStatus.isPermanentlyDenied) {
          print('Background location permission permanently denied');
          openAppSettings();
        }
      } else if (locationStatus.isDenied) {
        print('Foreground location permission denied');
      } else if (locationStatus.isPermanentlyDenied) {
        print('Foreground location permission permanently denied');
        openAppSettings();
      }

      var notificationStatus = await Permission.notification.request();
      print('Notification permission status: $notificationStatus');

      if (notificationStatus.isGranted) {
        print('Notification permission granted');
      } else if (notificationStatus.isDenied) {
        print('Notification permission denied');
      } else if (notificationStatus.isPermanentlyDenied) {
        print('Notification permission permanently denied');
        openAppSettings();
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  Future<void> changeLocationSettings() async {
    print('Changing location settings...');
    try {
      // Check if location permissions are granted
      if (!(await Permission.locationWhenInUse.isGranted) ||
          !(await Permission.locationAlways.isGranted)) {
        print('Location permissions are not granted.');
        return;
      } else {
        print('Location permissions are granted!');
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      print('Location service enabled status: $serviceEnabled');

      if (!serviceEnabled) {
        print('Location services are disabled. Requesting service...');
        await Geolocator.openLocationSettings();
      }
    } catch (e) {
      print('Error changing location settings: $e');
    }
  }

  Future<void> listenLocation(String patientId) async {
    print('Entered listenLocation for patientId: $patientId');
    await changeLocationSettings();

    try {
      print('Setting up location change listener...');
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter:
            1, // VALUE IS IN METERS ADJUST AS NEEDED currently using 1 Meter
      );

      positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          print(
              'Location changed: ${position.latitude}, ${position.longitude}');

          GeoPoint newLocation =
              GeoPoint(position.latitude, position.longitude);

          // Retrieve the patient's document from Firestore
          DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .get();

          if (patientSnapshot.exists) {
            Patient patient = Patient.fromFirestore(
                patientSnapshot as DocumentSnapshot<Map<String, dynamic>>);

            // Check if the patient is within the default geofence
            bool isWithinGeofence =
                patient.defaultGeofence.isWithinGeofence(newLocation);

            await FirebaseFirestore.instance
                .collection('patients')
                .doc(patientId)
                .update({
              'lastLocTracked': newLocation,
              'lastLocUpdated': Timestamp.now(),
              'isWithinGeofence': isWithinGeofence,
            });

            print(
                "Updated Firestore with new location: $newLocation and geofence status: $isWithinGeofence");
          }
        },
        onError: (e) {
          print('Error listening to location changes: $e');
        },
      );
    } catch (e) {
      print('Error in listenLocation: $e');
    }
  }

  void stopListening() {
    print('Stopping location listening...');
    if (positionStream != null) {
      positionStream!.cancel();
      positionStream = null;
      print('Stopped location listening.');
    } else {
      print('No active location listening to stop.');
    }
  }
}
