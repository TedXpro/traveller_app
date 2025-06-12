// lib/screens/payment_success.dart
// Description: This page is displayed after a payment attempt.
// It receives a Booking object as arguments and displays its details.
// It assumes the backend status update has been attempted before navigating here.

import 'package:flutter/material.dart';
import 'package:traveller_app/models/booking.dart';
// Keep if needed for theme or other user info
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:traveller_app/screens/main_screen.dart';
// Removed imports related to fetching/updating logic
// import 'package:traveller_app/services/booking_api_services.dart';
// import 'package:traveller_app/models/booking_status.dart';
import 'package:intl/intl.dart'; // For date formatting

class PaymentSuccessPage extends StatefulWidget {
  // Receive the Booking object as an argument
  final Booking booking;
  // Optional: Receive an error message about the backend update if needed
  final String? backendUpdateError;

  const PaymentSuccessPage({
    super.key,
    required this.booking,
    this.backendUpdateError,
  });

  @override
  _PaymentSuccessPageState createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  // The booking details are received directly, no need to fetch
  Booking? _bookingDetails;
  final bool _isLoading = false; // No longer loading data from fetch
  String?
  _errorMessage; // Can still be used to display backend update errors if passed

  @override
  void initState() {
    super.initState();
    // Set the booking details from the received widget property
    _bookingDetails = widget.booking;
    print("PaymentSuccessPage received Booking: ${_bookingDetails.toString()}");

    // Set the backend update error message if passed
    _errorMessage = widget.backendUpdateError;
  }

  // Helper method to build detail rows
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance
    final theme = Theme.of(context); // Access the current theme
    final colorScheme = theme.colorScheme; // Access the color scheme

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Navigate back to the main screen on back press
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.paymentStatusTitle), // Localize
          automaticallyImplyLeading: false,
        ),
        body:
            _isLoading // Still keep loading indicator structure, although it should be false
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: MediaQuery.of(context).size.width * 0.9,
                      constraints: const BoxConstraints(maxWidth: 450),
                      decoration: BoxDecoration(
                        color: theme.cardColor, // Use theme's card color
                        borderRadius: BorderRadius.circular(20),
                        boxShadow:
                            theme.brightness == Brightness.light
                                ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 20,
                                    offset: const Offset(0, 10),
                                  ),
                                ]
                                : null, // No shadow in dark mode
                      ),
                      // Display booking details directly from _bookingDetails
                      child:
                          _bookingDetails ==
                                  null // Should not be null if passed correctly
                              ? Column(
                                // Show error state if booking details are unexpectedly null
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    _errorMessage ??
                                        l10n.paymentError(
                                          'Booking details not available.',
                                        ), // Show specific or generic error
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: Colors.red),
                                  ),
                                  const SizedBox(height: 20),
                                  // No retry button for fetching here, as we expect the object to be passed
                                  TextButton(
                                    onPressed: () {
                                      if (!mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const MainScreen(),
                                        ),
                                        (Route<dynamic> route) => false,
                                      );
                                    },
                                    child: Text(l10n.backToHome), // Localize
                                  ),
                                ],
                              )
                              : Column(
                                // Show booking details if available
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display success/failure message based on booking status
                                  Text(
                                    _bookingDetails!.status ==
                                            'confirmed' // Use backend constant if available
                                        ? l10n
                                            .paymentSuccessful // Localize success message
                                        : l10n.paymentFailed(
                                          _bookingDetails!.status ??
                                              l10n.unknownStatus,
                                        ), // Localize failure message
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          color:
                                              _bookingDetails!.status ==
                                                      'confirmed'
                                                  ? Colors
                                                      .green // Green for success
                                                  : Colors
                                                      .red, // Red for failure
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  if (_errorMessage !=
                                      null) // Show backend update error if any
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        _errorMessage!,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(color: Colors.red),
                                      ),
                                    ),
                                  const SizedBox(height: 20),

                                  Text(
                                    l10n.bookingSummary,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          color: colorScheme.onSurface,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const Divider(height: 24),

                                  _buildDetailRow(
                                    l10n.bookingReference,
                                    _bookingDetails!.bookingRef ??
                                        l10n.notAvailable,
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.travelId,
                                    _bookingDetails!.travelId.toString(),
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.seatNo,
                                    (_bookingDetails!.seatNo).toString(),
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.bookTime,
                                    _bookingDetails!.bookTime != null
                                        ? DateFormat(
                                          'yyyy-MM-dd HH:mm:ss',
                                        ).format(
                                          _bookingDetails!.bookTime.toLocal(),
                                        ) // Convert to local time
                                        : l10n.notAvailable,
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.payTime, // Localize pay time
                                    _bookingDetails!.payTime != null
                                        ? DateFormat(
                                          'yyyy-MM-dd HH:mm:ss',
                                        ).format(
                                          _bookingDetails!.payTime!.toLocal(),
                                        ) // Convert to local time
                                        : l10n.notAvailable,
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.paymentAmount,
                                    '${_bookingDetails!.price.toStringAsFixed(2)} ${l10n.currencyETB}',
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.paymentType,
                                    _bookingDetails!.paymentType ??
                                        l10n.notAvailable,
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.paymentRef,
                                    _bookingDetails!.paymentRef!.currentPaymentRef.toString(),// Access paymentRef directly (now a string)
                                    theme,
                                  ),
                                  _buildDetailRow(
                                    l10n.status, // Localize status
                                    _bookingDetails!.status ??
                                        l10n.notAvailable,
                                    theme,
                                  ),

                                  const SizedBox(height: 30),

                                  Align(
                                    alignment: Alignment.center,
                                    child: TextButton(
                                      onPressed: () {
                                        if (!mounted) return;
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => const MainScreen(),
                                          ),
                                          (Route<dynamic> route) => false,
                                        );
                                      },
                                      child: Text(l10n.backToHome), // Localize
                                    ),
                                  ),
                                ],
                              ),
                    ),
                  ),
                ),
      ),
    );
  }
}
