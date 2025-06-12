// bookings_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/l10n/app_localizations_extension.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/booking_details.dart';
import 'package:traveller_app/services/booking_api_services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class BookingsPage extends StatefulWidget {
  final VoidCallback? onNavigateToHome;

  const BookingsPage({super.key, this.onNavigateToHome});

  @override
  _BookingsPageState createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  final BookingServices bookingServices = BookingServices();
  List<Booking> bookings = [];
  bool isLoading = true;
  bool _hasFetchedOnce = false;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasFetchedOnce || bookings.isEmpty) {
      _fetchBookings();
    }
  }

  Future<void> _fetchBookings() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      _hasFetchedOnce = true;
    });

    try {
      final l10n = AppLocalizations.of(context)!;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.userData;

      if (user == null || user.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.loginRequiredForBookingsPage)),
          );
          setState(() {
            bookings = [];
            isLoading = false;
          });
        }
        return;
      }

      List<Booking>? fetchedBookings = await bookingServices
          .getBookingsForTraveler(user.id!);

      if (mounted) {
        if (fetchedBookings.isEmpty) {
          setState(() {
            bookings = [];
          });
        } else {
          fetchedBookings.sort((a, b) => b.bookTime.compareTo(a.bookTime));
          setState(() {
            bookings = fetchedBookings;
          });
        }
      }
    } catch (e) {
      print('Error fetching bookings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToLoadBookings(e.toString()),
            ),
          ),
        );
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myBookingsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: isLoading ? null : _fetchBookings,
            tooltip: l10n.refreshBookings,
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : bookings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 80,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.noBookingsFound,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.startBookingMessage,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        widget.onNavigateToHome?.call();
                      },
                      icon: const Icon(Icons.add_road),
                      label: Text(l10n.findNewTravels),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: bookings.length,
                itemBuilder: (context, index) {
                  final booking = bookings[index];
                  String statusText = booking.status ?? l10n.unknownStatus;
                  Color statusColor = Colors.black;

                  if (booking.status == 'pending') {
                    statusColor = Colors.orange;
                  } else if (booking.status == 'confirmed') {
                    statusColor = Colors.green;
                  } else if (booking.status == 'cancelled') {
                    statusColor = Colors.red;
                  } else if (booking.status == 'failed') {
                    statusColor = Colors.red;
                  }

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.airplane_ticket,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(
                        // Updated title to include destination
                        '${l10n.from}: ${booking.startLocation} ${l10n.to}: ${booking.destination}',
                        style: theme.textTheme.titleMedium,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              l10n.travelIdDisplay(booking.travelId!),
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${l10n.bookedOn}: ${DateFormat('EEEE, MMMM d, yyyy hh:mm a', l10n.localeName).format(booking.bookTime.toLocal())}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${l10n.status}: ${l10n.getBookingStatusLocalized(statusText)}',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (booking.bookingRef != null &&
                              booking.bookingRef!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                '${l10n.bookingReference}: ${booking.bookingRef}',
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
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
