import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_patient_app/screens/auth/login_screen.dart';
import 'package:wanderguard_patient_app/screens/call_companion_screen.dart';
import 'package:wanderguard_patient_app/screens/home_screen.dart';
import 'package:wanderguard_patient_app/screens/loading_screen.dart';
import 'package:wanderguard_patient_app/services/zegocloud_service.dart'; // Import Zego service
import '../controllers/auth_controller.dart';
import '../controllers/patient_data_controller.dart';
import '../enum/auth_state.enum.dart';

class GlobalRouter {
  late final GoRouter router;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  GlobalRouter() {
    router = GoRouter(
      navigatorKey: navigatorKey,
      initialLocation: LoginScreen.route,
      redirect: handleRedirect,
      refreshListenable: AuthController.instance,
      routes: [
        GoRoute(
          path: LoginScreen.route,
          name: LoginScreen.name,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: HomeScreen.route,
          name: HomeScreen.name,
          builder: (context, state) {
            final patient =
                PatientDataController.instance.patientModelNotifier.value;
            if (patient != null) {
              ZegoServiceHelper zegoServiceHelper = ZegoServiceHelper(
                patientAcctId: patient.patientAcctId,
                patientName: '${patient.firstName} ${patient.lastName}',
                navigatorKey: navigatorKey,
              );
              zegoServiceHelper.initialize();
            }
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: CallCompanionScreen.route,
          name: CallCompanionScreen.name,
          builder: (context, state) => const CallCompanionScreen(),
        ),
        GoRoute(
          path: LoadingScreen.route,
          name: LoadingScreen.name,
          builder: (context, state) => const LoadingScreen(),
        ),
      ],
    );
  }

  FutureOr<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    if (AuthController.instance.state == AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return HomeScreen.route;
      }
      return null;
    } else {
      if (state.matchedLocation != LoginScreen.route) {
        return LoginScreen.route;
      }
      return null;
    }
  }

  static void initialize() {
    GetIt.instance.registerSingleton<GlobalRouter>(GlobalRouter());
  }

  static GlobalRouter get I => GetIt.instance.get<GlobalRouter>();
}
