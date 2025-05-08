import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/models/seat.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/models/agency.dart';
import 'package:traveller_app/screens/booking_confirmation.dart';
import 'package:traveller_app/services/agency_api_services.dart';
import 'package:traveller_app/services/booking_api_services.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TravelDetailsPage extends StatefulWidget {
  final Travel travel;

  const TravelDetailsPage({super.key, required this.travel});

  @override
  _TravelDetailsPageState createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  String agencyName = 'Loading...';
  final AgencyServices _agencyServices = AgencyServices();
  final Map<String, Agency> _agencyCache = {};
  final BookingServices _bookingServices = BookingServices();
  List<int> takenSeats = [];
  int? selectedSeat;

  // Consider adding a loading state variable if fetching data takes time
  // bool _isLoadingAgency = true;

  @override
  void initState() {
    super.initState();
    _fetchAgencyName();
    // TODO: Also fetch taken seats for this travel if implementing seat selection
  }

  Future<void> _fetchAgencyName() async {
    // setState(() { _isLoadingAgency = true; }); // Example loading state update
    if (_agencyCache.containsKey(widget.travel.agencyId)) {
      setState(() {
        agencyName = _agencyCache[widget.travel.agencyId]!.name;
        // _isLoadingAgency = false; // Example loading state update
      });
      return;
    }

    try {
      Agency? agency = await _agencyServices.fetchAgencyApi(
        widget.travel.agencyId,
      );
      if (agency != null) {
        setState(() {
          agencyName = agency.name;
          _agencyCache[widget.travel.agencyId] = agency;
          // _isLoadingAgency = false; // Example loading state update
        });
      } else {
        setState(() {
          agencyName = AppLocalizations.of(context)!.agencyNotFound;
          // _isLoadingAgency = false; // Example loading state update
        });
      }
    } catch (e) {
      print('Error fetching agency: $e');
      setState(() {
        agencyName = AppLocalizations.of(context)!.errorLoadingAgency;
        // _isLoadingAgency = false; // Example loading state update
      });
    }
  }

  Future<void> _bookTravel() async {
    // TODO: Implement actual seat selection logic before booking
    if (selectedSeat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseSelectSeat,
          ), // Add this localization key
        ),
      );
      return; // Prevent booking if no seat is selected
    }

    try {
      // Ensure user data is loaded and accessible
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      // Check if user data is available before attempting to get ID
      String travelerId =
          userProvider.userData?.id ??
          'anonymous'; // Use a fallback like 'anonymous' or handle error
      if (travelerId == 'anonymous') {
        // Show error or navigate to login if user is required
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.loginRequiredForBooking,
            ), // Add this localization key
          ),
        );
        return;
      }

      String paymentRef =
          'temp_payment_ref_${DateTime.now().millisecondsSinceEpoch}';
      DateTime now = DateTime.now().toUtc();
      DateTime bookTimeLimit = now.add(const Duration(minutes: 30));

      // Only choose seat if it's not already taken (requires fetching taken seats)
      // if (takenSeats.contains(selectedSeat!)) {
      //    ScaffoldMessenger.of(context).showSnackBar(
      //      SnackBar(
      //        content: Text(l10n.seatAlreadyTaken), // Add localization
      //      ),
      //    );
      //    return;
      // }

      // Call chooseSeat with the selectedSeat
      Seat seat = Seat(
        travelId: widget.travel.id,
        travelerId: travelerId,
        seatNo: selectedSeat!, // Use the selected seat
        maxTime: bookTimeLimit,
      );

      await _bookingServices.chooseSeat(seat);
      print(
        AppLocalizations.of(context)!.seatChosen(selectedSeat!),
      ); // Use selected seat in message

      // Note: You are creating a Booking object here and navigating to confirmation,
      // but the await _bookingServices.book(booking) line is commented out.
      // Ensure you call the book API or handle the booking finalization later.
      Booking booking = Booking(
        travelId: widget.travel.id,
        travelerId: travelerId,
        seatNo: selectedSeat!, // Use the selected seat
        tripType: 'One-way', // This is hardcoded, might need to be dynamic
        startLocation: widget.travel.startLocation,
        paymentType: widget.travel.price,
        paymentRef: paymentRef,
        bookTime: DateTime.now().toUtc(),
        payTime:
            DateTime.now().toUtc(), // Pay time is usually later than book time
        bookTimeLimit: bookTimeLimit,
        status: 'Pending',
      );

      print(booking.toJson());
      print(AppLocalizations.of(context)!.bookingTravel);

      // Consider uncommenting the booking API call or handling booking finalization
      // await _bookingServices.book(booking);

      // Navigate to the confirmation page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(booking: booking),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.failedToBookTravel(e.toString()),
          ),
        ),
      );
    }
  }

  // Widget to build a simple representation of a seat
  Widget _buildSeat(
    int seatNumber,
    bool isTaken,
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isTaken) {
      backgroundColor = Colors.grey; // Use a grey for taken seats
      textColor = Colors.black54;
      borderColor = Colors.grey[700]!;
    } else if (isSelected) {
      // Use the primary color from the theme for selected seats
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary; // Color that contrasts with primary
      borderColor = colorScheme.primaryContainer; // A related color for border
    } else {
      // Use surface or card color for available seats
      backgroundColor =
          colorScheme.surface; // Or colorScheme.cardColor if defined
      textColor = colorScheme.onSurface; // Color that contrasts with surface
      borderColor = colorScheme.onSurface.withOpacity(
        0.5,
      ); // Subtle border for available
    }

    return InkWell(
      onTap:
          isTaken
              ? null
              : () {
                setState(() {
                  selectedSeat =
                      isSelected
                          ? null
                          : seatNumber; // Deselect if already selected
                });
              },
      child: Container(
        width: 40, // Adjust size as needed
        height: 40, // Adjust size as needed
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8), // Rounded corners for seats
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Text(
          seatNumber.toString(),
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget to build the seat layout (basic grid example)
  Widget _buildSeatLayout(ColorScheme colorScheme) {
    // This is a simplified example. You might need a more complex layout
    // depending on the actual bus/vehicle seat arrangement.
    const int seatsPerRow = 4; // Example: 2+2 arrangement
    const int totalSeats = 40; // Example total number of seats

    return GridView.builder(
      shrinkWrap: true, // Important for placing inside Column
      physics:
          const NeverScrollableScrollPhysics(), // To prevent scrolling within the column
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: seatsPerRow,
        crossAxisSpacing: 12.0, // Spacing between seats horizontally
        mainAxisSpacing: 12.0, // Spacing between seats vertically
        childAspectRatio: 1.0, // Make seats square
      ),
      itemCount: totalSeats,
      itemBuilder: (context, index) {
        final seatNumber = index + 1; // Seat numbers usually start from 1
        final isTaken = takenSeats.contains(seatNumber);
        final isSelected = selectedSeat == seatNumber;
        return _buildSeat(seatNumber, isTaken, isSelected, colorScheme);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Access the current theme data
    final theme = Theme.of(context);
    // Access the color scheme for dynamic colors
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // AppBar styling will pick up theme.appBarTheme automatically
      appBar: AppBar(
        title: Text(l10n.travelDetails),
        // Title text color will use theme.appBarTheme.foregroundColor or titleTextStyle
        // Background color will use theme.appBarTheme.backgroundColor
      ),
      body: SingleChildScrollView(
        // Use SingleChildScrollView if content might exceed screen height
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.agency(agencyName),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                // Use color scheme primary color
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            // Card styling will pick up theme.cardTheme automatically
            Card(
              // Removed hardcoded elevation and shape to use theme.cardTheme
              // elevation: 4,
              // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      l10n.startLocation,
                      widget.travel.startLocation,
                      theme, // Pass theme for text styling
                    ),
                    _buildDetailRow(
                      l10n.destination,
                      widget.travel.destination,
                      theme, // Pass theme
                    ),
                    _buildDetailRow(
                      l10n.priceDisplay,
                      '\$${widget.travel.price.toStringAsFixed(2)}',
                      theme, // Pass theme
                    ),
                    _buildDetailRow(
                      l10n.departure,
                      DateFormat(
                        'MMM d, yyyy HH:mm', // Corrected date format pattern
                      ).format(widget.travel.plannedStartTime),
                      theme, // Pass theme
                    ),
                    _buildDetailRow(
                      l10n.arrival,
                      widget.travel.estArrivalTime != null
                          ? DateFormat(
                            'MMM d, yyyy HH:mm', // Corrected date format pattern
                          ).format(widget.travel.estArrivalTime!)
                          : l10n.notAvailable,
                      theme, // Pass theme
                    ),
                    _buildDetailRow(
                      l10n.driver,
                      widget.travel.driverName ?? l10n.notAssigned,
                      theme, // Pass theme
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              l10n.selectYourSeat, // Add localization key
              style:
                  theme.textTheme.titleMedium, // Use theme's title medium style
            ),
            const SizedBox(height: 16),

            // Display the seat layout
            _buildSeatLayout(colorScheme),

            const SizedBox(height: 20),

            Center(
              // ElevatedButton styling will pick up theme.elevatedButtonTheme automatically
              child: ElevatedButton(
                onPressed:
                    selectedSeat == null
                        ? null
                        : _bookTravel, // Disable if no seat selected
                // Removed hardcoded style to use theme.elevatedButtonTheme
                // style: ElevatedButton.styleFrom(...),
                child: Text(l10n.bookNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Pass Theme or ColorScheme to the detail row builder
  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            // Use theme's text style or colorScheme for contrast
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color:
                  theme
                      .colorScheme
                      .onSurface, // Color that contrasts with card/surface
            ),
          ),
          Text(
            value,
            // Use theme's text style or colorScheme for contrast
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  theme
                      .colorScheme
                      .onSurface, // Color that contrasts with card/surface
            ),
          ),
        ],
      ),
    );
  }
}
