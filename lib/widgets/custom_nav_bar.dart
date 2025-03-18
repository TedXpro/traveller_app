import 'package:flutter/material.dart';
import 'package:traveller_app/screens/home.dart';
import 'package:traveller_app/screens/book.dart';
// import 'package:traveller_app/screens/my_trips.dart';
// import 'package:traveller_app/screens/check_in.dart';

class CustomNavBar extends StatefulWidget {
  final Widget child;
  const CustomNavBar({Key? key, required this.child}) : super(key: key);

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    BookPage(),
    // MyTripsPage(),
    // CheckInPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => _pages[index]),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bus_alert), label: 'Book'),
          BottomNavigationBarItem(icon: Icon(Icons.luggage), label: 'My Trips'),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Check-In',
          ),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
