import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/models/agency.dart';
import 'package:traveller_app/services/agency_api_services.dart';

class TravelDetailsPage extends StatefulWidget {
  // Change to StatefulWidget
  final Travel travel;

  const TravelDetailsPage({super.key, required this.travel});

  @override
  _TravelDetailsPageState createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  String agencyName = 'Loading...';
  final AgencyServices _agencyServices = AgencyServices();
  Map<String, Agency> _agencyCache = {}; // Cache agencies

  @override
  void initState() {
    super.initState();
    _fetchAgencyName();
  }

  Future<void> _fetchAgencyName() async {
    if (_agencyCache.containsKey(widget.travel.agencyId)) {
      setState(() {
        agencyName = _agencyCache[widget.travel.agencyId]!.name;
      });
      return;
    }

    try {
      Agency? agency = await _agencyServices.fetchAgencyApi(
        widget.travel.agencyId,
      );
      if (agency != null) {
        setState(() {
          agencyName = agency.name;
          _agencyCache[widget.travel.agencyId] = agency; // Cache agency
        });
      } else {
        setState(() {
          agencyName = 'Agency Not Found';
        });
      }
    } catch (e) {
      print('Error fetching agency: $e');
      setState(() {
        agencyName = 'Error Loading Agency';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Agency: $agencyName', // Use fetched agency name
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      'Start Location',
                      widget.travel.startLocation,
                    ),
                    _buildDetailRow('Destination', widget.travel.destination),
                    _buildDetailRow(
                      'Price',
                      '\$${widget.travel.price.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow(
                      'Departure',
                      DateFormat(
                        'MMM d, yyyy HH:mm',
                      ).format(widget.travel.plannedStartTime),
                    ),
                    _buildDetailRow(
                      'Arrival',
                      widget.travel.estArrivalTime != null
                          ? DateFormat(
                            'MMM d, yyyy HH:mm',
                          ).format(widget.travel.estArrivalTime!)
                          : 'Not Available',
                    ),
                    _buildDetailRow(
                      'Driver',
                      widget.travel.driverName ?? 'Not Assigned',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement booking logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Book Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
