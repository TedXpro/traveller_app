import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/book.dart';
import 'package:traveller_app/services/travel_api_service.dart';
import 'package:traveller_app/utils/validation_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengers = 1;
  String? _departureLocation;
  String? _destinationLocation;
  String? errorMessage;
  String? departureLocationError;
  String? destinationLocationError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // Get AppLocalizations

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/ethiopian_city_logo.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(l10n), // Pass l10n
                  const SizedBox(height: 20),
                  _buildTripCard(l10n), // Pass l10n
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(AppLocalizations l10n) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.userData?.firstName ?? 'User';
        return Text(l10n.welcome(userName), // Localize "Welcome"
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        );
      },
    );
  }

  Widget _buildTripCard(AppLocalizations l10n) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bookATrip,
              style: const TextStyle(fontSize: 18),
            ), // Localize
            const SizedBox(height: 20),
            _buildDropdownInputs(l10n), // Pass l10n
            const SizedBox(height: 10),
            _buildDateInputs(l10n), // Pass l10n
            const SizedBox(height: 10),
            _buildPassengersInput(l10n), // Pass l10n
            const SizedBox(height: 20),
            _buildSearchButton(l10n), // Pass l10n
          ],
        ),
      ),
    );
  }

  /// 🔹 New Approach: Using Dropdown for Selecting Destinations
  Widget _buildDropdownInputs(AppLocalizations l10n) {
    final destinationProvider = Provider.of<DestinationProvider>(context);
    final destinations = destinationProvider.destinations;

    return Column(
      children: [
        _buildDropdown(
          label: l10n.selectDeparture, // Localize
          value: _departureLocation,
          items: destinations,
          onChanged: (value) {
            setState(() {
              _departureLocation = value;
              departureLocationError = validateLocation(_departureLocation);
            });
          },
          errorText: departureLocationError,
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              final temp = _departureLocation;
              _departureLocation = _destinationLocation;
              _destinationLocation = temp;
              departureLocationError = validateLocation(_departureLocation);
              destinationLocationError = validateLocation(_destinationLocation);
            });
          },
          child: Container(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey),
              ),
              padding: const EdgeInsets.all(8.0),
              child: const Icon(Icons.swap_vert),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildDropdown(
          label: l10n.selectDestination, // Localize
          value: _destinationLocation,
          items: destinations,
          onChanged: (value) {
            setState(() {
              _destinationLocation = value;
              destinationLocationError = validateLocation(_destinationLocation);
            });
          },
          errorText: destinationLocationError,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Destination> items,
    required void Function(String?) onChanged,
    String? errorText,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        errorText: errorText,
      ),
      items:
          items.map((destination) {
            return DropdownMenuItem<String>(
              value: destination.name,
              child: Text(destination.name),
            );
          }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildDateInputs(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateInput(l10n.departure, _departureDate, (date) {
                // Localize
                setState(() {
                  _departureDate = date;
                  errorMessage = validateDates(_departureDate, _returnDate);
                });
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDateInput(l10n.returnDate, _returnDate, (date) {
                // Localize
                setState(() {
                  _returnDate = date;
                  errorMessage = validateDates(_departureDate, _returnDate);
                });
              }),
            ),
          ],
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildDateInput(
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(date == null ? label : "${date.toLocal()}".split(' ')[0]),
            AnimatedOpacity(
              opacity: date != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child:
                  date != null
                      ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          onDateSelected(null);
                        },
                      )
                      : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersInput(AppLocalizations l10n) {
    return Row(
      children: [
        Text('${l10n.passengers}: '), // Localize
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
              () => setState(
                () => _passengers = (_passengers > 1) ? _passengers - 1 : 1,
              ),
        ),
        Text('$_passengers'),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _passengers++),
        ),
      ],
    );
  }

  Widget _buildSearchButton(AppLocalizations l10n) {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          departureLocationError = validateLocation(_departureLocation);
          destinationLocationError = validateLocation(_destinationLocation);
          errorMessage = validateDates(_departureDate, _returnDate);

          if (departureLocationError != null ||
              destinationLocationError != null ||
              errorMessage != null ||
              (_departureLocation != null &&
                  _destinationLocation != null &&
                  _departureLocation == _destinationLocation)) {
            setState(() {});

            String snackBarMessage;
            if (departureLocationError != null) {
              snackBarMessage = departureLocationError!;
            } else if (destinationLocationError != null) {
              snackBarMessage = destinationLocationError!;
            } else if (errorMessage != null) {
              snackBarMessage = errorMessage!;
            } else {
              snackBarMessage =
                  'Departure and destination locations cannot be the same.';
            }

            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(snackBarMessage)));
            return;
          }

          try {
            List<Travel>? travels = await searchTravelsApi(
              _departureLocation ?? "",
              _destinationLocation ?? "",
              _departureDate,
              _returnDate,
            );

            if (travels.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'No travels found for the selected criteria.',
                  ), // Localize
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookPage(travels: travels),
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e'))); // Localize
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: Text(l10n.searchTravel), // Localize
      ),
    );
  }
}
