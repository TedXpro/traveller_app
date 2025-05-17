// main_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/widgets/custom_app_bar.dart';
import 'package:traveller_app/widgets/custom_nav_bar.dart';
import 'package:traveller_app/screens/bookings.dart';
import 'package:traveller_app/screens/check_in.dart';
import 'package:traveller_app/screens/home.dart';
import 'package:traveller_app/screens/profile.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    BookingsPage(),
    CheckInPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Reload data from providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Reload data from providers
      // Use listen: false when calling methods in initState or postFrameCallback
      Provider.of<UserProvider>(context, listen: false).loadUserDataAndToken();
      Provider.of<DestinationProvider>(
        context,
        listen: false,
      ).fetchDestinations().then((_) { // Chain .then() to execute after fetch completes
         // Access the provider again (still with listen: false) to print the updated list
         final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);
         print('Fetched Destinations: ${destinationProvider.destinations}');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: CustomNavBar(
        // Use CustomNavBar
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
