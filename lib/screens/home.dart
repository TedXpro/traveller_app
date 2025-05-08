import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/book.dart';
import 'package:traveller_app/services/travel_api_service.dart';
import 'package:traveller_app/utils/validation_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    // Access theme data for context-specific colors/styles if needed for complex cases
    // final theme = Theme.of(context);

    return Scaffold(
      // Scaffold background will be from the theme, but your Stack covers it.
      body: Stack(
        children: [
          // Background Image - This will cover the Scaffold's background color.
          // If you want the theme's background color visible, this needs to be conditional or transparent.
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
                  _buildWelcomeText(l10n, context), // Pass context for theme
                  const SizedBox(height: 20),
                  _buildTripCard(l10n, context), // Pass context for theme
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText(AppLocalizations l10n, BuildContext context) {
    final theme = Theme.of(context); // Get theme data
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.userData?.firstName ?? 'User';
        return Text(
          l10n.welcome(userName),
          style: theme.textTheme.titleLarge?.copyWith(
            // Use a theme text style
            // fontWeight: FontWeight.bold, // titleLarge is already bold by theme
            // If you need to override only specific parts of the theme's text style:
            // color: theme.textTheme.titleLarge?.color?.withOpacity(0.9)
          ),
        );
      },
    );
  }

  Widget _buildTripCard(AppLocalizations l10n, BuildContext context) {
    // The Card widget will now use cardTheme from your ThemeData
    // If you removed local elevation and shape from Card, it will use theme's
    return Card(
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Keep if specific, or remove to use cardTheme.shape
      // elevation: 5, // Keep if specific, or remove to use cardTheme.elevation (which is 0 in your darkTheme)
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.bookATrip,
              style:
                  Theme.of(
                    context,
                  ).textTheme.titleMedium, // Use a theme text style
            ),
            const SizedBox(height: 20),
            _buildDropdownInputs(l10n, context), // Pass context
            const SizedBox(height: 10),
            _buildDateInputs(l10n, context), // Pass context
            const SizedBox(height: 10),
            _buildPassengersInput(l10n, context), // Pass context
            const SizedBox(height: 20),
            _buildSearchButton(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownInputs(AppLocalizations l10n, BuildContext context) {
    final destinationProvider = Provider.of<DestinationProvider>(context);
    final destinations = destinationProvider.destinations;
    final theme = Theme.of(context); // Get theme

    return Column(
      children: [
        _buildDropdown(
          label: l10n.selectDeparture,
          value: _departureLocation,
          items: destinations,
          onChanged: (value) {
            setState(() {
              _departureLocation = value;
              departureLocationError = validateLocation(_departureLocation);
            });
          },
          errorText: departureLocationError,
          context: context, // Pass context
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
                // Use theme color for border
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.all(8.0),
              // Icon color will be inherited from IconTheme
              child: Icon(Icons.swap_vert, color: theme.iconTheme.color),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildDropdown(
          label: l10n.selectDestination,
          value: _destinationLocation,
          items: destinations,
          onChanged: (value) {
            setState(() {
              _destinationLocation = value;
              destinationLocationError = validateLocation(_destinationLocation);
            });
          },
          errorText: destinationLocationError,
          context: context, // Pass context
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
    required BuildContext context, // Added context
  }) {
    // DropdownButtonFormField will use dropdownMenuTheme.inputDecorationTheme or inputDecorationTheme
    // The InputDecoration provided here can override parts of it.
    // For full theme application, define less in the local InputDecoration.
    return DropdownButtonFormField<String>(
      value: value,
      // The decoration here will merge with or override the theme's inputDecorationTheme.
      // To fully use the theme, you might remove local `border` if the theme provides it sufficiently.
      decoration: InputDecoration(
        labelText: label,
        // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // This overrides theme's border style if uncommented
        errorText: errorText,
        // Other properties like fillColor, hintStyle, labelStyle will come from the theme
        // if not specified here.
      ),
      items:
          items.map((destination) {
            return DropdownMenuItem<String>(
              value: destination.name,
              // Text style within dropdown items will also try to inherit
              child: Text(destination.name),
            );
          }).toList(),
      onChanged: onChanged,
      // dropdownColor: Theme.of(context).cardColor, // Example: explicit dropdown background
    );
  }

  Widget _buildDateInputs(AppLocalizations l10n, BuildContext context) {
    final theme = Theme.of(context); // Get theme
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDateInput(context, l10n.departure, _departureDate, (
                date,
              ) {
                setState(() {
                  _departureDate = date;
                  errorMessage = validateDates(_departureDate, _returnDate);
                });
              }),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDateInput(context, l10n.returnDate, _returnDate, (
                date,
              ) {
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
              // Use theme's error color
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
      ],
    );
  }

  Widget _buildDateInput(
    BuildContext context, // Pass context
    String label,
    DateTime? date,
    Function(DateTime?) onDateSelected,
  ) {
    final theme = Theme.of(context);
    // To make this look like a themed input field, we can use InputDecorator
    return InkWell(
      onTap: () async {
        final selectedDate = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
          // DatePicker theme is also controlled by ThemeData (dialogTheme, colorScheme)
        );
        if (selectedDate != null) {
          onDateSelected(selectedDate);
        }
      },
      child: InputDecorator(
        // Wrap with InputDecorator to use theme's input field styling
        decoration: InputDecoration(
          // Use properties from theme's inputDecorationTheme
          // border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), // Can keep specific border if needed
          // enabledBorder, focusedBorder, fillColor etc. will come from the theme.
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ), // Adjust padding as needed
        ),
        child: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align text and icon
          children: [
            Text(
              date == null ? label : "${date.toLocal()}".split(' ')[0],
              // Text color will be inherited (should be light on dark theme)
              style:
                  date == null
                      ? theme.inputDecorationTheme.hintStyle
                      : theme.textTheme.bodyLarge,
            ),
            if (date != null)
              IconButton(
                icon: Icon(
                  Icons.clear,
                  size: 20,
                  color: theme.iconTheme.color?.withOpacity(0.7),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {
                  onDateSelected(null);
                },
              )
            else
              Icon(
                Icons.calendar_today,
                size: 20,
                color: theme.iconTheme.color?.withOpacity(0.7),
              ), // Show calendar icon if no date
          ],
        ),
      ),
    );
  }

  Widget _buildPassengersInput(AppLocalizations l10n, BuildContext context) {
    final theme = Theme.of(context);
    // Text and Icon colors will be inherited from the theme
    return Row(
      children: [
        Text('${l10n.passengers}: ', style: theme.textTheme.bodyLarge),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
              () => setState(
                () => _passengers = (_passengers > 1) ? _passengers - 1 : 1,
              ),
          // Icon color and splash from theme
        ),
        Text('$_passengers', style: theme.textTheme.titleMedium),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => setState(() => _passengers++),
        ),
      ],
    );
  }

  Widget _buildSearchButton(AppLocalizations l10n) {
    // ElevatedButton will now use elevatedButtonTheme from your ThemeData
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // ... your existing validation and navigation logic ...
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
                  content: Text('No travels found for the selected criteria.'),
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
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
        child: Text(l10n.searchTravel),
      ),
    );
  }
}
