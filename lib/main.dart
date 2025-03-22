import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/providers/destination_provider.dart'; // Import DestinationProvider
import 'package:traveller_app/screens/signin.dart';

void main() {
  runApp(MyApp()); // No need to wrap in ChangeNotifierProvider here
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Use MultiProvider to provide multiple providers
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(
          create: (context) => DestinationProvider(),
        ), // Add DestinationProvider here
      ],
      child: Builder(
        // Use Builder to get a context that has access to the providers
        builder: (context) {
          Provider.of<UserProvider>(context, listen: false).loadUserData();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: SignInPage(),
          );
        },
      ),
    );
  }
}
