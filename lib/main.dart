import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/companion_data_controller.dart';
import 'controllers/patient_data_controller.dart';
import 'firebase_options.dart';
import 'routing/router.dart';
import 'services/background_service.dart';
import 'services/firestore_service.dart';
import 'services/location_service.dart';
import 'utils/size_config.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  AuthController.initialize();
  GlobalRouter
      .initialize(); // Correctly initializing without passing parameters
  PatientDataController.initialize();
  CompanionDataController.initialize();
  FirestoreService.initialize();
  await AuthController.instance.loadSession();
  await LocationService().requestPermission();
  await initializeService();

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(
      GlobalRouter.navigatorKey); // Accessing static navigatorKey

  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => PatientDataController.instance),
          // Add other providers if necessary
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return MaterialApp.router(
      routerConfig: GlobalRouter.I.router,
      debugShowCheckedModeBanner: false,
      title: 'WanderGuard Patient App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
      ),
    );
  }
}
