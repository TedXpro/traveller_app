import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/constants/api_constants.dart';

Future<List<Travel>> searchTravelsApi(
  String startLocation,
  String destination,
  DateTime? dateMin,
  DateTime? dateMax,
) async {
  // Check for empty locations
  if (startLocation.isEmpty || destination.isEmpty) {
    return []; // Return empty list if locations are empty
  }

  Map<String, String> queryParams = {
    'start_location': startLocation,
    'destination': destination,
  };

  if (dateMin != null) {
    queryParams['date_min'] = dateMin.toIso8601String().substring(0, 10);
  }

  if (dateMax != null) {
    queryParams['date_max'] = dateMax.toIso8601String().substring(0, 10);
  }

  final response = await http.get(Uri.https(searchUrl, '/travels/search', queryParams));
  print("here ${response.body}");

  if (response.statusCode == 200) {
    try {
      List<dynamic> decodedResponse = jsonDecode(response.body);

      return decodedResponse
          .map((dynamic item) => Travel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Handle decoding or mapping errors
      print("Error decoding or mapping travels: $e");
      return []; // Return empty list in case of error
    }
  } else {
    // Handle non-200 status code
    print("API error: ${response.statusCode}");
    return []; // Return empty list in case of error
  }
}
