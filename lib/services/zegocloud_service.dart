import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderguard_patient_app/screens/call_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

class ZegoServiceHelper {
  final String patientAcctId;
  final String patientName;
  final GlobalKey<NavigatorState> navigatorKey;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ZegoServiceHelper({
    required this.patientAcctId,
    required this.patientName,
    required this.navigatorKey,
  });

  void initialize() {
    print(
        'Initializing Zego for Patient with ID: $patientAcctId, Name: $patientName');
    ZegoUIKitPrebuiltCallInvitationService().init(
      appID: 629459745,
      appSign:
          '105b0dd752f0765c307a053b512f3ff7e2ebff0d993f4433b803c0854832e596',
      userID: patientAcctId,
      userName: patientName,
      plugins: [ZegoUIKitSignalingPlugin()],
    );

    _listenForIncomingCalls();
  }

  void deinitialize() {
    print('Deinitializing Zego for Patient');
    ZegoUIKitPrebuiltCallInvitationService().uninit();
  }

  void _listenForIncomingCalls() {
    _firestore
        .collection('custom_calls')
        .where('receiverId', isEqualTo: patientAcctId)
        .snapshots()
        .listen((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['status'] == 'calling') {
          _acceptIncomingCall(doc.id, doc['callerId'], doc['callerName']);
        }
      }
    });
  }

  void _acceptIncomingCall(String callId, String callerId, String callerName) {
    _firestore.collection('custom_calls').doc(callId).update({
      'status': 'accepted',
    });

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => CallScreen(
          currentUserId: patientAcctId,
          userId: callerId,
          userName: callerName,
        ),
      ),
    );
  }
}
