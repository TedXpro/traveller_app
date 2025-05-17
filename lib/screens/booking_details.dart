// booking_details_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/booking.dart'; // Assuming Booking model is correctly defined
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:traveller_app/screens/booking_confirmation.dart';

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance
    final theme = Theme.of(context); // Access the current theme
    final colorScheme = theme.colorScheme; // Access the color scheme

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingDetails), // Localized AppBar title
        // AppBar styling picks up theme.appBarTheme automatically
      ),
      // Scaffold background picks up theme.scaffoldBackgroundColor automatically
      body: SingleChildScrollView(
        // Use SingleChildScrollView to prevent overflow on small screens
        padding: const EdgeInsets.all(16.0),
        child: Card(
          // Wrap content in a Card for a better visual separation
          // Card styling picks up theme.cardTheme automatically
          elevation:
              theme.cardTheme.elevation ??
              1.0, // Use theme elevation or default
          shape:
              theme.cardTheme.shape ??
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ), // Use theme shape or default
          margin:
              EdgeInsets.zero, // Remove default card margin to use page padding
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header for the booking details
                Text(
                  l10n.bookingSummary, // Localized section title
                  style: theme.textTheme.titleLarge?.copyWith(
                    // Color contrasts with card background
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Divider(height: 24), // Add a separator
                // Use a helper to build individual detail rows
                _buildDetailRow(
                  l10n.travelId,
                  booking.travelId.toString(),
                  theme,
                ), // .toString() added
                _buildDetailRow(
                  l10n.travelerId,
                  booking.travelerId
                      .toString(), // .toString() added (assuming it might not be String)
                  theme,
                ),
                _buildDetailRow(
                  l10n.seatNo,
                  booking.seatNo.toString(),
                  theme,
                ), // .toString() added
                _buildDetailRow(
                  l10n.tripType,
                  booking.tripType.toString(),
                  theme,
                ), // .toString() added (assuming it might not be String)
                _buildDetailRow(
                  l10n.startLocation,
                  booking.startLocation
                      .toString(), // .toString() added (assuming it might not be String)
                  theme,
                ),
                // Add end location if available in your Booking model
                // _buildDetailRow(l10n.endLocation, booking.endLocation?.toString() ?? l10n.notAvailable, theme), // Example if endLocation can be null/non-string
                _buildDetailRow(
                  l10n.paymentType,
                  booking.paymentType.toString(),
                  theme,
                ), // .toString() added
                _buildDetailRow(
                  l10n.paymentRef,
                  booking.paymentRef.toString(),
                  theme,
                ), // .toString() added
                // Formatted Dates
                _buildDetailRow(
                  l10n.bookTime,
                  DateFormat('yyyy-MM-dd HH:mm:ss').format(booking.bookTime),
                  theme,
                ),
                _buildDetailRow(
                  l10n.payTime,
                  booking.payTime != null
                      ? DateFormat(
                        'yyyy-MM-dd HH:mm:ss',
                      ).format(booking.payTime!)
                      : l10n.notPaidYet, // Localized 'Not Paid Yet'
                  theme,
                ),
                _buildDetailRow(
                  l10n.bookTimeLimit,
                  DateFormat(
                    'yyyy-MM-dd HH:mm:ss',
                  ).format(booking.bookTimeLimit),
                  theme,
                ),

                const Divider(height: 24), // Separator before status
                // Booking Status with conditional styling
                _buildStatusRow(
                  l10n.status,
                  booking.status.toString(),
                  theme,
                  l10n,
                ), // .toString() added

                const SizedBox(height: 20),

                // Placeholder for future payment button if status is Pending
                // Safely check status after converting to string
                if (booking.status.toString().toLowerCase() ==
                    'pending') // Case-insensitive check on string value
                  Align(
                    // Align button to center or end if desired
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to BookingConfirmationPage and pass the booking object
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    BookingConfirmationPage(booking: booking),
                          ),
                        );
                      },
                      // ElevatedButton style will pick up theme.elevatedButtonTheme automatically
                      // style: ElevatedButton.styleFrom(...) // Override if specific style needed
                      child: Text(
                        l10n.proceedToPayment,
                      ), // Localized button text
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build individual detail rows
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (e.g., "Travel ID:")
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              // Use a less prominent color for labels
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
          ),
          // Value (e.g., the actual ID)
          Expanded(
            // Use Expanded to prevent overflow of long values
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                // Color contrasts with card background
                color: colorScheme.onSurface,
                fontWeight:
                    FontWeight.normal, // Value text is not bold by default
              ),
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
              maxLines: 2, // Allow text to wrap onto two lines if needed
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build the Status row with conditional styling
  Widget _buildStatusRow(
    String label,
    String? status,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    final colorScheme = theme.colorScheme;
    String statusText =
        status ?? l10n.unknownStatus; // Handle null status, localize default
    Color statusColor = colorScheme.onSurface; // Default color

    if (statusText.toLowerCase() == 'pending') {
      statusColor = colorScheme.error; // Use error color for pending
    } else if (statusText.toLowerCase() == 'paid') {
      statusColor = colorScheme.primary; // Use primary color for paid
    } else {
      statusColor = colorScheme.onSurface.withOpacity(
        0.7,
      ); // Default color for other statuses
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (e.g., "Status:")
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontWeight: FontWeight.normal,
            ),
          ),
          // Status Value with bold and conditional color
          Expanded(
            // Use Expanded to prevent overflow
            child: Text(
              statusText,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold, // Status is always bold
                color: statusColor, // Apply conditional color
              ),
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
              maxLines: 1,
            ),
          ),
          // Add extra info next to status if pending
          if (statusText.toLowerCase() == 'pending')
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Icon(
                Icons.warning,
                color: colorScheme.error,
                size: theme.textTheme.bodyMedium?.fontSize,
              ), // Warning icon
            ),
        ],
      ),
    );
  }
}
