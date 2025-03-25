import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/book.dart';
import 'package:traveller_app/services/travel_api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime? _departureDate;
  DateTime? _returnDate;
  int _passengers = 1;
  String _departureLocation = '';
  String _destinationLocation = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeText(),
            const SizedBox(height: 20),
            _buildTripCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.userData?.firstName ?? 'User';
        return Text(
          'Welcome, $userName',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        );
      },
    );
  }

  Widget _buildTripCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Book a Trip', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildTripInputs(),
            const SizedBox(height: 10),
            _buildDateInputs(),
            const SizedBox(height: 10),
            _buildPassengersInput(),
            const SizedBox(height: 20),
            _buildSearchButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTripInputs() {
    return Column(
      children: [
        _buildLocationInput(_departureLocation, true),
        const SizedBox(height: 10),
        Container(
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
        const SizedBox(height: 10),
        _buildLocationInput(_destinationLocation, false),
      ],
    );
  }

  Widget _buildLocationInput(String hint, bool isFrom) {
    final controller = TextEditingController(
      text: isFrom ? _departureLocation : _destinationLocation,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: isFrom ? 'Select departure' : 'Select destination',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onChanged: (value) {
            setState(() {
              if (isFrom) {
                _departureLocation = value;
              } else {
                _destinationLocation = value;
              }
            });
          },
        ),
        if ((isFrom
            ? _departureLocation.isNotEmpty
            : _destinationLocation.isNotEmpty))
          _buildSuggestions(isFrom ? _departureLocation : _destinationLocation),
      ],
    );
  }

  Widget _buildSuggestions(String query) {
    final destinationProvider = Provider.of<DestinationProvider>(
      context,
      listen: false,
    );
    final suggestions =
        destinationProvider.destinations
            .where(
              (destination) =>
                  destination.name.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();

    if (query.isNotEmpty && suggestions.isNotEmpty) {
      return Container(
        constraints: const BoxConstraints(maxHeight: 200),
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final destination = suggestions[index];
            return ListTile(
              title: Text(destination.name),
              onTap: () {
                setState(() {
                  if (query == _departureLocation) {
                    _departureLocation = destination.name;
                  } else {
                    _destinationLocation = destination.name;
                  }
                });
              },
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildDateInputs() {
    return Row(
      children: [
        Expanded(
          child: _buildDateInput('Departure', _departureDate, (date) {
            setState(() => _departureDate = date);
          }),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildDateInput('Return', _returnDate, (date) {
            setState(() => _returnDate = date);
          }),
        ),
      ],
    );
  }

  Widget _buildDateInput(
    String label,
    DateTime? date,
    Function(DateTime) onDateSelected,
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
        child: Text(date == null ? label : "${date.toLocal()}".split(' ')[0]),
      ),
    );
  }

  Widget _buildPassengersInput() {
    return Row(
      children: [
        const Text('Passengers: '),
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

  Widget _buildSearchButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          try {
            List<Travel> travels = await searchTravelsApi(
              _departureLocation,
              _destinationLocation,
              _departureDate,
              _returnDate,
            );

            // Navigate to the BookPage and pass the travels list
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookPage(travels: travels),
              ),
            );
          } catch (e) {
            // Handle error (e.g., show a snackbar)
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error: $e')));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        ),
        child: const Text('Search Flights'),
      ),
    );
  }
}
