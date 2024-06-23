import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

Future<Position> _determinePosition(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    _showLocationServicesDisabledDialog(context);
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      _showPermissionDeniedDialog(context);
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    _showPermissionDeniedForeverDialog(context);
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}

void _showLocationServicesDisabledDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location Services Disabled'),
      content: const Text('Please enable location services.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showPermissionDeniedDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location Permissions Denied'),
      content:
          const Text('Please grant location permissions to use this feature.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

void _showPermissionDeniedForeverDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Location Permissions Denied Forever'),
      content: const Text(
          'Location permissions are permanently denied. Please enable them in the app settings.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Open Settings'),
        ),
      ],
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              Position position = await _determinePosition(context);
              print(
                  'Latitud: ${position.latitude}, Longitud: ${position.longitude}');
            } catch (e) {
              print(e);
            }
          },
          child: const Text('Get coordinates'),
        ),
      ),
    );
  }
}
