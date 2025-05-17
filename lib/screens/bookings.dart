// bookings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/booking_details.dart';
import 'package:traveller_app/services/booking_api_services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

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
    if (!mounted) return; // Check mounted state before async operation
    setState(() {
      isLoading = true;
    });

    try {
      // Access the UserProvider to get the user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.userData;

      // Use the user's ID from userData (replace with your actual property name)
      if (user != null && user.id != null) {
        // Assuming user.id exists
        List<Booking> fetchedBookings = await bookingServices
            .getBookingsForTraveler(user.id!);

        // Sort the bookings by bookTime in descending order (latest first)
        fetchedBookings.sort((a, b) => b.bookTime.compareTo(a.bookTime));

        if (mounted) {
          setState(() {
            bookings = fetchedBookings;
          });
        }
      } else {
        // Handle the case where the user or user ID is null
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User ID not available. Please log in.'),
            ),
          ); // Improved message
        }
      }
    } catch (e) {
      print('Error fetching bookings: $e'); // Log the error
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load bookings: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance
    final theme = Theme.of(context); // Access the current theme

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myBookingsTitle)), // Localize title
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : bookings.isEmpty
              ? Center(
                child: Text(l10n.noBookingsFound),
              ) // Localize empty message
              : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  // Determine status text and color
                  String statusText =
                      booking.status ??
                      l10n.unknownStatus; // Default to unknown if status is null
                  Color statusColor = Colors.black; // Default color

                  if (booking.status == 'pending') {
                    // Use backend status string
                    statusColor = Colors.red;
                  } else if (booking.status == 'confirmed') {
                    // Use backend status string
                    statusColor = Colors.green;
                  }
                  // Add other statuses if needed (e.g., 'cancelled', 'failed')

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: ListTile(
                      // Displaying start location and potentially destination
                      title: Text(
                        '${l10n.from}: ${booking.startLocation}',
                      ), // Localize
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.bookedOn}: ${DateFormat('yyyy-MM-dd HH:mm').format(booking.bookTime.toLocal())}',
                          ), // Localize and format book time in local time
                          Text(
                            '${l10n.status}: $statusText',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ), // Display status with color
                        ],
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
