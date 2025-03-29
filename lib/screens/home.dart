import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/destination.dart';
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
  String? _departureLocation;
  String? _destinationLocation;

  @override
  Widget build(BuildContext context) {
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
                  _buildWelcomeText(),
                  const SizedBox(height: 20),
                  _buildTripCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final userName = userProvider.userData?.firstName ?? 'User';
        return Text(
          'Welcome, $userName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
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
            _buildDropdownInputs(),
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

  /// 🔹 New Approach: Using Dropdown for Selecting Destinations
  Widget _buildDropdownInputs() {
    final destinationProvider = Provider.of<DestinationProvider>(context);
    final destinations = destinationProvider.destinations;

    return Column(
      children: [
        _buildDropdown(
          label: "Select Departure",
          value: _departureLocation,
          items: destinations,
          onChanged: (value) => setState(() => _departureLocation = value),
        ),
        const SizedBox(height: 10),
        // 🔄 Swap Button
        GestureDetector(
          onTap: () {
            setState(() {
              // Swap departure and destination
              final temp = _departureLocation;
              _departureLocation = _destinationLocation;
              _destinationLocation = temp;
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
          label: "Select Destination",
          value: _destinationLocation,
          items: destinations,
          onChanged: (value) => setState(() => _destinationLocation = value),
        ),
      ],
    );
  }


  /// Generic Dropdown Builder
  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<Destination> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
              _departureLocation ?? "",
              _destinationLocation ?? "",
              _departureDate,
              _returnDate,
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookPage(travels: travels),
              ),
            );
          } catch (e) {
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
