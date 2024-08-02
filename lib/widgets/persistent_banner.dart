import 'package:flutter/material.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';

class PersistentBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const PersistentBanner({
    Key? key,
    required this.message,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
        color: Colors.red.withOpacity(0.9),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ALERT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
