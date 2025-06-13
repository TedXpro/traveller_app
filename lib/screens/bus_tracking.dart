import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:traveller_app/constants/api_constants.dart';
import 'package:traveller_app/services/travel_api_service.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class BusTrackingPage extends StatefulWidget {
  final String travelId;
  final String jwtToken;

  const BusTrackingPage({super.key, required this.travelId, required this.jwtToken});

  @override
  State<BusTrackingPage> createState() => _BusTrackingPageState();
}

class _BusTrackingPageState extends State<BusTrackingPage> {
  late WebSocketChannel channel;
  LatLng? currentPosition;
  String _busId = "";

  @override
  void initState() {
    super.initState();
    initStateAsync();
    print(widget.jwtToken);
    // channel = WebSocketChannel.connect(
    //   Uri.parse('ws://$baseUrl/ws'), // Change this
    // );

    // authorization header should be set
    channel = IOWebSocketChannel.connect(
      Uri.parse('wss://$BASE_URL_TRAILING/ws'),
      headers: {
        'Authorization': 'Bearer ${widget.jwtToken}', // Replace with your auth token
      },
    );

    channel.stream.listen((message) {
      final data = jsonDecode(message);
      if (data['bus_id'] == _busId) {
        setState(() {
          currentPosition = LatLng(data['latitude'], data['longitude']);
        });
      }
    });
  }

  void initStateAsync() async{
    var travel = await getTravelByIdApi(widget.travelId);
    setState(() {
      _busId = travel.busRef!;
    });
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Bus Tracking')),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: currentPosition!,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPosition!,
                      width: 50,
                      height: 50,
                      child: const Icon(
                        Icons.directions_bus,
                        size: 40,
                        color: Colors.blueAccent,
                      ),
                    )
                  ],
                ),
              ],
            ),
    );
  }
}
