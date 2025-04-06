// bookings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/booking_details.dart';
import 'package:traveller_app/services/booking_api_services.dart';
import 'package:intl/intl.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final BookingServices bookingServices = BookingServices();
  List<Booking> bookings = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    try {
      // Access the UserProvider to get the user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.userData;

      // Use the user's ID from userData (replace with your actual property name)
      if (user != null && user.id != null) {
        // Assuming user.id exists
        bookings = await bookingServices.getBookingsForTraveler(user.id!);
      } else {
        // Handle the case where the user or user ID is null
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User ID not available.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load bookings: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Bookings')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : bookings.isEmpty
              ? const Center(child: Text('No bookings found.'))
              : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      title: Text('Start: ${booking.startLocation}'),
                      subtitle: Text(
                        'Booked on: ${DateFormat('yyyy-MM-dd HH:mm').format(booking.bookTime)}',
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    BookingDetailsPage(booking: booking),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }
}
