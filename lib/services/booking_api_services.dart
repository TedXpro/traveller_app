import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/models/seat.dart';

class BookingServices {
  final String baseUrl = 'http://localhost:8080';

  Future<void> book(Booking booking) async {
    final response = await http.post(
      Uri.parse('$baseUrl/booking/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(booking.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to book: ${response.body}');
    }
  }

  Future<void> chooseSeat(Seat seat) async {
    final response = await http.post(
      Uri.parse('$baseUrl/booking/seat/choose'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(seat.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to choose seat: ${response.body}');
    }
  }

  Future<List<Booking>> getBookingsForTraveler(String travelerId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/booking/traveler/$travelerId'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Booking.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load bookings: ${response.body}');
    }
  }
}
