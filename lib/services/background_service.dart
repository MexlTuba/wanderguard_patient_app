import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:wanderguard_patient_app/services/location_service.dart';

Future<void> initializeService() async {
  print('Entered initializeService');
  final service = FlutterBackgroundService();

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'my_foreground', // id
    'MY FOREGROUND SERVICE', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.low,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

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
void onStart(ServiceInstance service) async {
  print('Entered onStart');
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  String? patientId;
  print('Initial patient ID: $patientId');

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
        flutterLocalNotificationsPlugin.show(
          888,
          'WanderGuard Service',
          'Running ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'my_foreground',
              'MY FOREGROUND SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );
      }
    }
  });
}

void startLocationTracking(String patientId) {
  final locationService = LocationService();
  print('Listening to location updates for patient ID: $patientId');
  locationService.listenLocation(patientId);
}
