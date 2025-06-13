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
  // if (startLocation.isEmpty || destination.isEmpty) {
  //   return []; // Return empty list if locations are empty
  // }

  Map<String, String> queryParams = {};

  if (startLocation.isNotEmpty){
    queryParams['start_location'] = startLocation;
  }

  if (destination.isNotEmpty) {
    queryParams['destination'] = destination;
  }

  if (dateMin != null) {
    queryParams['date_min'] = dateMin.toIso8601String().substring(0, 10);
  }

  if (dateMax != null) {
    queryParams['date_max'] = dateMax.toIso8601String().substring(0, 10);
  }

  print("Query Params: $queryParams");

  final response = await http.get(
    Uri.http(searchUrl, '/travels/search', queryParams),
  );
  print("here ${response.body}");

  if (response.statusCode == 200) {
    try {
      List<dynamic> decodedResponse = jsonDecode(response.body);

      decodedResponse =
          decodedResponse
              .map(
                (dynamic item) => Travel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
      print("Decoded Travels: $decodedResponse");
      return decodedResponse.cast<Travel>();
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

Future<Travel> getTravelByIdApi(String travelID) async{
  final url = Uri.parse("$baseUrl/travel/$travelID");
  final response = await http.get(url);
  if (response.statusCode == 200){
    try {
      final Map<String, dynamic> travelData = jsonDecode(response.body);
      return Travel.fromJson(travelData);
    } catch (e) {
      // Handle decoding error
      print("Error decoding travel data: $e");
      throw Exception("Failed to decode travel data");
    }
  } else {
    // Handle non-200 status code
    print("API error: ${response.statusCode}");
    throw Exception("Failed to load travel data");
  }
}