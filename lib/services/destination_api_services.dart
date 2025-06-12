import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/constants/api_constants.dart';

Future<List<Destination>> fetchDestinationsApi() async {
  final url = Uri.parse('$baseUrl/destination/all');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the JSON response directly as a List
      final List<dynamic> data = jsonDecode(response.body);

      // Map the list of JSON objects to a list of Destination objects
      return data.map((dynamic item) => Destination.fromJson(item)).toList();
    } else {
      // Handle non-200 status codes
      print(
        'Failed to load destinations: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to load destinations: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network or decoding errors
    print('Error fetching destinations: $e');
    rethrow; // Re-throw the exception to be handled by the caller (e.g., Provider)
  }
}

Future<Destination> fetchDestinationByIdApi(id) async{
  final url = Uri.parse('$baseUrl/destination/$id');
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // Decode the JSON response directly as a Map
      final Map<String, dynamic> data = jsonDecode(response.body);

      // Create a Destination object from the JSON map
      return Destination.fromJson(data);
    } else {
      // Handle non-200 status codes
      print(
        'Failed to load destination: ${response.statusCode} - ${response.body}',
      );
      throw Exception('Failed to load destination: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network or decoding errors
    print('Error fetching destination by ID: $e');
    rethrow; // Re-throw the exception to be handled by the caller
  }
}