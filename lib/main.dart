// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/screens/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    print(token);

    if (token != null && token.isNotEmpty) {
      // Token exists, user is logged in
      return MainScreen();
    } else {
      // No token, user is not logged in
      return const SignInPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => DestinationProvider()),
      ],
      child: Builder(
        builder: (context) {
          return FutureBuilder<Widget>(
            future: _getInitialScreen(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator(); // Show loading indicator
              } else if (snapshot.hasData) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: snapshot.data,
                );
              } else {
                return const MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: SignInPage(),
                ); // Default to SignInPage if error
              }
            },
          );
        },
      ),
    );
  }
}
