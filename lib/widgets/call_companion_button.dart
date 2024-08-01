import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wanderguard_patient_app/controllers/auth_controller.dart';
import 'package:wanderguard_patient_app/screens/call_companion_screen.dart';
import 'package:wanderguard_patient_app/services/information_service.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';

class CallCompanionButton extends StatelessWidget {
  final String text;

  const CallCompanionButton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: CustomColors.primaryColor,
        minimumSize: Size(
            MediaQuery.of(context).size.width, 60), // Increase the height to 60
      ),
      clipBehavior: Clip.hardEdge,
      onPressed: () {
        Info.showSnackbarMessage(context,
            message: "Call Companion Button Pressed", label: "Info");
      },
      child: Text(
        text,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
