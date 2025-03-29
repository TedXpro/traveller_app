import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/utils/theme.dart';
import 'package:traveller_app/providers/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Map<String, dynamic>> _loadAppData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    await themeProvider.loadThemeMode(); // Load theme mode

    if (token != null && token.isNotEmpty) {
      await userProvider.loadUserData(); // Load user data
    }

    return {'token': token, 'userDataLoaded': userProvider.userData != null};
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => DestinationProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Builder(
        builder: (context) {
          return FutureBuilder<Map<String, dynamic>>(
            future: _loadAppData(context),
            builder: (context, snapshot) {
              final themeProvider = Provider.of<ThemeProvider>(context);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasData) {
                final token = snapshot.data!['token'];
                final userDataLoaded = snapshot.data!['userDataLoaded'];

                Widget initialScreen =
                    token != null && token.isNotEmpty && userDataLoaded
                        ? MainScreen()
                        : const SignInPage();

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: initialScreen,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                );
              } else {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: const SignInPage(),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                );
              }
            },
          );
        },
      ),
    );
  }
}
