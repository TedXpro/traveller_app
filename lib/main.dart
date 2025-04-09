import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/utils/theme.dart';
import 'package:traveller_app/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await dotenv.load(fileName: ".env"); // Load .env file here
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  Locale _locale = WidgetsBinding.instance.platformDispatcher.locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  Future<Map<String, dynamic>> _loadAppData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

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
                return MaterialApp(
                  localizationsDelegates: [
                    AppLocalizations.delegate, 
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('en'), // English
                    Locale('am'), // Amharic
                  ],
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: _locale, 
                );
              } else if (snapshot.hasData) {
                final token = snapshot.data!['token'];
                final userDataLoaded = snapshot.data!['userDataLoaded'];

                Widget initialScreen =
                    token != null && token.isNotEmpty && userDataLoaded
                        ? MainScreen()
                        : const SignInPage();

                return MaterialApp(
                  localizationsDelegates: [
                    AppLocalizations.delegate, 
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('en'), // English
                    Locale('am'), // Amharic
                  ],
                  debugShowCheckedModeBanner: false,
                  home: initialScreen,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: _locale, 
                );
              } else {
                return MaterialApp(
                  localizationsDelegates: [
                    AppLocalizations.delegate, 
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [
                    Locale('en'), // English
                    Locale('am'), // Amharic
                  ],
                  debugShowCheckedModeBanner: false,
                  home: const SignInPage(),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: _locale, 
                );
              }
            },
          );
        },
      ),
    );
  }
}
