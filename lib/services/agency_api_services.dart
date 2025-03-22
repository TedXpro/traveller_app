import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:traveller_app/models/agency.dart';

class AgencyServices {
  final String baseUrl = 'http://localhost:8080';

  Future<Agency?> fetchAgencyApi(agencyId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/agency/get/$agencyId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> agencyData = jsonDecode(response.body);
      return Agency.fromJson(agencyData);
    }

    return null;
  }
}
