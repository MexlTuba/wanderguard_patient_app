import 'package:flutter/material.dart';
import 'package:wanderguard_patient_app/models/companion.model.dart';
import 'package:wanderguard_patient_app/services/firestore_service.dart';
import 'package:wanderguard_patient_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';
import '../models/patient.model.dart';
import '../widgets/backup_companion_card.dart';
import '../widgets/call_companion_button.dart';
import '../widgets/dialogs/waiting_dialog.dart';

class CallCompanionScreen extends StatefulWidget {
  static const route = '/callcompanionscreen';
  static const name = 'CallCompanionScreen';
  const CallCompanionScreen({super.key});

  @override
  _CallCompanionScreenState createState() => _CallCompanionScreenState();
}

class _CallCompanionScreenState extends State<CallCompanionScreen> {
  bool _loadingCompanion = true;
  Companion? _companion;

  @override
  void initState() {
    super.initState();
    _fetchCompanionDetails();
  }

  Future<void> _fetchCompanionDetails() async {
    try {
      print('Fetching companion details...');
      Patient? patient =
          PatientDataController.instance.patientModelNotifier.value;
      if (patient != null) {
        print(
            'Patient found: ${patient.patientAcctId}, fetching companion ID: ${patient.companionAcctId}');
        Companion? companion = await FirestoreService.instance
            .getCompanion(patient.companionAcctId);
        if (companion != null) {
          print(
              'Companion details fetched: ${companion.firstName} ${companion.lastName}');
          setState(() {
            _companion = companion;
            _loadingCompanion = false;
          });
        } else {
          print('No companion found with ID: ${patient.companionAcctId}');
          setState(() {
            _loadingCompanion = false;
          });
        }
      } else {
        print('No patient data available in PatientDataController');
        setState(() {
          _loadingCompanion = false;
        });
      }
    } catch (e) {
      print('Error fetching companion details: $e');
      setState(() {
        _loadingCompanion = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: _loadingCompanion
            ? WaitingDialog(
                prompt: "Loading...", color: CustomColors.primaryColor)
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 50), // Space for status bar
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        _companion?.photoUrl ?? '',
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      '${_companion?.firstName ?? ''} ${_companion?.lastName ?? ''}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      'companion',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Backup Companions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          BackupCompanionCard(
                            name: 'Diwata Mendoza',
                            phoneNumber: '+639081102982',
                            address: '12 orchid street, Capitol site',
                            relationship: 'Nephew',
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/wanderguard-1e83a.appspot.com/o/profile-photos%2FFB_IMG_1708753576727.jpg?alt=media&token=7a057f88-68a8-467e-9444-ce841438eac7',
                          ),
                          BackupCompanionCard(
                            name: 'Maine Mendoza',
                            phoneNumber: '+639081102982',
                            address: '12 orchid street, Capitol site',
                            relationship: 'Niece',
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/wanderguard-1e83a.appspot.com/o/profile-photos%2FFB_IMG_1708753576727.jpg?alt=media&token=7a057f88-68a8-467e-9444-ce841438eac7',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    CallCompanionButton(text: 'Call Companion'),
                  ],
                ),
              ),
      ),
    );
  }
}
