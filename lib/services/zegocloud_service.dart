// lib/zego_service_helper.dart
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';
import 'package:flutter/material.dart';

class ZegoServiceHelper {
  final String patientAcctId;
  final String patientName;
  final GlobalKey<NavigatorState> navigatorKey;

  ZegoServiceHelper({
    required this.patientAcctId,
    required this.patientName,
    required this.navigatorKey,
  });

  void initialize() {
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 629459745,
      appSign:
          '105b0dd752f0765c307a053b512f3ff7e2ebff0d993f4433b803c0854832e596',
      userID: patientAcctId,
      userName: patientName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );
  }

  void deinitialize() {
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }
}
