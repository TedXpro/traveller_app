import 'package:flutter/material.dart';
import 'package:traveller_app/screens/home.dart';
import 'package:traveller_app/screens/book.dart';
// import 'package:traveller_app/screens/my_trips.dart';
// import 'package:traveller_app/screens/check_in.dart';

class CustomNavBar extends StatefulWidget {
  int currIndex;
  CustomNavBar({super.key, required this.currIndex});

  @override
  _CustomNavBarState createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {

  final List<Widget> _pages = [
    HomePage(),
    BookPage(travels: [],),
    // MyTripsPage(),
    // CheckInPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: widget.currIndex,
      onTap: (index) {
        setState(() {
          widget.currIndex = index;
        });
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => _pages[widget.currIndex]),
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
    );
  }
}
