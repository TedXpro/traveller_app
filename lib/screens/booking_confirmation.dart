// booking_confirmation_page.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/booking.dart'; // Assuming Booking model is correctly defined
import 'package:intl/intl.dart'; // For date formatting
import 'package:chapasdk/chapasdk.dart'; // For Chapa payment integration
import 'package:provider/provider.dart'; // For accessing UserProvider
import 'package:traveller_app/providers/user_provider.dart'; // Assuming you have this provider
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:traveller_app/screens/main_screen.dart'; // Import MainScreen for navigation

class BookingConfirmationPage extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationPage({super.key, required this.booking});

  // Helper to build detail rows (similar to BookingDetailsPage)
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
      // Use PopScope to control back navigation
      canPop: false, // Prevent popping back to the booking page directly
      onPopInvoked: (didPop) {
        if (didPop) return;
        // Instead of popping, navigate back to the main screen or bookings list
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainScreen(),
          ), // Or BookingsPage()
          (Route<dynamic> route) => false, // Remove all routes below MainScreen
        );
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.bookingConfirmationTitle), // Localized title
          // AppBar styling picks up theme.appBarTheme automatically
          automaticallyImplyLeading: false, // Hide the back button
        ),
        // Scaffold background picks up theme.scaffoldBackgroundColor automatically
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            // Center the confirmation card
            child: Container(
              // Using Container with decoration similar to Sign In/Up
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width * 0.9,
              constraints: const BoxConstraints(
                maxWidth: 450,
              ), // Max width for larger screens
              decoration: BoxDecoration(
                color: theme.cardColor, // Use theme's card color
                borderRadius: BorderRadius.circular(20),
                boxShadow:
                    theme.brightness == Brightness.light
                        ? [
                          // Show shadow in light mode
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                        : null, // No shadow in dark mode
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Make column fit content
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Confirmation Message
                  Text(
                    l10n.bookingConfirmedMessage, // Localized confirmation message
                    style: theme.textTheme.headlineSmall?.copyWith(
                      // Using headlineSmall
                      color:
                          colorScheme.primary, // Use primary color for emphasis
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Booking Details Summary
                  Text(
                    l10n.bookingSummary, // Localized section title
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(height: 24),

                  // Use the helper to display details
                  _buildDetailRow(
                    l10n.travelId,
                    booking.travelId.toString(),
                    theme,
                  ), // Assuming travelId can be non-string
                  _buildDetailRow(
                    l10n.seatNo,
                    booking.seatNo.toString(),
                    theme,
                  ), // Assuming seatNo can be non-string
                  _buildDetailRow(
                    l10n.bookTime,
                    DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(booking.bookTime), // Use full format for clarity
                    theme,
                  ),
                  _buildDetailRow(
                    l10n.paymentDue, // New localization key for payment due
                    DateFormat(
                      'yyyy-MM-dd HH:mm:ss',
                    ).format(booking.bookTimeLimit), // Use full format
                    theme,
                  ),
                  // Safely display payment amount, assuming it's a double or int
                  // Using paymentType here as in your original code, but assuming it holds the price
                  _buildDetailRow(
                    l10n.paymentAmount, // New localization key for payment amount
                    '${double.tryParse(booking.paymentType?.toString() ?? '0.0')?.toStringAsFixed(2) ?? l10n.notAvailable} ${l10n.currencyETB}', // Safely parse and format
                    theme,
                  ),

                  const SizedBox(height: 30),

                  // Chapa Payment Button
                  Align(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () async {
                        // async is still needed for context.mounted checks or future async operations
                        // Check mounted state before using context in async
                        if (!context.mounted) return;

                        final userProvider = Provider.of<UserProvider>(
                          context,
                          listen: false,
                        );
                        final userData = userProvider.userData;

                        if (userData != null) {
                          // Check mounted state before showing loading or using context
                          if (!context.mounted) return;
                          // Show a loading indicator or message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.initiatingPayment),
                            ), // Localized message
                          );

                          try {
                            // Ensure you have a valid transaction reference
                            String transactionRef =
                                booking.paymentRef.isNotEmpty
                                    ? booking.paymentRef
                                    : 'tx_${DateTime.now().microsecondsSinceEpoch}';
                            // Fallback phone number if user phone is null/empty
                            String userPhone =
                                userData.phoneNumber != null &&
                                        userData.phoneNumber!.isNotEmpty
                                    ? userData.phoneNumber!
                                    : '0900112233';

                            // Safely get amount, assuming paymentType holds the price as a string or can be converted
                            String amountToPay =
                                booking.paymentType?.toString() ?? '0';
                            if (double.tryParse(amountToPay) == null) {
                              // Handle invalid amount case
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar(); // Hide loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    l10n.paymentError('Invalid amount'),
                                  ),
                                ), // Localized error
                              );
                              return; // Stop if amount is invalid
                            }

                            // 1. Set the payment parameters (This static call seems ok)
                            Chapa.paymentParameters(
                              context: context,
                              publicKey: 'CHAPUBK_TEST-voptMDn42ONLgwsUDFMy6bTYay96dvxL', 
                              currency: 'ETB', 
                              amount: '5', 
                              email: 'johannes.woldeyes@gmail.com' ,
                              phone: "0900112233",
                              firstName: "Abe",
                              lastName: "Kebe",
                              txRef: "chappatest5-tx-12345678sss2abcMiniRocks",
                              title: "l10n.paymentTitle", 
                              desc: "l10n.paymentDescription(booking.travelId.toString(),)",
                              nativeCheckout: true,
                              // namedRouteFallBack: '/checkin', 
                              showPaymentMethodsOnGridView: true,
                              availablePaymentMethods: const [
                                'mpesa', // Example methods, confirm supported ones
                                'cbebirr',
                                'telebirr',
                                'ebirr',
                                // Add other methods supported by Chapa 0.0.7+1 if needed
                                'awash',
                                'abank',
                                'boa',
                              ],
                              onPaymentFinished: (message, reference, amount) {
                                Navigator.pop(context);
                              },
                              // onPaymentFinished parameter is NOT used here as per error
                            );

                            // Check mounted state after the (non-awaited) initiatePayment call
                            // as control might return here quickly before the UI closes
                            if (!context.mounted) return;

                            // Hide the initiating payment message immediately after calling initiatePayment
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();

                            // TODO: >>> IMPORTANT <<<
                            // The error "Instance member 'initiatePayment' can't be accessed using static access"
                            // means initiatePayment must be called on an INSTANCE, not on the static Chapa class.
                            // The method returns void, and the result is handled by a separate callback.

                            // You MUST consult the Chapa SDK documentation for version 0.0.7+1
                            // to find out:
                            // 1. How to obtain the instance that has the initiatePayment method.
                            //    (e.g., Is it returned by Chapa.paymentParameters? Is there a Chapa.getInitiator()?)
                            // 2. How to register the payment completion callback.
                            //    (e.g., Is there a Chapa.onPaymentResult listener? Is the callback set on the instance?)

                            // --- Placeholder for obtaining instance and calling initiatePayment ---
                            /*
                             // Example Hypothetical Usage (Check SDK Docs for actual API):
                             var chapaInitiator = // How you get the instance from the SDK? ;

                             // Example Hypothetical Callback Registration (Check SDK Docs):
                             // chapaInitiator.setOnPaymentResultCallback((message, reference, amount) {
                               // Handle result here (similar to the onPaymentFinished logic previously)
                               // Remember context.mounted checks inside callbacks
                             // });

                             // Now call initiatePayment on the instance
                             // chapaInitiator.initiatePayment(); // This call should now work on the instance
                             */
                            // --- End Placeholder ---
                          } catch (e) {
                            // Check mounted state before using context
                            if (!context.mounted) return;
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
                          if (!context.mounted) return;
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
                        if (!context.mounted) return;
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
