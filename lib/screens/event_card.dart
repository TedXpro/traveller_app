import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/screens/book.dart';
import 'package:traveller_app/services/destination_api_services.dart';
import 'package:traveller_app/services/travel_api_service.dart';

class EventCard extends StatefulWidget {
  final String title;
  final String location;
  final String date;
  final String? imageUrl;
  final String? description;

  const EventCard({
    super.key,
    required this.title,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.description,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isExpanded = false;
  Destination? destination;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    // Simulate fetching destination data
    // In a real app, you would fetch this from an API or database
    destination = await fetchDestinationByIdApi(widget.location);
    setState(() {
      destination = destination;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'yyyy-MM-dd',
    ).format(DateTime.parse(widget.date));
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(formattedDate, style: TextStyle(fontSize: 12)),
                ),
              ],
            ),

            SizedBox(height: 6),

            // Location
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                destination == null ? "Loading Location" : destination!.name,
                style: TextStyle(fontSize: 12),
              ),
            ),

            SizedBox(height: 10),

            // Photo
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                widget.imageUrl == null ? "Event" : widget.imageUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[300],
                      child: Center(child: Text('Photo')),
                    ),
              ),
            ),

            SizedBox(height: 10),

            // Description
            Text(
              widget.description == null
                  ? "Description unavailable"
                  : widget.description!,
              maxLines: isExpanded ? null : 2,
              overflow:
                  isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),

            SizedBox(height: 10),

            // Book Now and Read More buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Book Now button
                ElevatedButton(
                  onPressed: () async{
                    String to = destination!.name;
                    String from = "";
                    // DateTime? dateMin = "";
                    DateTime? dateMax = DateTime.parse(widget.date);
                    List<Travel> travels = await searchTravelsApi(from, to, null, dateMax);
                    print(travels);
                    if (travels.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('No travels found for this event')),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookPage(travels: travels),
                      ),
                    );
                    // Handle booking logic
                    // ScaffoldMessenger.of(context).showSnackBar(
                    //   SnackBar(content: Text('Booking feature coming soon!')),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                    foregroundColor: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('Book Now'),
                ),

                // Read More / Read Less button
                TextButton(
                  onPressed: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Text(isExpanded ? 'Read less' : 'Read more'),
                ),
              ],
            ),

          ],
        ),
      ),
    );
  }
}
