import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:traveller_app/widgets/custom_app_bar.dart';
import 'package:traveller_app/widgets/custom_nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  // Sample list of cities
  final List<String> cities = [
    'Addis Ababa',
    'Bahir Dar',
    'Gondar',
    'Dire Dawa',
    'Mekelle',
    'Hawassa',
  ];

  @override
  Widget build(BuildContext context) {
    return CustomNavBar(
      child: Scaffold(
        appBar: CustomAppBar(),
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
      ),
    );
  }

  // Reusable welcome text widget
  Widget _buildWelcomeText() {
    return Text(
      'Welcome, [User Name]',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    );
  }

  // Reusable card for booking a trip
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
          ],
        ),
      ),
    );
  }

  // Reusable row for trip inputs (From, To)
  Widget _buildTripInputs() {
    return Row(
      children: [_buildFromInput(), const SizedBox(width: 10), _buildToInput()],
    );
  }

  // From TextField with GestureDetector
  Widget _buildFromInput() {
    return Expanded(
      child: GestureDetector(
        onTap: () => showSlidingPanel(context),
        child: TextField(
          controller: _fromController,
          decoration: const InputDecoration(
            labelText: 'From',
            suffixIcon: Icon(Icons.search),
          ),
        ),
      ),
    );
  }

  // To TextField
  Widget _buildToInput() {
    return Expanded(
      child: TextField(
        controller: _toController,
        decoration: const InputDecoration(labelText: 'To'),
      ),
    );
  }

  // Show sliding panel for city selection
  void showSlidingPanel(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SlidingUpPanel(
          minHeight: 0,
          maxHeight: MediaQuery.of(context).size.height * 0.6,
          panelBuilder: (sc) {
            return _buildCitySelectionPanel(sc);
          },
        );
      },
    );
  }

  // Reusable sliding panel for city selection
  Widget _buildCitySelectionPanel(ScrollController sc) {
    return SingleChildScrollView(
      controller: sc,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextField(
              decoration: InputDecoration(
                hintText: 'Search by city...',
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cities (A-Z)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildCityList(),
          ],
        ),
      ),
    );
  }

  // Reusable ListView for cities
  Widget _buildCityList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        itemCount: cities.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(cities[index]),
            onTap: () {
              setState(() {
                _fromController.text = cities[index];
              });
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
