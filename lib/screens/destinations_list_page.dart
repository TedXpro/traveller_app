// lib/screens/destinations_list_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/destination.dart'; // Assuming you have a Destination model
import 'package:traveller_app/services/destination_api_services.dart'; // Import your DestinationService
import 'package:traveller_app/screens/destination_details_page.dart'; // Import the DestinationDetailsPage
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
// Import any other necessary packages

class DestinationsListPage extends StatefulWidget {
  const DestinationsListPage({super.key});

  @override
  _DestinationsListPageState createState() => _DestinationsListPageState();
}

class _DestinationsListPageState extends State<DestinationsListPage> {
  late Future<List<Destination>> _destinationsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching the list of destinations when the widget is created
    _destinationsFuture = _fetchAllDestinations();
  }

  // Method to fetch all destinations using the service
  Future<List<Destination>> _fetchAllDestinations() async {
    final destinationService =
        DestinationService(); // Create an instance of your service

    return await destinationService.fetchAllDestinations(
      // jwtToken, // Pass token if needed
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Access localization

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.destinationsTitle), // Localize title
        // Optional: Add a refresh button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _destinationsFuture =
                    _fetchAllDestinations(); // Refresh the list
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Destination>>(
        future: _destinationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if fetching failed
            print(
              'Error fetching destinations: ${snapshot.error}',
            ); // Log the error
            return Center(
              child: Text(
                l10n.failedToLoadDestinations(snapshot.error.toString()),
              ), // Localize error message
            );
          } else if (snapshot.hasData &&
              snapshot.data != null &&
              snapshot.data!.isNotEmpty) {
            // Data is loaded successfully and the list is not empty, display the grid
            final destinations = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(8.0), // Add padding around the grid
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 items per row
                  crossAxisSpacing: 8.0, // Horizontal spacing between items
                  mainAxisSpacing: 8.0, // Vertical spacing between items
                  childAspectRatio:
                      1.0, // Adjust aspect ratio for a more square card since there's no image
                ),
                itemCount: destinations.length,
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return GestureDetector(
                    // Make the card tappable
                    onTap: () {
                      print('Tapped on destination: ${destination.name}');
                      // Navigate to the DestinationDetailsPage, passing the ID and Name
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => DestinationDetailsPage(
                                destinationId:
                                    destination.id.toString(), // Pass the destination ID
                                destinationName:
                                    destination
                                        .name, // Pass the destination name
                              ),
                        ),
                      );
                    },
                    child: Card(
                      // Use a Card for a visually distinct item
                      elevation: 4.0, // Add shadow
                      shape: RoundedRectangleBorder(
                        // Rounded corners
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      clipBehavior:
                          Clip.antiAlias, // Clip content to rounded corners
                      child: Center(
                        // Center the text within the card
                        child: Padding(
                          padding: const EdgeInsets.all(
                            8.0,
                          ), // Padding for text
                          child: Text(
                            destination.name, // Display destination name
                            textAlign: TextAlign.center, // Center the text
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2, // Allow name to wrap if needed
                            overflow:
                                TextOverflow
                                    .ellipsis, // Add ellipsis if name is too long
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            // Handle the case where data is loaded but the list is empty
            return Center(
              child: Text(l10n.noDestinationsFound), // Localize empty message
            );
          }
        },
      ),
    );
  }
}

// TODO: Ensure you have a Destination model class with 'id' and 'name' fields.
// TODO: Ensure your DestinationService has a fetchAllDestinations method that returns Future<List<Destination>>.
// TODO: Ensure DestinationDetailsPage exists and accepts destinationId and destinationName.
// TODO: Add localization strings for 'destinationsTitle', 'failedToLoadDestinations', 'noDestinationsFound'.
