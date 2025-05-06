import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/models/seat.dart';
import 'package:traveller_app/constants/api_constants.dart';

class BookingServices {
  Future<bool> bookTravel(Booking booking) async {
    final url = Uri.parse('$baseUrl/bookings');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(booking.toJson()),
      );
      if (response.statusCode == 200) {
        return true; // Or check for a specific success message
      } else {
        print(
          'Failed to book travel: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error booking travel: $e');
      return false;
    }
  }

  Future<bool> chooseSeat(Seat seat) async {
    final url = Uri.parse('$baseUrl/bookings/choose-seat');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(seat.toJson()),
      );
      if (response.statusCode == 200) {
        return true; // Or check for a specific success message
      } else {
        print(
          'Failed to choose seat: ${response.statusCode} - ${response.body}',
        );
        return false;
      }
    } catch (e) {
      print('Error choosing seat: $e');
      return false;
    }
  }

  Future<List<int>> fetchTakenSeats(String travelId) async {
    final url = Uri.parse(
      '$baseUrl/bookings/taken-seats/$travelId',
    ); // Adjust the endpoint
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data =
            json.decode(
              response.body,
            )['taken_seats']; // Adjust based on your backend response
        return data.cast<int>();
      } else {
        print('Failed to fetch taken seats: ${response.statusCode}');
        throw Exception('Failed to fetch taken seats');
      }
    } catch (e) {
      print('Error fetching taken seats: $e');
      rethrow;
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
