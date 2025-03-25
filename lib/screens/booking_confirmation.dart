import 'package:flutter/material.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:intl/intl.dart';
import 'package:chapasdk/chapasdk.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Booking booking;

  const BookingConfirmationPage({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Confirmation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking Confirmed!',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text('Travel ID: ${booking.travelId}'),
            Text('Seat Number: ${booking.seatNo}'),
            Text(
              'Book Time: ${DateFormat('MMM d, yyyy HH:mm').format(booking.bookTime)}',
            ),
            Text(
              'Payment Due: ${DateFormat('MMM d, yyyy HH:mm').format(booking.bookTimeLimit)}',
            ),
            Text(
              'Payment Amount: ${booking.paymentType} ETB',
            ), // Show payment amount
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final userProvider = Provider.of<UserProvider>(
                    context,
                    listen: false,
                  );
                  final userData = userProvider.userData;

                  if (userData != null) {
                    Chapa.paymentParameters(
                      context: context,
                      publicKey:
                          'CHAPUBK_TEST-voptMDn42ONLgwsUDFMy6bTYay96dvxL',
                      currency: 'ETB',
                      amount: booking.paymentType.toString(),
                      email: userData.email ?? 'default@example.com',
                      phone: "0900112233",
                      firstName: userData.firstName ?? 'Guest',
                      lastName: userData.lastName ?? 'User',
                      txRef: booking.paymentRef,
                      title: 'Order Payment',
                      desc: 'Payment for order #12345',
                      nativeCheckout: true,
                      namedRouteFallBack: "",
                      showPaymentMethodsOnGridView: true,
                      availablePaymentMethods: [
                        'mpesa',
                        'cbebirr',
                        'telebirr',
                        'ebirr',
                      ],
                      onPaymentFinished: (message, reference, amount) {
                        Navigator.pop(context);
                        if (message == "SUCCESS") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment successful!'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Payment failed: $message')),
                          );
                        }
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User data not found. Please log in.'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('PAY'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
