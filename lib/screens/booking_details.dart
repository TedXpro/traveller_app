// booking_details_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/booking.dart'; // Assuming Booking model is correctly defined
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:traveller_app/screens/booking_confirmation.dart';
import 'package:traveller_app/l10n/app_localizations_extension.dart'; // Ensure this is imported for getBookingStatusLocalized
import 'dart:async'; // Import for Timer

class BookingDetailsPage extends StatelessWidget {
  final Booking booking;

  const BookingDetailsPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations instance
    final theme = Theme.of(context); // Access the current theme
    final colorScheme = theme.colorScheme; // Access the color scheme

    // Determine if the booking status is 'pending' for conditional display
    final isPending = booking.status.toString().toLowerCase() == 'pending';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.bookingDetails), // Localized AppBar title
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Use Column as the direct child of SingleChildScrollView
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Conditional Pay By / Countdown (Still at top if pending) ---
            if (isPending) ...[
              _PayByCountdownRow(
                bookTimeLimit: booking.bookTimeLimit,
                l10n: l10n,
                theme: theme,
              ),
              const SizedBox(height: 16), // Spacing after countdown
            ],

            // --- Main Details Card ---
            Card(
              elevation: theme.cardTheme.elevation ?? 4.0,
              shape:
                  theme.cardTheme.shape ??
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Booking Summary Header ---
                    Text(
                      l10n.bookingSummary,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 30, thickness: 1.5),

                    // --- Travel Information Section ---
                    _buildSectionHeader(
                      l10n.travelDetailsSection,
                      theme,
                      Icons.route,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      l10n.travelId,
                      booking.travelId.toString(),
                      theme,
                      Icons.vpn_key_outlined,
                    ),
                    _buildDetailRow(
                      l10n.from,
                      booking.startLocation.toString(),
                      theme,
                      Icons.location_on_outlined,
                    ),
                    _buildDetailRow(
                      l10n.to,
                      booking.destination.toString(),
                      theme,
                      Icons.location_on_outlined,
                    ),
                    _buildDetailRow(
                      l10n.fullName,
                      "${booking.firstName!} ${booking.lastName!}".toString(),
                      theme,
                      Icons.person_outline, 
                    ),
                    _buildDetailRow(
                      l10n.email,
                      booking.email.toString(),
                      theme,
                      Icons.email_outlined,
                    ),
                    _buildDetailRow(
                      l10n.phoneNumber,
                      booking.phoneNumber.toString(),
                      theme,
                      Icons.phone_outlined,
                    ),
                    _buildDetailRow(
                      l10n.seatNo,
                      (booking.seatNo).toString(),
                      theme,
                      Icons.event_seat_outlined,
                    ),
                    _buildDetailRow(
                      l10n.tripType,
                      booking.tripType.toString(),
                      theme,
                      Icons.alt_route,
                    ),
                    _buildDetailRow(
                      l10n.priceDisplay,
                      '\$${booking.price.toStringAsFixed(2)}',
                      theme,
                      Icons.price_change_outlined,
                    ),
                    _buildDetailRow(
                      l10n.bookedOn,
                      DateFormat(
                        'EEEE, MMMM d, yyyy hh:mm a',
                        l10n.localeName,
                      ).format(booking.bookTime.toLocal()),
                      theme,
                      Icons.date_range_outlined,
                    ),

                    // --- Payment Information Section ---
                    const SizedBox(height: 20),
                    _buildSectionHeader(
                      l10n.paymentDetails,
                      theme,
                      Icons.payment,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      l10n.paymentType,
                      booking.paymentType ?? l10n.notAvailable,
                      theme,
                      Icons.credit_card_outlined,
                    ),
                    _buildDetailRow(
                      l10n.paymentRef,
                      booking.paymentRef!.currentPaymentRef ?? l10n.notAvailable,
                      theme,
                      Icons.confirmation_number_outlined,
                    ),
                    // CONDITIONAL: Only show payTime if NOT pending
                    if (!isPending)
                      _buildDetailRow(
                        l10n.payTime,
                        booking.payTime != null
                            ? DateFormat(
                              'EEEE, MMMM d, yyyy hh:mm a',
                              l10n.localeName,
                            ).format(booking.payTime!.toLocal())
                            : l10n.notPaidYet,
                        theme,
                        Icons.payments_outlined,
                      ),

                    // --- Booking Status Section ---
                    const SizedBox(height: 20),
                    _buildSectionHeader(l10n.status, theme, Icons.info_outline),
                    const SizedBox(height: 12),
                    _buildStatusRow(
                      l10n.status,
                      booking.status.toString(),
                      theme,
                      l10n,
                    ),

                    // --- Action Button (e.g., Proceed to Payment) ---
                    const SizedBox(height: 30),
                    if (isPending)
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => BookingConfirmationPage(
                                      booking: booking,
                                    ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(l10n.proceedToPayment),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            textStyle: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget to build section headers with icons
  Widget _buildSectionHeader(String title, ThemeData theme, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: theme.colorScheme.secondary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // Helper widget to build individual detail rows with icons
  Widget _buildDetailRow(
    String label,
    String value,
    ThemeData theme,
    IconData icon,
  ) {
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.onSurface.withOpacity(0.6), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontWeight: FontWeight.normal,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
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
    String statusText = status ?? l10n.unknownStatus;
    Color statusColor = colorScheme.onSurface;
    IconData statusIcon = Icons.help_outline;

    final localizedStatus = l10n.getBookingStatusLocalized(statusText);

    if (statusText.toLowerCase() == 'pending') {
      statusColor = Colors.orange;
      statusIcon = Icons.pending_actions_outlined;
    } else if (statusText.toLowerCase() == 'confirmed') {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (statusText.toLowerCase() == 'cancelled') {
      statusColor = Colors.red;
      statusIcon = Icons.cancel_outlined;
    } else if (statusText.toLowerCase() == 'failed') {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else if (statusText.toLowerCase() == 'paid') {
      statusColor = theme.colorScheme.primary;
      statusIcon = Icons.payments_outlined;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor.withOpacity(0.5), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 28),
              const SizedBox(width: 12),
              Text(
                '${l10n.status}:',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              localizedStatus,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

// Stateful Widget for the Countdown Timer
class _PayByCountdownRow extends StatefulWidget {
  final DateTime bookTimeLimit;
  final AppLocalizations l10n;
  final ThemeData theme;

  const _PayByCountdownRow({
    required this.bookTimeLimit,
    required this.l10n,
    required this.theme,
  });

  @override
  __PayByCountdownRowState createState() => __PayByCountdownRowState();
}

class __PayByCountdownRowState extends State<_PayByCountdownRow> {
  late Timer _timer;
  late Duration _remainingTime;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.bookTimeLimit.difference(DateTime.now());
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _remainingTime = widget.bookTimeLimit.difference(DateTime.now());
        if (_remainingTime.isNegative) {
          _timer.cancel();
        }
      });
    });
  }

  // Helper to format duration into a readable string
  String _formatDuration(Duration duration, AppLocalizations l10n) {
    if (duration.isNegative) {
      return l10n.timeExpired;
    }

    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    if (duration.inDays > 0) {
      return l10n.timeRemainingDays(duration.inDays, hours, minutes, seconds);
    } else if (duration.inHours > 0) {
      return l10n.timeRemainingHours(hours, minutes, seconds);
    } else if (duration.inMinutes > 0) {
      return l10n.timeRemainingMinutes(minutes, seconds);
    } else {
      return l10n.timeRemainingSeconds(seconds);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final colorScheme = theme.colorScheme;
    final l10n = widget.l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 15.0),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.orange.withOpacity(0.5), width: 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.hourglass_bottom, color: Colors.orange, size: 28),
              const SizedBox(width: 12),
              Text(
                '${l10n.paymentDue}:',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Flexible(
            child: Text(
              _formatDuration(_remainingTime, l10n),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _remainingTime.isNegative ? Colors.red : Colors.orange,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
