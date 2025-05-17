// booking_confirmation_page.dart
// Description: This page displays booking details and initiates the Chapa payment process.
// After payment completion, it calls the backend to update the booking status
// and explicitly navigates to the payment success page with the updated booking details.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:intl/intl.dart';
import 'package:chapasdk/chapasdk.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/payment_success.dart'; // Import PaymentSuccessPage
import 'package:traveller_app/services/booking_api_services.dart'; // Import BookingServices
import 'package:traveller_app/models/booking_status.dart'; // Import BookingStatus model

class BookingConfirmationPage extends StatefulWidget {
  final Booking booking;

  const BookingConfirmationPage({super.key, required this.booking});

  @override
  _BookingConfirmationPageState createState() =>
      _BookingConfirmationPageState();
}

class _BookingConfirmationPageState extends State<BookingConfirmationPage> {
  // Helper to build detail rows
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Navigate back to the main screen or bookings list on back press
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookingConfirmationTitle),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(maxWidth: 450),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                        : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.bookingConfirmedMessage,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    l10n.bookingSummary,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),

                  _buildDetailRow(
                    l10n.travelId,
                    widget.booking.travelId
                        .toString(), // Access booking via widget.booking
                    theme,
                  ),
                  // Display Booking Reference
                  _buildDetailRow(
                    l10n.bookingReference,
                    widget.booking.bookingRef ??
                        l10n.notAvailable, // Access booking via widget.booking
                    theme,
                  ),
                  _buildDetailRow(
                    l10n.seatNo,
                    widget.booking.seatNo
                        .toString(), // Access booking via widget.booking
                    theme,
                  ),
                  _buildDetailRow(
                    l10n.bookTime,
                    widget.booking.bookTime !=
                            null // Access booking via widget.booking
                        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                          widget.booking.bookTime,
                        ) // Access booking via widget.booking
                        : l10n.notAvailable,
                    theme,
                  ),
                  _buildDetailRow(
                    l10n.paymentDue,
                    widget.booking.bookTimeLimit !=
                            null // Access booking via widget.booking
                        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(
                          widget.booking.bookTimeLimit,
                        ) // Access booking via widget.booking
                        : l10n.notAvailable,
                    theme,
                  ),
                  _buildDetailRow(
                    l10n.paymentAmount,
                    '${widget.booking.price.toStringAsFixed(2)} ${l10n.currencyETB}', // Access booking via widget.booking
                    theme,
                  ),
                  _buildDetailRow(
                    l10n.paymentType,
                    widget.booking.paymentType ??
                        l10n.notAvailable, // Access booking via widget.booking
                    theme,
                  ),
                  // Display generated Payment Reference (from the nested Payment struct)
                  _buildDetailRow(
                    l10n.paymentRef,
                    widget.booking.paymentRef?.currentPaymentRef ??
                        l10n.notAvailable, // Access nested paymentRef
                    theme,
                  ),

                  const SizedBox(height: 30),

                  // Chapa Payment Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!mounted) return;

                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final userData = userProvider.userData;
                        final jwtToken = userProvider.jwtToken;

                        if (userData != null && jwtToken != null) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.initiatingPayment)),
                          );

                          try {
                            String amountToPay =
                                widget.booking.price.toString();
                            // Use the paymentRef from the nested Payment struct for Chapa's txRef
                            String transactionRef =
                                widget.booking.paymentRef?.currentPaymentRef ??
                                "";
                            print(
                              "Chapa TxRef (from booking.paymentRef):     $transactionRef",
                            );

                            String userPhone =
                                userData.phoneNumber != null &&
                                        userData.phoneNumber!.isNotEmpty
                                    ? userData.phoneNumber!
                                    : '0900123456';

                            if (double.tryParse(amountToPay) == null ||
                                double.parse(amountToPay) <= 0) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.paymentError(
                                      'Invalid amount: $amountToPay',
                                    ),
                                  ),
                                ),
                              );
                              return;
                            }

                            final chapa = Chapa.paymentParameters(
                              context: context,
                              publicKey:
                                  'CHAPUBK_TEST-voptMDn42ONLgwsUDFMy6bTYay96dvxL',
                              currency: 'ETB',
                              amount: amountToPay,
                              email: userData.email ?? '',
                              phone: userPhone,
                              firstName: userData.firstName ?? '',
                              lastName: userData.lastName ?? '',
                              txRef:
                                  transactionRef, // Use the generated PaymentRef for Chapa transaction reference
                              title: l10n.paymentTitle,
                              desc: l10n.paymentDescription(
                                widget.booking.travelId.toString(),
                              ),
                              nativeCheckout: true,
                              namedRouteFallBack: '',
                              showPaymentMethodsOnGridView: true,
                              availablePaymentMethods: const [
                                'mpesa',
                                'cbebirr',
                                'telebirr',
                                'ebirr',
                                'awash',
                                'abank',
                                'boa',
                              ],
                              onPaymentFinished: (
                                message,
                                reference, // This is Chapa's transaction reference
                                amount,
                              ) async {
                                if (!mounted) return;

                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();

                                print(
                                  '\n\n\n\tChapa payment finished callback triggered. Message: $message, Ref: $reference, Amount: $amount\n\n\n',
                                );
                                print(
                                  'Attempting to update booking status on backend from callback...',
                                );

                                String backendStatus;
                                print("\n\t\tInside the Payment\n");
                                print("$message\n\n");

                                
                                if (message == 'paymentSuccessful') {
                                  backendStatus = 'confirmed';
                                } else if (message == 'Invalid Test Number or Invalid OTP or payment method, please refer to our documentation.') {
                                  backendStatus = 'failed';
                                } else if (message == 'Transaction reference has been used before') {
                                  backendStatus = 'failed';
                                } else {
                                  backendStatus = 'unknown';
                                }

                                BookingStatus
                                bookingStatusUpdate = BookingStatus(
                                  bookingRef:
                                      widget.booking.bookingRef ??
                                      '', // Use the bookingRef from the original booking
                                  status: backendStatus,
                                );

                                BookingServices bookingServices =
                                    BookingServices();

                                print(
                                  '\n\t\tCalling updateBookingStatus with bookingRef: ${bookingStatusUpdate.bookingRef} and status: ${bookingStatusUpdate.status} \n\n',
                                );

                                Booking? updatedBooking;
                                String? backendUpdateError;

                                try {
                                  updatedBooking = await bookingServices
                                      .updateBookingStatus(
                                        bookingStatusUpdate,
                                        jwtToken,
                                      ); // Assuming this returns Booking?

                                  if (updatedBooking != null) {
                                    print(
                                      'Backend status update successful from callback. New status: ${updatedBooking.status}',
                                    );
                                  } else {
                                    print(
                                      'Failed to update booking status on backend from callback (API returned null).',
                                    );
                                    backendUpdateError = AppLocalizations.of(
                                      context,
                                    )!.paymentError(
                                      'Failed to finalize booking status on backend.',
                                    ); // Localize
                                  }
                                } catch (e) {
                                  print(
                                    'Error calling backend updateBookingStatus API from callback: $e',
                                  );
                                  backendUpdateError = AppLocalizations.of(
                                    context,
                                  )!.paymentError(
                                    'An error occurred while updating booking status.',
                                  ); // Localized error
                                }

                                if (mounted) {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => PaymentSuccessPage(
                                            // Pass the updated booking if available, otherwise the original
                                            booking:
                                                updatedBooking ??
                                                widget.booking,
                                            // Pass the backend update error message
                                            backendUpdateError:
                                                backendUpdateError,
                                          ),
                                    ),
                                    (Route<dynamic> route) =>
                                        false, // Remove all routes below success page
                                  );

                                  if (updatedBooking != null &&
                                      updatedBooking.status == 'confirmed') {
                                    // SnackBar shown on success page is often sufficient
                                  } else if (backendUpdateError != null) {
                                    // SnackBar shown on success page is often sufficient
                                  } else if (updatedBooking != null) {
                                    // Backend update successful but status is not confirmed
                                    // SnackBar shown on success page is often sufficient
                                  }
                                }
                              },
                            );

                            // Now, call initiatePayment on the instance returned by paymentParameters
                            chapa.initiatePayment();
                          } catch (e) {
                            // Check mounted state before using context
                            if (!mounted) return;
                            ScaffoldMessenger.of(
                              context,
                            ).hideCurrentSnackBar(); // Hide loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l10n.paymentError(e.toString())),
                              ), // Localized error message
                            );
                            print('Chapa payment initiation error: $e');
                          }
                        } else {
                          // Check mounted state before using context
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.loginRequiredForPayment,
                              ), // Localized
                            ),
                          );
                          // TODO: Optionally navigate to login page
                        }
                      },
                      child: Text(
                        l10n.payButtonLabel,
                      ), // Localized button label
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Optionally add a button to go back to bookings or home
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: () {
                        if (!mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ), // Navigate back to MainScreen or BookingsPage
                          (Route<dynamic> route) => false,
                        );
                      },
                      child: Text(
                        l10n.backToBookings,
                      ), // Localized button label
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
