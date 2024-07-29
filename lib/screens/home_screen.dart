import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderguard_patient_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_patient_app/models/patient.model.dart';
import 'package:wanderguard_patient_app/services/location_service.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';
import 'package:wanderguard_patient_app/widgets/map_action_buttons.dart';
import 'package:wanderguard_patient_app/widgets/my_companion_card.dart';
import '../services/information_service.dart';
import '../widgets/contact_companion_button.dart';
import '../widgets/dialogs/waiting_dialog.dart';
import '../controllers/companion_data_controller.dart';
import '../services/firestore_service.dart';
import '../models/companion.model.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  static const name = 'Home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  bool _loadingLocation = true;
  late GoogleMapController _controller;
  late Position _currentPosition;
  final LocationService _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      await _locationService.requestPermission();
      _determinePosition().then((position) {
        setState(() {
          _currentPosition = position;
          _initialPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          );
          _loadingLocation = false;
          // // Start listening to location updates
          // Patient? patient =
          //     PatientDataController.instance.patientModelNotifier.value;
          // if (patient != null) {
          //   _locationService.listenLocation(patient.patientAcctId);
          //   print("Now Tracking Live Location");
          // }
        });
      }).catchError((e) {
        setState(() {
          _loadingLocation = false;
        });
        Info.showSnackbarMessage(context,
            message: e.toString(), label: "Error");
      });
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    }
  }

  Future<Position> _determinePosition() async {
    print('Determining position...');
    return await Geolocator.getCurrentPosition();
  }

  @override
  void dispose() {
    _locationService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingLocation
          ? WaitingDialog(
              prompt: "Loading...",
              color: CustomColors.primaryColor,
            )
          : SafeArea(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: _initialPosition,
                    mapType: MapType.normal,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    padding: EdgeInsets.only(bottom: 250),
                    onMapCreated: (GoogleMapController controller) {
                      _controller = controller;
                      _controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(_currentPosition.latitude,
                                _currentPosition.longitude),
                            zoom: 15,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16.0,
                    left: 16.0,
                    right: 16.0,
                    child: ContactCompanionButton(
                        text: '(LOGOUT)Contact Companion'),
                  ),
                  Positioned(
                      bottom: 80.0,
                      left: 16.0,
                      right: 16.0,
                      child: Column(
                        children: [
                          MapActionButtons(
                            onFirstButtonPressed: () {
                              Info.showSnackbarMessage(context,
                                  message: "First button pressed",
                                  label: "Info");
                            },
                            onSecondButtonPressed: () {
                              Info.showSnackbarMessage(context,
                                  message: "Second button pressed",
                                  label: "Info");
                            },
                            onThirdButtonPressed: () {
                              Info.showSnackbarMessage(context,
                                  message: "Third button pressed",
                                  label: "Info");
                            },
                          ),
                          SizedBox(height: 11),
                          CompanionCard(
                            name: 'Mexl Delver Tuba',
                            phoneNumber: '+639081102982',
                            address: '12 orchid street, Capitol site',
                            relationship: 'Nephew',
                            imageUrl:
                                'https://firebasestorage.googleapis.com/v0/b/wanderguard-1e83a.appspot.com/o/Homeroom.jpg?alt=media&token=9a47fa78-4cdb-433a-9e77-f69e489302d9',
                          ),
                        ],
                      )),
                ],
              ),
            ),
    );
  }
}
