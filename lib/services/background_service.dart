import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderguard_patient_app/services/location_service.dart';

import '../utils/colors.dart';

Future<void> initializeService() async {
  print('Entered initializeService');
  final service = FlutterBackgroundService();

  await AwesomeNotifications().initialize(
    'resource://drawable/logo_purple',
    [
      NotificationChannel(
        channelGroupKey: 'my_foreground_group',
        channelKey: 'my_foreground',
        channelName: 'MY FOREGROUND SERVICE',
        channelDescription: 'This channel is used for important notifications.',
        defaultColor: CustomColors.primaryColor,
        ledColor: Colors.white,
        importance: NotificationImportance.Low,
        locked: true,
      ),
      NotificationChannel(
        channelGroupKey: 'geofence_alert_group',
        channelKey: 'geofence_alerts',
        channelName: 'Geofence Alerts',
        channelDescription:
            'This channel is used for geofence alert notifications.',
        defaultColor: CustomColors.primaryColor,
        ledColor: Colors.white,
        vibrationPattern: highVibrationPattern,
        importance: NotificationImportance.High,
        playSound: true,
        enableVibration: true,
      ),
    ],
    debug: true,
  );

  AwesomeNotifications().setListeners(
    onNotificationCreatedMethod: onNotificationCreatedMethod,
    onNotificationDisplayedMethod: onNotificationDisplayedMethod,
    onDismissActionReceivedMethod: onDismissActionReceivedMethod,
    onActionReceivedMethod: onActionReceivedMethod,
  );

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: 'my_foreground',
      initialNotificationTitle: 'WanderGuard Service',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 888,
    ),
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
Future<void> onStart(ServiceInstance service) async {
  print('Entered onStart');
  createPersistentNotification();
  print('Persistent notification created');
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  String? patientId;
  print('Initial patient ID: $patientId');

  // Retrieve patient ID from shared preferences
  final prefs = await SharedPreferences.getInstance();
  patientId = prefs.getString('patientAcctId');
  if (patientId != null) {
    print('Retrieved patient ID from shared preferences: $patientId');
    startLocationTracking(patientId);
  }

  service.on('setPatientId').listen((event) {
    patientId = event?['patientId'];
    print('Final Patient ID set to: $patientId');
    if (patientId != null) {
      startLocationTracking(patientId!);
    }
  });

  service.on("stopService").listen((event) {
    service.stopSelf();
    print("background process is now stopped");
  });

  Timer.periodic(const Duration(seconds: 1), (timer) async {
    print('Timer running...');
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        createPersistentNotification();
      }
    }
  });
}

void startLocationTracking(String patientId) {
  final locationService = LocationService();
  print('Listening to location updates for patient ID: $patientId');
  locationService.listenLocation(patientId);
}

@pragma('vm:entry-point')
Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification) async {
  // Handle notification creation
}

@pragma('vm:entry-point')
Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification) async {
  // Handle notification display
}

@pragma('vm:entry-point')
Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction) async {
  // Handle notification dismissal
  if (receivedAction.id == 999) {
    // This was the geofence alert notification
    print('Geofence alert notification dismissed');
  }
  if (receivedAction.id == 888) {
    // This was the persistent notification
    print('Persistent notification dismissed');
    createPersistentNotification();
  }
}

@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction receivedAction) async {
  // Handle notification action
}

void createPersistentNotification() {
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: 888,
      channelKey: 'my_foreground',
      title: 'WanderGuard Service',
      body: 'Running ${DateTime.now()}',
      notificationLayout: NotificationLayout.Default,
      icon: 'resource://drawable/logo_purple',
      autoDismissible: false,
    ),
  );
}
