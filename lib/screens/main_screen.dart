// main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/destinations_list_page.dart';
import 'package:traveller_app/screens/event.dart';
import 'package:traveller_app/widgets/custom_app_bar.dart';
import 'package:traveller_app/widgets/custom_nav_bar.dart';
import 'package:traveller_app/screens/bookings.dart';
// import 'package:traveller_app/screens/check_in.dart';
import 'package:traveller_app/screens/home.dart';
import 'package:traveller_app/screens/profile.dart';
import 'package:traveller_app/screens/event.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // REMOVED 'static const' to allow dynamic page creation with callbacks
  late List<Widget> _pages; // Declared as late, initialized in initState

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    // Initialize _pages here, passing the callback to BookingsPage
    _pages = <Widget>[
      const HomePage(), // Index 0: Home Page
      BookingsPage(
        // Index 1: Bookings Page
        // Pass a callback function that will change the MainScreen's selected index
        onNavigateToHome: () {
          _onItemTapped(0); // Navigate to Home tab (assuming Home is index 0)
        },
      ),
      const DestinationsListPage(), // Index 2: Destinations List Page
      // CheckInPage(), // If you uncomment this, ensure it's a const widget if possible
      const ProfilePage(), // Index 3: Profile Page
      const EventPage(),
    ];

    // Reload data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use listen: false when calling methods in initState or postFrameCallback
      Provider.of<UserProvider>(context, listen: false).loadUserDataAndToken();
      Provider.of<DestinationProvider>(
        context,
        listen: false,
      ).fetchDestinations().then((_) {
        // Chain .then() to execute after fetch completes
        // Access the provider again (still with listen: false) to print the updated list
        final destinationProvider = Provider.of<DestinationProvider>(
          context,
          listen: false,
        );
        print('Fetched Destinations: ${destinationProvider.destinations}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        // Use IndexedStack to preserve the state of tabs when switching
        child: IndexedStack(index: _selectedIndex, children: _pages),
      ),
      bottomNavigationBar: CustomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
