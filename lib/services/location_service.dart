import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final loc.Location location = loc.Location();

  Future<void> requestPermission() async {
    try {
      var locationStatus = await Permission.locationWhenInUse.request();
      if (locationStatus.isGranted) {
        var backgroundStatus = await Permission.locationAlways.request();
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
    try {
      await location.changeSettings(
        interval: 300,
        accuracy: loc.LocationAccuracy.high,
      );
      await location.enableBackgroundMode(enable: true);
    } catch (e) {
      print('Error changing location settings: $e');
    }
  }

  Future<loc.LocationData> getLocation() async {
    try {
      return await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      rethrow;
    }
  }

  Future<void> listenLocation(String patientId) async {
    await changeLocationSettings();
    location.onLocationChanged.handleError((onError) {
      print('Error listening to location changes: $onError');
    }).listen((loc.LocationData currentLocation) async {
      GeoPoint newLocation =
          GeoPoint(currentLocation.latitude!, currentLocation.longitude!);
      await FirebaseFirestore.instance
          .collection('patients')
          .doc(patientId)
          .update({
        'lastLocTracked': newLocation,
        'lastLocUpdated': Timestamp.now(),
      });
      print("Now Tracking Live Location: $newLocation");
    });
  }

  void stopListening() {
    location.onLocationChanged.listen((_) {}).cancel();
  }
}
