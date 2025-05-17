// Import for json.decode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/models/seat.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/models/agency.dart';
import 'package:traveller_app/screens/booking_confirmation.dart';
import 'package:traveller_app/services/agency_api_services.dart';
import 'package:traveller_app/services/booking_api_services.dart'; // Assuming this is your BookingServices file
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
  final BookingServices _bookingServices =
      BookingServices(); // Use your BookingServices
  List<bool> seatStatusBooleans = []; // Store the raw boolean list from backend
  // Removed takenSeats list as we are now using the boolean list directly for display
  // List<int> takenSeats = []; // Store the list of taken seat numbers (1-based)
  int? selectedSeat; // Store the 0-based index of the selected seat
  bool _isLoadingSeats = true; // Loading state for fetching taken seats
  bool _isBooking = false; // Loading state for the booking process

  @override
  void initState() {
    super.initState();
    _fetchAgencyName();
    _fetchTakenSeats(); // Fetch taken seats when the page initializes
  }

  Future<void> _fetchAgencyName() async {
    if (_agencyCache.containsKey(widget.travel.agencyId)) {
      if (mounted) {
        setState(() {
          agencyName = _agencyCache[widget.travel.agencyId]!.name;
        });
      }
      return;
    }

    try {
      Agency? agency = await _agencyServices.fetchAgencyApi(
        widget.travel.agencyId,
      );
      if (mounted) {
        if (agency != null) {
          setState(() {
            agencyName = agency.name;
            _agencyCache[widget.travel.agencyId] = agency;
          });
        } else {
          setState(() {
            agencyName = AppLocalizations.of(context)!.agencyNotFound;
          });
        }
      }
    } catch (e) {
      print('Error fetching agency: $e');
      if (mounted) {
        setState(() {
          agencyName = AppLocalizations.of(context)!.errorLoadingAgency;
        });
      }
    }
  }

  // Method to fetch seat status from backend and update state
  Future<void> _fetchTakenSeats() async {
    if (mounted) {
      setState(() {
        _isLoadingSeats = true; // Set loading state
      });
    }
    try {
      // Call the BookingServices method which now returns List<bool>
      final fetchedSeatStatus = await _bookingServices.fetchTakenSeats(
        widget.travel.id,
      );

      if (mounted) {
        setState(() {
          seatStatusBooleans = fetchedSeatStatus; // Store the boolean list
          _isLoadingSeats = false; // Clear loading state on success
        });
      }
    } catch (e) {
      print('Error fetching taken seats: $e');
      if (mounted) {
        setState(() {
          _isLoadingSeats = false; // Clear loading state on error
          // Optionally show an error message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.paymentError('Failed to load taken seats.'),
              ), // Reusing paymentError key for a generic error message
              backgroundColor: Colors.red,
            ),
          );
        });
      }
    }
  }

  Future<void> _bookTravel() async {
    // selectedSeat now holds the 0-based index
    if (selectedSeat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectSeat)),
      );
      return;
    }

    // Ensure user data is loaded and accessible
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? travelerId = userProvider.userData?.id;

    if (travelerId == null) {
      // Show error or navigate to login if user is required
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.loginRequiredForBooking),
        ),
      );
      // TODO: Optionally navigate to login page
      return;
    }

    // Prevent multiple booking attempts
    if (_isBooking) {
      return;
    }

    // Check if the selected seat (using 0-based index) is already taken
    if (selectedSeat! >= 0 &&
        selectedSeat! < seatStatusBooleans.length &&
        seatStatusBooleans[selectedSeat!]) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // Display 1-based seat number in the message
              AppLocalizations.of(
                context,
              )!.paymentError('Seat ${selectedSeat! + 1} is already taken.'),
            ), // Use a localized message
            backgroundColor: Colors.orange, // Indicate a warning/info
          ),
        );
      }
      // Re-fetch taken seats to ensure UI is up-to-date
      _fetchTakenSeats();
      return; // Stop the booking process if the seat is taken
    }
    // --- End check for already taken seats ---

    if (mounted) {
      setState(() {
        _isBooking = true; // Set booking loading state
      });
      // Show a loading indicator or message for the booking process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.bookingTravel),
          duration: const Duration(
            seconds: 30,
          ), // Show for a reasonable duration
        ),
      );
    }

    try {
      DateTime now = DateTime.now().toUtc();
      DateTime bookTimeLimit = now.add(
        const Duration(minutes: 30),
      ); // Match backend reservation span

      // 1. Call the chooseSeat API
      Seat seatToChoose = Seat(
        travelId: widget.travel.id,
        travelerId: travelerId,
        seatNo: selectedSeat!, // Use the 0-based selectedSeat index
        maxTime: bookTimeLimit, // Pass the same time limit
      );

      bool seatChosenSuccess = await _bookingServices.chooseSeat(seatToChoose);

      if (!seatChosenSuccess) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).hideCurrentSnackBar(); // Hide booking loading
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(
                  context,
                )!.paymentError('Failed to choose seat. It might be taken.'),
              ), // Generic error for now
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isBooking = false;
          }); // Clear booking loading state
        }
        _fetchTakenSeats(); // Re-fetch seats to show updated status
        return; // Stop if choosing seat failed
      }

      // If chooseSeat is successful, proceed to bookTravel
      Booking bookingToBook = Booking(
        id: '', // Backend will generate ID
        bookingRef: '', // Backend will generate bookingRef
        travelId: widget.travel.id,
        travelerId: travelerId,
        seatNo: selectedSeat!, // Use the 0-based selectedSeat index
        tripType: 'One-way', // Assuming 'One-way' for now
        startLocation: widget.travel.startLocation,
        price: widget.travel.price,
        bookTime: now,
        payTime: null,
        bookTimeLimit: bookTimeLimit,
        status: 'pending', // Initial status
      );

      print(
        "Attempting to book travel with details: ${bookingToBook.toJson()}",
      );
      // The bookTravel method should return the created Booking object from the backend
      Booking? createdBooking = await _bookingServices.bookTravel(
        bookingToBook,
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide booking loading
        setState(() {
          _isBooking = false;
        }); // Clear booking loading state
      }

      if (createdBooking != null) {
        print("Booking created successfully: ${createdBooking.toJson()}");
        // Booking successful, navigate to confirmation page with the created booking
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                // Display 1-based seat number in success message
                AppLocalizations.of(context)!.seatChosen(selectedSeat! + 1),
              ), // Use selected seat in message
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => BookingConfirmationPage(
                    booking: createdBooking,
                  ), // Pass the created booking
            ),
          );
        }
      } else {
        // Booking failed
        print("Booking API returned null after chooseSeat was successful.");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.failedToBookTravel(
                  'Booking API returned null.',
                ), // Generic error
              ),
              backgroundColor: Colors.red,
            ),
          );
          // Consider re-fetching taken seats as the seat might not be booked
          _fetchTakenSeats();
        }
      }
    } catch (e) {
      print('Error during booking process: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide booking loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.failedToBookTravel(e.toString()),
            ),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isBooking = false;
        }); // Clear booking loading state
        // Consider re-fetching taken seats on error
        _fetchTakenSeats();
      }
    }
  }

  // Widget to build a simple representation of a seat
  Widget _buildSeat(
    int seatIndex, // 0-based index
    bool isTaken, // Now directly passed from the boolean list
    bool isSelected,
    ColorScheme colorScheme,
  ) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isTaken) {
      // Highlight taken seats with a light grey/white color
      backgroundColor = Colors.grey[300]!; // Light grey background
      textColor = Colors.black54; // Darker text for readability
      borderColor = Colors.grey[400]!; // Slightly darker border
    } else if (isSelected) {
      // Use the primary color from the theme for selected seats
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary; // Color that contrasts with primary
      borderColor = colorScheme.primaryContainer; // A related color for border
    } else {
      // Use surface or card color for available seats
      backgroundColor = colorScheme.surface; // Use theme's surface color
      textColor = colorScheme.onSurface; // Color that contrasts with surface
      borderColor = colorScheme.outline.withOpacity(
        0.5,
      ); // Lighter outline for available
    }

    return InkWell(
      onTap:
          isTaken ||
                  _isBooking // Disable tapping if taken or booking is in progress
              ? null
              : () {
                setState(() {
                  // Toggle selection: if this seat is already selected, deselect it
                  selectedSeat =
                      isSelected ? null : seatIndex; // Store 0-based index
                });
              },
      child: Container(
        width: 35, // Smaller seat size
        height: 40, // Adjust size as needed
        margin: const EdgeInsets.all(4), // Add some margin around seats
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8), // Rounded corners for seats
          border: Border.all(color: borderColor, width: 1),
          boxShadow:
              isSelected && !isTaken && !_isBooking
                  ? [
                    // Add a subtle shadow to selected seats
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.5),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          (seatIndex).toString(), // Display 0-based index
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Widget to build the bus seat layout
  Widget _buildBusSeatLayout(ColorScheme colorScheme) {
    // Use the length of the boolean list for the total number of seats
    final int totalSeats = seatStatusBooleans.length;
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingSeats) {
      return const Center(
        child: CircularProgressIndicator(),
      ); // Show loading indicator while fetching seats
    }

    // Handle the case where no seat data is loaded yet
    if (totalSeats == 0) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.paymentError('No seat data available.'),
        ), // Localized message
      );
    }

    List<Widget> rows = [];

    // Add driver position row
    rows.add(
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20.0, bottom: 10.0),
          child: Text(
            l10n.driver,
            style: Theme.of(context).textTheme.bodySmall,
          ), // Localize "Driver"
        ),
      ),
    );

    // Build rows with 2-2 layout for most seats
    // We iterate in steps of 4 for the 2-2 rows
    for (
      int i = 0;
      i <
          totalSeats -
              (totalSeats % 4 == 0 && totalSeats > 0 ? 4 : totalSeats % 4);
      i += 4
    ) {
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the row
          children: [
            _buildSeat(
              i,
              seatStatusBooleans[i],
              selectedSeat == i,
              colorScheme,
            ),
            _buildSeat(
              i + 1,
              seatStatusBooleans[i + 1],
              selectedSeat == i + 1,
              colorScheme,
            ),
            const SizedBox(
              width: 30,
            ), // Aisle space (increased for better visual)
            _buildSeat(
              i + 2,
              seatStatusBooleans[i + 2],
              selectedSeat == i + 2,
              colorScheme,
            ),
            _buildSeat(
              i + 3,
              seatStatusBooleans[i + 3],
              selectedSeat == i + 3,
              colorScheme,
            ),
          ],
        ),
      );
    }

    // Handle the last row (can have 1, 2, 3, or 4 seats together)
    int startIndexLastRow =
        totalSeats -
        (totalSeats % 4 == 0 && totalSeats > 0 ? 4 : totalSeats % 4);
    int remainingSeats = totalSeats - startIndexLastRow;

    if (remainingSeats > 0) {
      List<Widget> lastRowSeats = [];
      for (int i = startIndexLastRow; i < totalSeats; i++) {
        lastRowSeats.add(
          _buildSeat(i, seatStatusBooleans[i], selectedSeat == i, colorScheme),
        );
      }
      rows.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center the row
          children: lastRowSeats,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
        children: rows,
      ),
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
                        'MMM d, BBBB HH:mm', // Corrected date format pattern
                      ).format(widget.travel.plannedStartTime),
                      theme, // Pass theme
                    ),
                    _buildDetailRow(
                      l10n.arrival,
                      widget.travel.estArrivalTime != null
                          ? DateFormat(
                            'MMM d, BBBB HH:mm', // Corrected date format pattern
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

            // Display the bus seat layout
            _buildBusSeatLayout(colorScheme),

            const SizedBox(height: 20),

            Center(
              // ElevatedButton styling will pick up theme.elevatedButtonTheme automatically
              child: ElevatedButton(
                onPressed:
                    selectedSeat == null ||
                            _isBooking // Disable if no seat selected or booking in progress
                        ? null
                        : _bookTravel, // Disable if no seat selected
                // Removed hardcoded style to use theme.elevatedButtonTheme
                // style: ElevatedButton.styleFrom(...),
                child:
                    _isBooking // Show loading indicator on button if booking
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color:
                                colorScheme
                                    .onPrimary, // Match button text color
                            strokeWidth: 3,
                          ),
                        )
                        : Text(l10n.bookNow),
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
