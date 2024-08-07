// call_patient_button.dart
import 'package:flutter/material.dart';
import 'package:zego_uikit/zego_uikit.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

enum CallType { voiceCall, videoCall }

class CallCompanionButton extends StatelessWidget {
  final String companionAcctId;
  final String companionName;
  final CallType callType;
  final double opacity;

  const CallCompanionButton({
    super.key,
    required this.companionAcctId,
    required this.companionName,
    this.callType = CallType.videoCall,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: ZegoSendCallInvitationButton(
        isVideoCall: callType == CallType.videoCall,
        invitees: [
          ZegoUIKitUser(id: companionAcctId, name: companionName),
        ],
        resourceID: 'wanderguard',
        iconSize: const Size(40, 40), // Default icon size
        buttonSize: const Size(50, 50), // Default button size
        onPressed:
            (String inviterID, String inviterName, List<String> invitees) {
          debugPrint('SendCallButton pressed for patient: $companionAcctId');
        },
      ),
    );
  }
}
