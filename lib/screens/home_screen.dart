import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wanderguard_patient_app/controllers/patient_data_controller.dart';
import 'package:wanderguard_patient_app/models/companion.model.dart';
import 'package:wanderguard_patient_app/services/location_service.dart';
import 'package:wanderguard_patient_app/utils/colors.dart';
import 'package:wanderguard_patient_app/widgets/map_action_buttons.dart';
import 'package:wanderguard_patient_app/widgets/my_companion_card.dart';
import 'package:wanderguard_patient_app/widgets/contact_companion_button.dart';
import 'package:wanderguard_patient_app/widgets/dialogs/waiting_dialog.dart';
import 'package:wanderguard_patient_app/controllers/auth_controller.dart';
import 'package:wanderguard_patient_app/services/firestore_service.dart';
import 'package:wanderguard_patient_app/services/information_service.dart';
import '../models/geofence.model.dart';
import '../models/patient.model.dart';
import '../utils/custom_marker_generator.dart';
import '../utils/location_utils.dart';
import '../utils/dialog_utils.dart';
import '../utils/polyline_utils.dart';
import '../utils/geofence_utils.dart';

class HomeScreen extends StatefulWidget {
  static const route = '/home';
  static const name = 'Home';

  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(0, 0),
    zoom: 2,
  );
  bool _loadingLocation = true;
  bool _loadingCompanion = true;
  bool _polylineVisible = false;
  late GoogleMapController _controller;
  late Position _currentPosition;
  final LocationService _locationService = LocationService();
  Companion? _companion;
  List<LatLng> _polylineCoordinates = [];
  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  final PolylineUtils _polylineUtils = PolylineUtils();

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _triggerLocationTracking();
    _fetchCompanionDetails();
  }

  Future<void> _triggerLocationTracking() async {
    final service = FlutterBackgroundService();
    final prefs = await SharedPreferences.getInstance();
    String? patientAcctId = prefs.getString('patientAcctId');
    if (patientAcctId != null) {
      print('Triggering location tracking for patient ID: $patientAcctId');
      service.invoke('setPatientId', {'patientId': patientAcctId});
    } else {
      print('No patient account ID found in SharedPreferences');
    }
  }

  Future<void> _initializeLocation() async {
    try {
      print('Initializing location...');
      determinePosition().then((position) {
        setState(() {
          _currentPosition = position;
          _initialPosition = CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15,
          );
          _loadingLocation = false;
          print('Current position: $_currentPosition');
          // Start listening to location updates
          Patient? patient =
              PatientDataController.instance.patientModelNotifier.value;
          if (patient != null) {
            print(
                'Starting to listen to location updates for patient ID: ${patient.patientAcctId}');
            _locationService.listenLocation(patient.patientAcctId);
            print("Now Tracking Live Location");
            // Draw geofences
            _drawGeofences(patient);
            // Add home marker
            _addHomeMarker(patient);
          } else {
            print('No patient found in PatientDataController');
          }
        });
      }).catchError((e) {
        print('Error determining position: $e');
        setState(() {
          _loadingLocation = false;
        });
        Info.showSnackbarMessage(context,
            message: e.toString(), label: "Error");
      });
    } catch (e) {
      print('Error initializing location: $e');
      setState(() {
        _loadingLocation = false;
      });
      Info.showSnackbarMessage(context, message: e.toString(), label: "Error");
    }
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
      Info.showSnackbarMessage(context,
          message: 'Failed to fetch companion details', label: "Error");
    }
  }

  Future<void> _togglePolylineToHome() async {
    if (_polylineVisible) {
      setState(() {
        _polylineCoordinates.clear();
        _polylineVisible = false;
      });
    } else {
      showLoadingDialog(context, message: "Locating Home...");
      await _polylineUtils.drawPolylineToHome(
        currentPosition: _currentPosition,
        onPolylineGenerated: (polylineCoordinates) {
          setState(() {
            _polylineCoordinates = polylineCoordinates;
            _polylineVisible = true;
          });
        },
      );
      hideLoadingDialog(context);
    }
  }

  void _drawGeofences(Patient patient) {
    drawGeofence(this, patient.defaultGeofence);
    for (Geofence geofence in patient.geofences) {
      drawGeofence(this, geofence);
    }
  }

  void _addHomeMarker(Patient patient) async {
    List<Location> locations = await locationFromAddress(patient.homeAddress);
    if (locations.isNotEmpty) {
      Location homeLocation = locations.first;
      BitmapDescriptor homeIcon = await createCustomMarker(
          'lib/assets/images/home-icon.png',
          isNetwork: false);
      final Marker homeMarker = Marker(
        markerId: MarkerId('home_marker'),
        position: LatLng(homeLocation.latitude, homeLocation.longitude),
        icon: homeIcon,
        infoWindow: InfoWindow(title: 'Home'),
      );

      setState(() {
        _markers.add(homeMarker);
      });
    }
  }

  void addCircle(Circle circle) {
    setState(() {
      _circles.add(circle);
    });
  }

  @override
  void dispose() {
    _locationService.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingLocation || _loadingCompanion
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
                    polylines: {
                      Polyline(
                        polylineId: PolylineId('poly'),
                        color: Colors.blue,
                        points: _polylineCoordinates,
                      ),
                    },
                    circles: _circles,
                    markers: _markers,
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
                    child: ContactCompanionButton(text: 'Contact Companion'),
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
                              _togglePolylineToHome();
                            },
                            onThirdButtonPressed: () {
                              AuthController.instance.logout();
                            },
                            isPolylineVisible: _polylineVisible,
                          ),
                          SizedBox(height: 11),
                          _companion != null
                              ? CompanionCard(
                                  name:
                                      '${_companion!.firstName} ${_companion!.lastName}',
                                  phoneNumber: _companion!.contactNo,
                                  address: _companion!.address,
                                  relationship: 'Companion',
                                  imageUrl: _companion!.photoUrl,
                                )
                              : Text('No companion data available'),
                        ],
                      )),
                ],
              ),
            ),
    );
  }
}
