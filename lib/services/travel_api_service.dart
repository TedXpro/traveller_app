import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/travel.dart';

Future<List<Travel>> searchTravelsApi(
  String startLocation,
  String destination,
  DateTime? dateMin,
  DateTime? dateMax,
) async {
  // Construct the query parameters
  Map<String, String> queryParams = {
    'start_location': startLocation,
    'destination': destination,
  };

  if (dateMin != null) {
    queryParams['date_min'] = dateMin.toIso8601String().substring(
      0,
      10,
    ); // Format: YYYY-MM-DD
  }

  if (dateMax != null) {
    queryParams['date_max'] = dateMax.toIso8601String().substring(
      0,
      10,
    ); // Format: YYYY-MM-DD
  }

  final uri = Uri.http('localhost:8080', '/travels/search', queryParams);

  final response = await http.get(uri);
  print("here ${response.body}");

  if (response.statusCode == 200) {
    List<dynamic> decodedResponse = jsonDecode(response.body);

    return decodedResponse
        .map(
          (dynamic item) => Travel.fromJson(item as Map<String, dynamic>),
        ) // Corrected line
        .toList();
  } else {
    throw Exception('Failed to search travels');
  }
}
