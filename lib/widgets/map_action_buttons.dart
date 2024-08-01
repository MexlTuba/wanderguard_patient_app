import 'package:flutter/material.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';

class MapActionButtons extends StatelessWidget {
  final VoidCallback onFirstButtonPressed;
  final VoidCallback onSecondButtonPressed;
  final VoidCallback onThirdButtonPressed;
  final bool isPolylineVisible;

  const MapActionButtons({
    Key? key,
    required this.onFirstButtonPressed,
    required this.onSecondButtonPressed,
    required this.onThirdButtonPressed,
    required this.isPolylineVisible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildActionButton(Icons.note, onFirstButtonPressed, 50),
        _buildActionButton(isPolylineVisible ? Icons.clear : Icons.home,
            onSecondButtonPressed, 60),
        _buildActionButton(Icons.medical_services, onThirdButtonPressed, 50),
      ],
    );
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback onPressed, double size) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColors.primaryColor,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: size / 2,
        ),
      ),
    );
  }
}
