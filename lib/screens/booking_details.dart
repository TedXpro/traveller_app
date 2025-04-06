// booking_details_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:intl/intl.dart';

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Travel ID: ${booking.travelId}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Traveler ID: ${booking.travelerId}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Seat No: ${booking.seatNo}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Trip Type: ${booking.tripType}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Start Location: ${booking.startLocation}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Payment Type: ${booking.paymentType}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Payment Ref: ${booking.paymentRef}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Book Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(booking.bookTime)}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Pay Time: ${booking.payTime != null ? DateFormat('yyyy-MM-dd HH:mm:ss').format(booking.payTime!) : 'Not Paid Yet'}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Book Time Limit: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(booking.bookTimeLimit)}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Status: ${booking.status}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
