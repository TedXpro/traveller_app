// lib/services/destination_api_services.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/destination.dart'; // Import Destination model
import 'package:traveller_app/constants/api_constants.dart'; // Assuming baseUrl is here

// Define the DestinationService class
class DestinationService {
  // Method to fetch all destinations
  // Corresponds to your backend's GET /destination/all endpoint
  Future<List<Destination>> fetchAllDestinations() async {
    final url = Uri.parse('$baseUrl/destination/all');
    try {
      final response = await http.get(url);

      print(
        'Fetch All Destinations API Response Status: ${response.statusCode}',
      );
      print(
        'Fetch All Destinations API Response Body: ${response.body}',
      ); // Log response body

      if (response.statusCode == 200) {
        // Decode the JSON response body as a List
        final List<dynamic> data = jsonDecode(response.body);

        // Map the list of JSON objects to a list of Destination objects
        return data.map((dynamic item) => Destination.fromJson(item)).toList();
      } else {
        // Handle non-200 status codes
        print(
          'Failed to load destinations: ${response.statusCode} - ${response.body}',
        );
        // Throw an exception to be caught by the FutureBuilder or caller
        throw Exception('Failed to load destinations: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or decoding errors
      print('Error fetching destinations: $e');
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }

  Future<DestinationDetails?> getDestinationDetailsById(
    String destinationId,
    // String? jwtToken, // Uncomment and pass if backend requires authentication
  ) async {
    // Construct the URL with the destination ID
    final url = Uri.parse(
      '$baseUrl/destination/details/$destinationId',
    ); // Adjust endpoint if needed

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // If backend requires authentication, uncomment and add:
          // 'Authorization': 'Bearer $jwtToken',
        },
      );

      print(
        'Get Destination Details API Response Status: ${response.statusCode}',
      );
      print(
        'Get Destination Details API Response Body: ${response.body}',
      ); // Log response body

      if (response.statusCode == 200) {
        print(
          'Destination details fetched successfully for ID: $destinationId',
        );
        // Decode the JSON response body into a DestinationDetails object
        final Map<String, dynamic> detailsJson = json.decode(response.body);
        return DestinationDetails.fromJson(detailsJson);
      } else if (response.statusCode == 404) {
        print('Destination details not found for ID: $destinationId');
        return null; // Return null if details are not found
      } else {
        print(
          'Failed to fetch destination details: ${response.statusCode} - ${response.body}',
        );
        // Log the error response body for debugging
        print('Error response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching destination details: $e');
      return null;
    }
  }
}

// TODO: Ensure your Destination model is correctly defined in lib/models/destination.dart
// TODO: Ensure your DestinationDetails model is correctly defined in lib/models/destination_details.dart
// TODO: Ensure api_constants.dart contains the correct baseUrl
// TODO: If your backend endpoints require JWT tokens, uncomment the jwtToken parameters and headers.
