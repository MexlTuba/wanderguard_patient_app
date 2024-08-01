import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';

void showLoadingDialog(BuildContext context, {required String message}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SpinKitRipple(
                color: CustomColors.primaryColor,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: CustomColors.primaryColor),
              ),
            ],
          ),
        ),
      );
    },
  );
}

void hideLoadingDialog(BuildContext context) {
  Navigator.of(context).pop();
}
