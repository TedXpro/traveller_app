// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   late GoogleMapController mapController;
//   final LatLng _center = const LatLng(9.02497, 38.74689); // Addis Ababa
//   final Set<Marker> _markers = {};
//   LatLng? driverLocation;
//   Timer? _timer;
//   double latitudeOffset = 0.001;
//   double longitudeOffset = 0.001;

//   @override
//   void initState() {
//     super.initState();
//     _startSimulation();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   void _startSimulation() {
//     driverLocation = _center;
//     _updateDriverMarker();

//     _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
//       setState(() {
//         driverLocation = LatLng(
//           driverLocation!.latitude + latitudeOffset,
//           driverLocation!.longitude + longitudeOffset,
//         );
//         _updateDriverMarker();
//       });

//       // Simple logic to change direction
//       if (driverLocation!.latitude > _center.latitude + 0.01 ||
//           driverLocation!.latitude < _center.latitude - 0.01) {
//         latitudeOffset = -latitudeOffset;
//       }
//       if (driverLocation!.longitude > _center.longitude + 0.01 ||
//           driverLocation!.longitude < _center.longitude - 0.01) {
//         longitudeOffset = -longitudeOffset;
//       }
//     });
//   }

//   void _updateDriverMarker() {
//     if (driverLocation != null) {
//       _markers.clear();
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('driver'),
//           position: driverLocation!,
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         ),
//       );
//       mapController.animateCamera(CameraUpdate.newLatLng(driverLocation!));
//         }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Simulated Driver Tracking')),
//       body: GoogleMap(
//         onMapCreated: _onMapCreated,
//         initialCameraPosition: CameraPosition(target: _center, zoom: 13.0),
//         markers: _markers,
//       ),
//     );
//   }
// }


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(9.02497, 38.74689); // Addis Ababa
  final Set<Marker> _markers = {};
  late StreamSubscription<Position> _positionStream;
  late WebSocketChannel _channel;
  LatLng? driverLocation;
  LatLng? myLocation; // To store the user's location

  @override
  void initState() {
    super.initState();
    _initLocation();
    _connectWebSocket();
  }

  @override
  void dispose() {
    _positionStream.cancel();
    _channel.sink.close();
    super.dispose();
  }

  Future<void> _initLocation() async {
    // ... (Your existing location initialization code)
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    _positionStream = Geolocator.getPositionStream().listen((
      Position position,
    ) {
      _sendLocation(position);
    });
  }

  void _sendLocation(Position position) {
    // Send location data to your backend via WebSocket
    _channel.sink.add(
      '${position.latitude},${position.longitude}',
    ); // Send as a string
  }

  void _connectWebSocket() {
    // Replace with your WebSocket server URL
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://your-backend-websocket-url'),
    );

    _channel.stream.listen((message) {
      // Receive location updates from the backend
      final parts = message.toString().split(',');
      if (parts.length == 2) {
        setState(() {
          driverLocation = LatLng(
            double.parse(parts[0]),
            double.parse(parts[1]),
          );
          _updateDriverMarker();
        });
      }
    });
  }

  void _updateDriverMarker() {
    if (driverLocation != null) {
      _markers.clear();
      _markers.add(
        Marker(
          markerId: const MarkerId('driver'),
          position: driverLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
      if (mapController != null) {
        mapController.animateCamera(CameraUpdate.newLatLng(driverLocation!));
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _goToMyLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      myLocation = LatLng(position.latitude, position.longitude);

      mapController.animateCamera(CameraUpdate.newLatLng(myLocation!));

      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('myLocation'),
            position: myLocation!,
            infoWindow: const InfoWindow(title: 'My Location'),
          ),
        );
      });
    } catch (e) {
      print('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not get your location.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps Tracking')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 11.0),
        markers: _markers,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
