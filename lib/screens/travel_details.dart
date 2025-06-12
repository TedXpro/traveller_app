import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting
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
import 'package:traveller_app/utils/validation_utils.dart'; // Ensure you have this utility for validation

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
  List<bool> seatStatusBooleans = [];
  int?
  selectedSeat; // Stores the 0-based index of the selected seat (e.g., 0 for seat 1, 1 for seat 2)
  bool _isLoadingSeats = true; // Loading state for fetching taken seats
  bool _isBooking = false; // Loading state for the booking process

  // Form Key for the new user details form
  final _userDetailsFormKey = GlobalKey<FormState>();

  // Controllers for user details
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAgencyName();
    _fetchTakenSeats(); // Fetch taken seats when the page initializes
    _prefillUserDetails(); // New: Prefill user details
  }

  // New method to prefill user details from UserProvider
  void _prefillUserDetails() {
    // We use Future.microtask to ensure that the Provider is available
    // and context is ready after the first build cycle.
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userData = userProvider.userData;

      if (userData != null) {
        _firstNameController.text = userData.firstName ?? '';
        _lastNameController.text = userData.lastName ?? '';
        _emailController.text = userData.email ?? '';
        _phoneController.text = userData.phoneNumber ?? '';
      }
    });
  }

  @override
  void dispose() {
    // Dispose controllers for user details
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
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
    final l10n = AppLocalizations.of(context)!;

    // Validate the new user details form
    if (!_userDetailsFormKey.currentState!.validate()) {
      // If validation fails, show a snackbar or just let the validators highlight errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseFillAllFields)));
      return;
    }

    // selectedSeat now holds the 0-based index
    if (selectedSeat == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.pleaseSelectSeat)));
      return;
    }

    // Ensure user data is loaded and accessible
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String? travelerId = userProvider.userData?.id;

    if (travelerId == null) {
      // Show error or navigate to login if user is required
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.loginRequiredForBooking)));
      // TODO: Optionally navigate to login page
      return;
    }

    // Prevent multiple booking attempts
    if (_isBooking) {
      return;
    }

    // Check if the selected seat (using 0-based index) is already taken
    // Ensure selectedSeat is within bounds before accessing seatStatusBooleans
    if (selectedSeat != null &&
        selectedSeat! >= 0 &&
        selectedSeat! < seatStatusBooleans.length &&
        seatStatusBooleans[selectedSeat!]) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // Display 1-based seat number in the message for the user
              l10n.paymentError('Seat ${selectedSeat! + 1} is already taken.'),
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
          content: Text(l10n.bookingTravel),
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
        seatNo: selectedSeat! + 1, // Sending 1-based seat number to backend
        maxTime: bookTimeLimit, // Pass the same time limit
      );

      print(
        "Sending 1-based seat number to backend (chooseSeat): ${selectedSeat! + 1}",
      );

      bool seatChosenSuccess = await _bookingServices.chooseSeat(seatToChoose);

      if (!mounted) return; // Check mounted after async operation

      if (!seatChosenSuccess) {
        ScaffoldMessenger.of(
          context,
        ).hideCurrentSnackBar(); // Hide booking loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.paymentError('Failed to choose seat. It might be taken.'),
            ), // Generic error for now
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isBooking = false;
        }); // Clear booking loading state
        _fetchTakenSeats(); // Re-fetch seats to show updated status
        return; // Stop if choosing seat failed
      }

      // If chooseSeat is successful, proceed to bookTravel
      Booking bookingToBook = Booking(
        id: '', // Backend will generate ID
        bookingRef: '', // Backend will generate bookingRef
        travelId: widget.travel.id,
        travelerId: travelerId,
        // Pass the updated user details from the form controllers
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email:
            _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
        phoneNumber:
            _phoneController.text.trim().isEmpty
                ? null
                : _phoneController.text.trim(),
        seatNo: selectedSeat! + 1, // Sending 1-based seat number to backend
        tripType: 'One-way', // Assuming 'One-way' for now
        startLocation: widget.travel.startLocation,
        destination: widget.travel.destination,
        price: widget.travel.price,
        bookTime: now,
        payTime: null,
        bookTimeLimit: bookTimeLimit,
        status: 'pending', // Initial status
      );

      print(
        "Sending 1-based seat number to backend (bookTravel): ${bookingToBook.toJson()}",
      );
      // The bookTravel method should return the created Booking object from the backend
      Booking? createdBooking = await _bookingServices.bookTravel(
        bookingToBook,
      );

      if (!mounted) return; // Check mounted after async operation

      ScaffoldMessenger.of(
        context,
      ).hideCurrentSnackBar(); // Hide booking loading
      setState(() {
        _isBooking = false;
      }); // Clear booking loading state

      if (createdBooking != null) {
        print("Booking created successfully: ${createdBooking.toJson()}");
        // Booking successful, navigate to confirmation page with the created booking
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              // Display 1-based seat number in success message for the user
              l10n.seatChosen(selectedSeat! + 1),
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
      } else {
        // Booking failed
        print("Booking API returned null after chooseSeat was successful.");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.failedToBookTravel(
                'Booking API returned null.',
              ), // Generic error
            ),
            backgroundColor: Colors.red,
          ),
        );
        // Consider re-fetching taken seats as the seat might not be booked
        _fetchTakenSeats();
      }
    } catch (e) {
      print('Error during booking process: $e');
      if (!mounted) return; // Check mounted after async operation
      ScaffoldMessenger.of(
        context,
      ).hideCurrentSnackBar(); // Hide booking loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.failedToBookTravel(e.toString())),
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

  // Widget to build a simple representation of a seat
  Widget _buildSeat(
    int seatIndex, // 0-based index (e.g., 0, 1, 2...)
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
        width: 45, // Adjusted seat size for better touch target
        height: 45, // Adjusted size as needed
        margin: const EdgeInsets.all(6), // Increased margin around seats
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            10,
          ), // More rounded corners for seats
          border: Border.all(
            color: borderColor,
            width: 1.5,
          ), // Slightly thicker border
          boxShadow:
              isSelected && !isTaken && !_isBooking
                  ? [
                    // Add a subtle shadow to selected seats
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          (seatIndex + 1)
              .toString(), // Display 1-based index for users (e.g., 1, 2, 3...)
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
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
          l10n.paymentError('No seat data available.'), // Localized message
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.error),
        ),
      );
    }

    List<Widget> rows = [];

    // Add driver position row (aligned to right)
    rows.add(
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 20.0, bottom: 10.0),
          child: Text(
            l10n.driver,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.grey[700],
            ),
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
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
          ), // Add vertical spacing between rows
          child: Row(
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
                width: 40,
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
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4.0,
          ), // Add vertical spacing for last row
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the row
            children: lastRowSeats,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16), // Increased padding
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(
          0.3,
        ), // Lighter background for the seat layout area
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(15), // More rounded container
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch to fill width
        children: rows,
      ),
    );
  }

  // Helper function to format DateTime for display using the desired format
  String _formatDateTime(DateTime dateTime, AppLocalizations l10n) {
    // Format: "Thursday, May 22, 2025 10:30 AM" (or PM)
    // l10n.localeName ensures the format is adapted to the user's locale (e.g., "en", "am")
    return DateFormat(
      'EEEE, MMMM d, replete hh:mm a', // Corrected to 'yyyy'
      l10n.localeName,
    ).format(dateTime.toLocal());
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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          Flexible(
            // Added Flexible to prevent overflow of long values
            child: Text(
              value,
              textAlign: TextAlign.end, // Align value to the right
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // New _buildUserDetailsForm method for the new form
  Widget _buildUserDetailsForm(AppLocalizations l10n, ThemeData theme) {
    return Form(
      key: _userDetailsFormKey,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.travelerDetails, // Add this key to your app_en.arb etc.
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              // Reusing _buildInputField for consistency
              _buildDetailInputField(
                l10n.firstName,
                _firstNameController,
                l10n,
                theme,
              ),
              _buildDetailInputField(
                l10n.lastName,
                _lastNameController,
                l10n,
                theme,
              ),
              _buildDetailInputField(
                l10n.email,
                _emailController,
                l10n,
                theme,
                isEmail: true,
              ),
              _buildDetailInputField(
                l10n.phoneNumber,
                _phoneController,
                l10n,
                theme,
                isPhone: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // A slightly modified input field builder for the details form
  // to better integrate with the card's visual style and specific validation needs.
  Widget _buildDetailInputField(
    String label,
    TextEditingController controller,
    AppLocalizations l10n,
    ThemeData theme, {
    bool isEmail = false,
    bool isPhone = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType:
            isEmail
                ? TextInputType.emailAddress
                : (isPhone ? TextInputType.phone : TextInputType.text),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium, // Use theme's text style
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withOpacity(0.7),
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(
            0.2,
          ), // Light fill
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ), // Adjust padding
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return l10n.thisFieldRequired;
          }
          if (isEmail && !isValidEmail(value.trim())) {
            return l10n.validEmail;
          }
          if (isPhone && !isValidPhoneNumber(value.trim())) {
            return l10n.validPhone;
          }
          // Basic name validation (non-empty is already covered)
          if (!isEmail && !isPhone && !isValidName(value.trim())) {
            return l10n.validFirstName; // Reusing for general name validation
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelDetails)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.agency(agencyName),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      l10n.startLocation,
                      widget.travel.startLocation,
                      theme,
                    ),
                    _buildDetailRow(
                      l10n.destination,
                      widget.travel.destination,
                      theme,
                    ),
                    _buildDetailRow(
                      l10n.priceDisplay,
                      '\$${widget.travel.price.toStringAsFixed(2)}',
                      theme,
                    ),
                    _buildDetailRow(
                      l10n.departure,
                      _formatDateTime(widget.travel.plannedStartTime, l10n),
                      theme,
                    ),
                    _buildDetailRow(
                      l10n.arrival,
                      widget.travel.estArrivalTime != null
                          ? _formatDateTime(widget.travel.estArrivalTime!, l10n)
                          : l10n.notAvailable,
                      theme,
                    ),
                    _buildDetailRow(
                      l10n.pickupLocations,
                      widget.travel.pickupLocations.join(', '),
                      theme,
                    ),
                    _buildDetailRow(
                      l10n.busReference,
                      widget.travel.busRef ?? l10n.notAvailable,
                      theme,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // NEW: User Details Form
            _buildUserDetailsForm(l10n, theme),
            const SizedBox(height: 20),

            Text(l10n.selectYourSeat, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),

            _buildBusSeatLayout(colorScheme),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed:
                    selectedSeat == null || _isBooking ? null : _bookTravel,
                child:
                    _isBooking
                        ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
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
}
