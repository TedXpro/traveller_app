import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:traveller_app/models/advertisement.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/book.dart';
import 'package:traveller_app/services/advertisement_api_services.dart';
import 'package:traveller_app/services/travel_api_service.dart';
import 'package:traveller_app/utils/validation_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart'; // Import for DateFormat

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
  bool _hasSearchedAndNoResults = false; // NEW: State for showing no results UI

  int activeAdIndex = 0;

  List<Advertisement> _advertisements = [];

  @override
  void initState() {
    super.initState();
    // Initialize departure and destination locations if needed
    initStateAsync();
  }

  void initStateAsync() async {
    _advertisements = await AdvertisementApiServices().getAdvertisements();
    print("adverts $_advertisements");
    print(_advertisements[0].imageUrl + _advertisements[0].title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Stack(
        children: [
          // Background image
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
                  // NEW: Conditionally display no results message
                  if (_hasSearchedAndNoResults) ...[
                    const SizedBox(height: 40),
                    _buildNoResultsMessage(l10n, context),
                  ],
                  _buildAdvertisementCarousel(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementCarousel() {
    return Container(
      child: Column(
        children: [
          CarouselSlider.builder(
            options: CarouselOptions(
              height: 100,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 3),
              onPageChanged:
                  (index, reason) => setState(() {
                    activeAdIndex = index;
                  }),
            ),
            itemCount: _advertisements.length,
            itemBuilder: (context, index, realIndes) {
              final image = _advertisements[index].imageUrl;
              return buildAdvertisementCard(image, index);
            },
          ),

          buildAdIndicator(),
        ],
      ),
    );
  }

  Widget buildAdvertisementCard(String imageUrl, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: double.infinity,
          height: 100,
        ),
      ),
    );
  }

  Widget buildAdIndicator() {
    return AnimatedSmoothIndicator(
      activeIndex: activeAdIndex,
      count: _advertisements.length,
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
            // Customize text style for welcome message, e.g.,
            // color: theme.colorScheme.onSurface,
            // fontWeight: FontWeight.bold,
          ),
        );
      },
    );
  }

  Widget _buildTripCard(AppLocalizations l10n, BuildContext context) {
    return Card(
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
              _hasSearchedAndNoResults = false; // Reset on new input
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
              _hasSearchedAndNoResults = false; // Reset on new input
            });
          },
          child: Container(
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.5),
                ),
              ),
              padding: const EdgeInsets.all(8.0),
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
              _hasSearchedAndNoResults = false; // Reset on new input
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
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, errorText: errorText),
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
                  _hasSearchedAndNoResults = false; // Reset on new input
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
                  _hasSearchedAndNoResults = false; // Reset on new input
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
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label, // Use labelText for the hint
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          // Ensure suffix icon is shown
          suffixIcon:
              date != null
                  ? IconButton(
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
                  : Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: theme.iconTheme.color?.withOpacity(0.7),
                  ),
        ),
        // Display the selected date or label
        child: Text(
          date == null ? label : DateFormat('MMM d, yyyy').format(date),
          style:
              date == null
                  ? theme.inputDecorationTheme.hintStyle
                  : theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildPassengersInput(AppLocalizations l10n, BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text('${l10n.passengers}: ', style: theme.textTheme.bodyLarge),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed:
              () => setState(
                () => _passengers = (_passengers > 1) ? _passengers - 1 : 1,
              ),
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
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          // Reset error messages and no results flag at the start of a new search
          setState(() {
            departureLocationError = validateLocation(_departureLocation);
            destinationLocationError = validateLocation(_destinationLocation);
            errorMessage = validateDates(_departureDate, _returnDate);
            _hasSearchedAndNoResults =
                false; // Hide previous no results message
          });

          if (departureLocationError != null ||
              destinationLocationError != null ||
              errorMessage != null ||
              (_departureLocation != null &&
                  _destinationLocation != null &&
                  _departureLocation == _destinationLocation)) {
            String snackBarMessage;
            if (departureLocationError != null) {
              snackBarMessage = departureLocationError!;
            } else if (destinationLocationError != null) {
              snackBarMessage = destinationLocationError!;
            } else if (errorMessage != null) {
              snackBarMessage = errorMessage!;
            } else {
              snackBarMessage = l10n.sameLocationError; // NEW Localization key
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
              // Instead of a SnackBar, set the flag to display the custom UI
              setState(() {
                _hasSearchedAndNoResults = true;
              });
              // NO SNACKBAR HERE
            } else {
              // If travels are found, navigate to BookPage
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookPage(travels: travels),
                ),
              );
              // Reset the no results flag in case a previous search had none
              setState(() {
                _hasSearchedAndNoResults = false;
              });
            }
          } catch (e) {
            // Show general error message for API failures (e.g., network issues)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.searchError(e.toString()))),
            ); // NEW Localization key
            setState(() {
              _hasSearchedAndNoResults =
                  false; // Don't show no results for technical errors
            });
          }
        },
        child: Text(l10n.searchTravel),
      ),
    );
  }

  // NEW: Widget to display the no results message
  Widget _buildNoResultsMessage(AppLocalizations l10n, BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off, // A relevant icon
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noTravelsFoundSearch, // "No travels found for your search."
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.adjustSearchCriteria, // "Try adjusting your locations or dates."
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Reset all search fields and the no results flag
              setState(() {
                _departureDate = null;
                _returnDate = null;
                _passengers = 1;
                _departureLocation = null;
                _destinationLocation = null;
                errorMessage = null;
                departureLocationError = null;
                destinationLocationError = null;
                _hasSearchedAndNoResults = false;
              });
            },
            icon: const Icon(Icons.clear),
            label: Text(l10n.clearSearch), // "Clear Search"
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
