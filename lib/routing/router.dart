import "dart:async";
import "package:flutter/material.dart";
import "package:get_it/get_it.dart";
import "package:go_router/go_router.dart";
import "package:wanderguard_patient_app/screens/call_companion_screen.dart";
import "../controllers/auth_controller.dart";
import "../enum/auth_state.enum.dart";
import "../screens/auth/login_screen.dart";
import "../screens/home_screen.dart";

class GlobalRouter {
  static void initialize() {
    GetIt.instance.registerSingleton<GlobalRouter>(GlobalRouter());
  }

  static GlobalRouter get I => GetIt.instance<GlobalRouter>();

  late GoRouter router;
  late GlobalKey<NavigatorState> _rootNavigatorKey;
  late GlobalKey<NavigatorState> _shellNavigatorKey;

  FutureOr<String?> handleRedirect(
      BuildContext context, GoRouterState state) async {
    if (AuthController.instance.state == AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return HomeScreen.route;
      }
      return null;
    }
    if (AuthController.instance.state != AuthState.authenticated) {
      if (state.matchedLocation == LoginScreen.route) {
        return null;
      }
      return LoginScreen.route;
    }
    return null;
  }

  GlobalRouter() {
    _rootNavigatorKey = GlobalKey<NavigatorState>();
    _shellNavigatorKey = GlobalKey<NavigatorState>();
    router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: LoginScreen.route,
      redirect: handleRedirect,
      refreshListenable: AuthController.instance,
      routes: [
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: LoginScreen.route,
          name: LoginScreen.name,
          builder: (context, _) {
            return const LoginScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: HomeScreen.route,
          name: HomeScreen.name,
          builder: (context, _) {
            return HomeScreen();
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: CallCompanionScreen.route,
          name: CallCompanionScreen.name,
          builder: (context, _) {
            return CallCompanionScreen();
          },
        ),
      ],
    );
  }
}
