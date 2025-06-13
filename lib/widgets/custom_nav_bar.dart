// custom_nav_bar.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations

class CustomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CustomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(icon: const Icon(Icons.home), label: l10n.home),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: l10n.bookings),
        BottomNavigationBarItem(
          icon: Icon(Icons.place),
          label: l10n.destinationsTitle,
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: l10n.profile),
        BottomNavigationBarItem(icon: Icon(Icons.event), label: l10n.events)
      ],
      currentIndex: selectedIndex,
      onTap: onItemTapped,
    );
  }
}
