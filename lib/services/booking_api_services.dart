import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/seat.dart';

class BookingServices {
  final String baseUrl = 'http://localhost:8080';

  Future<void> chooseSeat(Seat seat) async {
    final response = await http.post(
      Uri.parse('$baseUrl/booking/choose-seat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(seat.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to choose seat: ${response.body}');
    }
  }
}
