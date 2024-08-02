import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../models/patient.model.dart';

class LocationService {
  StreamSubscription<Position>? positionStream;
  Function(bool)? onGeofenceStatusChanged;

  LocationService({this.onGeofenceStatusChanged}) {
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
    await changeLocationSettings();

    try {
      LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 1,
      );

      positionStream = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) async {
          GeoPoint newLocation =
              GeoPoint(position.latitude, position.longitude);

          DocumentSnapshot patientSnapshot = await FirebaseFirestore.instance
              .collection('patients')
              .doc(patientId)
              .get();

          if (patientSnapshot.exists) {
            Patient patient = Patient.fromFirestore(
                patientSnapshot as DocumentSnapshot<Map<String, dynamic>>);

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

            if (onGeofenceStatusChanged != null) {
              onGeofenceStatusChanged!(isWithinGeofence);
            }

            print(
                "Updated Firestore with new location: $newLocation and geofence status: $isWithinGeofence");

            if (!isWithinGeofence) {
              // Trigger the notification with vibration
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: 999,
                  channelKey: 'geofence_alerts',
                  title: 'Alert',
                  body: 'Left safe zone, please return now',
                  notificationLayout: NotificationLayout.Default,
                  autoDismissible: false,
                ),
                actionButtons: [
                  NotificationActionButton(
                    key: 'DISMISS',
                    label: 'Dismiss',
                    actionType: ActionType.DismissAction,
                  ),
                ],
              );
            }
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
