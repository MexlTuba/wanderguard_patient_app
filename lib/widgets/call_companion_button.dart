import 'package:flutter/material.dart';
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
        minimumSize: Size(MediaQuery.of(context).size.width, 60),
      ),
      clipBehavior: Clip.hardEdge,
      onPressed: () {
        Info.showSnackbarMessage(context,
            message: "Call Companion Button Pressed", label: "Info");
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
          SizedBox(width: 8),
          Icon(Icons.phone, color: Colors.white),
        ],
      ),
    );
  }
}
