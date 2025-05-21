// lib/screens/destination_details_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/services/destination_api_services.dart'; // Import DestinationService
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
// You might need url_launcher for opening map links
// import 'package:url_launcher/url_launcher.dart';

class DestinationDetailsPage extends StatefulWidget {
  // Accept the destination ID as a required argument
  final String destinationId;
  // Optionally accept the destination name to display in the app bar quickly
  final String? destinationName;

  const DestinationDetailsPage({
    super.key,
    required this.destinationId,
    this.destinationName, // Optional: Pass name from list screen
  });

  @override
  _DestinationDetailsPageState createState() => _DestinationDetailsPageState();
}

class _DestinationDetailsPageState extends State<DestinationDetailsPage> {
  late Future<DestinationDetails?> _destinationDetailsFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching destination details when the widget is created
    _destinationDetailsFuture = _fetchDestinationDetails();
  }

  // Method to fetch destination details using the service
  Future<DestinationDetails?> _fetchDestinationDetails() async {
    final destinationService =
        DestinationService(); // Create an instance of your service
    // You might need to pass the JWT token if your backend requires authentication
    // final userProvider = Provider.of<UserProvider>(context, listen: false); // Example if using Provider for token
    // final jwtToken = userProvider.jwtToken; // Get token if needed

    return await destinationService.getDestinationDetailsById(
      widget.destinationId,
      // jwtToken, // Pass token if needed
    );
  }

  // Helper function to launch URLs (e.g., map links)
  // Future<void> _launchUrl(String urlString) async {
  //   final Uri url = Uri.parse(urlString);
  //   if (!await launchUrl(url)) {
  //     // Handle error launching URL (e.g., show a SnackBar)
  //     print('Could not launch $url');
  //     if (mounted) {
  //        ScaffoldMessenger.of(context).showSnackBar(
  //           SnackBar(content: Text(AppLocalizations.of(context)!.failedToOpenLink)), // Localize
  //           backgroundColor: Colors.red,
  //        );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Access localization

    return Scaffold(
      // No AppBar here, as we're using SliverAppBar in CustomScrollView
      body: FutureBuilder<DestinationDetails?>(
        future: _destinationDetailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while fetching data
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Show an error message if fetching failed
            print(
              'Error fetching destination details: ${snapshot.error}',
            ); // Log the error
            return Center(
              child: Text(
                l10n.failedToLoadDestinationDetails(snapshot.error.toString()),
              ), // Localize error message
            );
          } else if (snapshot.hasData && snapshot.data != null) {
            // Data is loaded successfully, display the details
            final destinationDetails = snapshot.data!;

            return CustomScrollView(
              slivers: [
                // SliverAppBar for the main image
                SliverAppBar(
                  expandedHeight:
                      250.0, // Height of the app bar when fully expanded
                  floating: false, // App bar stays at the top
                  pinned: true, // App bar is visible even when scrolled up
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      // Use the passed name or a default/fetched name
                      widget.destinationName ??
                          destinationDetails
                              .destinationId.toString(), // Assuming DestinationID is a fallback
                      style: const TextStyle(
                        color: Colors.white, // Text color for title
                        shadows: [
                          // Add shadow for better readability on image
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black,
                            offset: Offset(2.0, 2.0),
                          ),
                        ],
                      ),
                    ),
                    background:
                        destinationDetails.image != null &&
                                destinationDetails.image!.isNotEmpty
                            ? Image.network(
                              destinationDetails.image!,
                              fit:
                                  BoxFit
                                      .cover, // Cover the entire background area
                              errorBuilder: (context, error, stackTrace) {
                                // Handle image loading errors
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              color: Colors.grey[200],
                            ), // Placeholder if no image
                  ),
                ),

                // SliverToBoxAdapter to hold the scrollable content below the app bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Display Description
                        Text(
                          destinationDetails.description ??
                              l10n.noDescriptionAvailable, // Localize fallback
                          style: const TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 24.0), // Increased spacing
                        // Display Culture (if available)
                        if (destinationDetails.culture != null &&
                            destinationDetails.culture!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.cultureTitle,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), // Localize
                              const SizedBox(height: 8.0),
                              Text(
                                destinationDetails.culture!,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 24.0),
                            ],
                          ),

                        // Display History (if available)
                        if (destinationDetails.history != null &&
                            destinationDetails.history!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.historyTitle,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), // Localize
                              const SizedBox(height: 8.0),
                              Text(
                                destinationDetails.history!,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(height: 24.0),
                            ],
                          ),

                        // Display Hotels (if available)
                        if (destinationDetails.hotels != null &&
                            destinationDetails.hotels!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.hotelsTitle,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), // Localize
                              const SizedBox(height: 12.0), // Adjusted spacing
                              // Use a Column to list hotels with more visual separation
                              Column(
                                children:
                                    destinationDetails.hotels!
                                        .map(
                                          (hotel) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ), // Add vertical padding
                                            child: Card(
                                              // Wrap in Card for better visual structure
                                              elevation:
                                                  2.0, // Add slight shadow
                                              child: ListTile(
                                                leading:
                                                    hotel.imageUrl != null &&
                                                            hotel
                                                                .imageUrl!
                                                                .isNotEmpty
                                                        ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4.0,
                                                              ),
                                                          child: Image.network(
                                                            hotel.imageUrl!,
                                                            width:
                                                                60, // Increased size
                                                            height:
                                                                60, // Increased size
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                width: 60,
                                                                height: 60,
                                                                color:
                                                                    Colors
                                                                        .grey[300],
                                                                child: Icon(
                                                                  Icons.hotel,
                                                                  color:
                                                                      Colors
                                                                          .grey[600],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                        : const Icon(
                                                          Icons.hotel,
                                                          size: 60,
                                                        ), // Default icon
                                                title: Text(
                                                  hotel.name ??
                                                      l10n.unknownHotel,
                                                ), // Localize fallback
                                                // Add onTap to open map link if available
                                                onTap: () {
                                                  if (hotel.mapLink != null &&
                                                      hotel
                                                          .mapLink!
                                                          .isNotEmpty) {
                                                    // TODO: Implement logic to open map link (e.g., using url_launcher package)
                                                    print(
                                                      'Tapped on hotel ${hotel.name}. Map link: ${hotel.mapLink}',
                                                    );
                                                    // _launchUrl(hotel.mapLink!); // Uncomment when implemented
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 24.0),
                            ],
                          ),

                        // Display Tourist Attractions (if available)
                        if (destinationDetails.touristAttractions != null &&
                            destinationDetails.touristAttractions!.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.attractionsTitle,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ), // Localize
                              const SizedBox(height: 12.0), // Adjusted spacing
                              // Use a Column to list attractions with more visual separation
                              Column(
                                children:
                                    destinationDetails.touristAttractions!
                                        .map(
                                          (attraction) => Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 8.0,
                                            ), // Add vertical padding
                                            child: Card(
                                              // Wrap in Card for better visual structure
                                              elevation:
                                                  2.0, // Add slight shadow
                                              child: ListTile(
                                                leading:
                                                    attraction.imageUrl !=
                                                                null &&
                                                            attraction
                                                                .imageUrl!
                                                                .isNotEmpty
                                                        ? ClipRRect(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                4.0,
                                                              ),
                                                          child: Image.network(
                                                            attraction
                                                                .imageUrl!,
                                                            width:
                                                                60, // Increased size
                                                            height:
                                                                60, // Increased size
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                width: 60,
                                                                height: 60,
                                                                color:
                                                                    Colors
                                                                        .grey[300],
                                                                child: Icon(
                                                                  Icons
                                                                      .attractions,
                                                                  color:
                                                                      Colors
                                                                          .grey[600],
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        )
                                                        : const Icon(
                                                          Icons.attractions,
                                                          size: 60,
                                                        ), // Default icon
                                                title: Text(
                                                  attraction.name ??
                                                      l10n.unknownAttraction,
                                                ), // Localize fallback
                                                subtitle: Text(
                                                  attraction.desc ??
                                                      l10n.noDescriptionAvailable,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ), // Localize fallback
                                                // Add onTap to open map link if available
                                                onTap: () {
                                                  if (attraction.mapLink !=
                                                          null &&
                                                      attraction
                                                          .mapLink!
                                                          .isNotEmpty) {
                                                    // TODO: Implement logic to open map link (e.g., using url_launcher package)
                                                    print(
                                                      'Tapped on attraction ${attraction.name}. Map link: ${attraction.mapLink}',
                                                    );
                                                    // _launchUrl(attraction.mapLink!); // Uncomment when implemented
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              const SizedBox(height: 24.0),
                            ],
                          ),

                        // You can add more details here (Latitude, Longitude, etc.)
                        // Consider displaying Latitude/Longitude on a map if possible.
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Handle the case where snapshot.hasData is true but snapshot.data is null (e.g., 404 from backend)
            return Center(
              child: Text(l10n.destinationDetailsNotFound), // Localize
            );
          }
        },
      ),
    );
  }
}
