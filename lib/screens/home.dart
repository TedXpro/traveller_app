import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/widgets/custom_app_bar.dart';
import 'package:traveller_app/widgets/custom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = '';

  @override
  void initState() {
    super.initState();
    _getUserName();
  }

  // Fetch user name from SharedPreferences
  _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName =
          prefs.getString('userName') ??
          'User'; // Default to 'User' if not found
    });
  }

  // Log out and clear user data from SharedPreferences
  _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userName'); // Remove user info from SharedPreferences
    prefs.remove('authToken'); // Remove the token as well
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SignInPage(),
      ), // Navigate back to sign-in page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      bottomNavigationBar: CustomNavBar(currIndex: 0),
    );
  }

  // Reusable welcome text widget
  Widget _buildWelcomeText() {
    return Text(
      'Welcome, $userName', // Display the user’s name
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
      child: TextField(decoration: const InputDecoration(labelText: 'To')),
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
          ],
        ),
      ),
    );
  }

  // Logout button
  Widget _buildLogoutButton() {
    return ElevatedButton(onPressed: _logout, child: const Text('Logout'));
  }
}
