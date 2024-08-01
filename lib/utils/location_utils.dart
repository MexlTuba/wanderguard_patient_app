import 'package:geolocator/geolocator.dart';

Future<Position> determinePosition() async {
  print('Determining position...');
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}
