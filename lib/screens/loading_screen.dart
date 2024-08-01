import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';

class LoadingScreen extends StatelessWidget {
  static const route = '/loading';
  static const name = 'LoadingScreen';

  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('LoadingScreen: Building...');
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SpinKitRipple(
              color: CustomColors.primaryColor,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              "Processing...",
              style: TextStyle(color: CustomColors.primaryColor, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
