import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/destination.dart';

Future<List<Destination>> fetchDestinations() async {
  final response = await http.get(
    Uri.parse('http://localhost:8080/destination/all'),
  );

  if (response.statusCode == 200) {
    // Decode the JSON response
    Map<String, dynamic> decodedResponse = jsonDecode(response.body);

    // Extract the list from the "data" key
    if (decodedResponse.containsKey('data') &&
        decodedResponse['data'] is List) {
      List<dynamic> data = decodedResponse['data'];
      print(data);
      return data.map((dynamic item) => Destination.fromJson(item)).toList();
    } else {
      throw Exception(
        'Invalid response format: Missing or incorrect "data" key',
      );
    }
  } else {
    throw Exception('Failed to load destinations');
  }
}
