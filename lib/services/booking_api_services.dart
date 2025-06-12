import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/models/booking_status.dart';
import 'package:traveller_app/models/seat.dart';
import 'package:traveller_app/constants/api_constants.dart';

class BookingServices {
  Future<Booking?> bookTravel(Booking booking) async {
    final url = Uri.parse('$baseUrl/booking/add');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(booking.toJson()),
      );

      print("inside BookTravel\n\n");
      print(response.statusCode);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        print(responseData);
        return Booking.fromJson(responseData);
      } else {
        print(
          'Failed to book travel: ${response.statusCode} - ${response.body}',
        );
        return null; // Return null on failure
      }
    } catch (e) {
      print('Error booking travel: $e');
      return null; // Return null on error
    }
  }

  Future<bool> chooseSeat(Seat seat) async {
    final url = Uri.parse('$baseUrl/booking/seat/choose');
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

  Future<List<bool>> fetchTakenSeats(String travelId) async {
    final url = Uri.parse('$baseUrl/booking/seats/$travelId');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        final List<bool> seatsStatus = data.cast<bool>();

        print(
          'Successfully fetched boolean seat status for Travel ID $travelId. Length: ${seatsStatus.length}',
        );
        return seatsStatus;
      } else {
        print(
          'Failed to fetch travel seats: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to fetch travel seats: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching travel seats: $e');
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

  // Method to update booking status to 'confirmed' after successful payment
  Future<bool> updateBookingStatusToConfirmed(Booking booking) async {
    // Construct the URL with the booking ID
    // Assuming your Booking model has an 'id' field that matches the backend's _id
    // Note: MongoDB's _id is ObjectId, which is serialized to a string in JSON
    final url = Uri.parse(
      '$baseUrl/booking/edit/${booking.id}',
    ); // Use booking.id

    // Create a new Booking object with the updated status
    // We create a copy to avoid modifying the original object if needed elsewhere
    final updatedBooking = Booking(
      id: booking.id, // Include the ID
      travelId: booking.travelId,
      travelerId: booking.travelerId,
      firstName: booking.firstName,
      lastName: booking.lastName,
      email: booking.email,
      phoneNumber: booking.phoneNumber,
      seatNo: booking.seatNo,
      tripType: booking.tripType,
      startLocation: booking.startLocation,
      destination: booking.destination,
      price: booking.price,
      paymentType: booking.paymentType, // Keep existing payment type
      paymentRef: booking.paymentRef, // Keep existing payment ref
      bookTime: booking.bookTime,
      payTime: DateTime.now(), // Set payTime to now
      bookTimeLimit: booking.bookTimeLimit, 
      status: 'confirmed', // Set status to 'confirmed'
    );

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(
          updatedBooking.toJson(),
        ), // Send the updated booking object
      );

      if (response.statusCode == 200) {
        print(
          'Booking status updated to confirmed successfully for ID: ${booking.id}',
        );
        return true;
      } else {
        print(
          'Failed to update booking status: ${response.statusCode} - ${response.body}',
        );
        // Log the error response body for debugging
        print('Error response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating booking status: $e');
      return false;
    }
  }

  Future<Booking?> updateBookingStatus(
    BookingStatus bookingStatus,
    String jwtToken,
  ) async {
    // Added jwtToken parameter
    // Assuming the backend endpoint for UpdateBooking is /booking/update
    final url = Uri.parse('$baseUrl/booking/update');
    try {
      final response = await http.put(
        // Use PUT method as per backend router
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwtToken', // Include Authorization header
        },
        body: jsonEncode(
          bookingStatus.toJson(),
        ), // Send BookingStatus object as body
      );

      if (response.statusCode == 200) {
        // Assuming the backend returns the updated Booking object on success
        final Map<String, dynamic> bookingData = jsonDecode(response.body);
        print(
          'Successfully updated booking status for BookingRef ${bookingStatus.bookingRef} to ${bookingStatus.status}.',
        );
        return Booking.fromJson(bookingData);
      } else if (response.statusCode == 401) {
        print(
          'Unauthorized to update booking status for BookingRef ${bookingStatus.bookingRef}.',
        );
        return null; // Indicate unauthorized failure
      } else {
        print(
          'Failed to update booking status for BookingRef ${bookingStatus.bookingRef}: ${response.statusCode} - ${response.body}',
        );
        return null; // Indicate failure
      }
    } catch (e) {
      print(
        'Error updating booking status for BookingRef ${bookingStatus.bookingRef}: $e',
      );
      return null; // Indicate failure
    }
  }

}
