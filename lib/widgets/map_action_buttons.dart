import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        _buildActionButton(
            'lib/assets/icons/reminders.svg', onFirstButtonPressed, 60, 16),
        _buildActionButton(
            isPolylineVisible
                ? 'lib/assets/icons/close.svg'
                : 'lib/assets/icons/locate-home.svg',
            onSecondButtonPressed,
            80,
            20),
        _buildActionButton(
            'lib/assets/icons/medicine.svg', onThirdButtonPressed, 60, 14),
      ],
    );
  }

  Widget _buildActionButton(
      String iconPath, VoidCallback onPressed, double size, double padding) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CustomColors.primaryColor,
        ),
        child: SvgPicture.asset(
          iconPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
