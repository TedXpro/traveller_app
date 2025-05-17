import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/screens/main_screen.dart';
import 'package:traveller_app/screens/payment_success.dart'; // Import the updated PaymentSuccessPage
import 'package:traveller_app/screens/signin.dart';
import 'package:traveller_app/utils/theme.dart';
import 'package:traveller_app/providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:traveller_app/screens/notification_screen.dart';
import 'package:traveller_app/models/booking.dart'; // Import Booking model

// Define the background message handler as a top-level function
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
  // You can perform background tasks here, but UI updates are limited.
}

// Define a global key for your Navigator
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set up background message handler (if needed)
  // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request notification permissions (for iOS and Web)
  // await requestNotificationPermissions();

  runApp(MyApp());
}

Future<void> requestNotificationPermissions() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    print('User granted permission');
  } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
    print('User granted provisional permission');
  } else {
    print('User declined or has not accepted permission');
  }
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

  Future<void> setupInteractedMessage(BuildContext context) async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      _handleMessage(context, initialMessage);
    }

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleMessage(context, message);
    });
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    if (message.notification != null || message.data.isNotEmpty) {
      final notificationData = {
        'notification': message.notification?.toMap() ?? {},
        'data': message.data,
      };
      navigatorKey.currentState?.pushNamed(
        '/notification',
        arguments: {
          'notifications': [notificationData],
        },
      );
    } else {
      navigatorKey.currentState?.pushNamed('/notification');
    }
  }

  Future<Map<String, dynamic>> _loadAppData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('authToken');
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    await themeProvider.loadThemeMode();

    if (token != null && token.isNotEmpty) {
      await userProvider.loadUserDataAndToken();
    }

    setupFirebaseMessagingListeners(context);

    return {'token': token, 'userDataLoaded': userProvider.userData != null};
  }

  void setupFirebaseMessagingListeners(BuildContext context) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');
      if (message.notification != null) {
        print(
          'Message also contained a notification: ${message.notification!.body}',
        );
        // TODO: Display the notification using a local notification plugin if needed
      }
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setupInteractedMessage(context);
    });
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
                  supportedLocales: [Locale('en'), Locale('am')],
                  debugShowCheckedModeBanner: false,
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: _locale,
                  navigatorKey: navigatorKey,
                  routes: {
                    '/notification': (context) {
                      final arguments =
                          ModalRoute.of(context)?.settings.arguments;
                      List<Map<String, dynamic>>? initialNotifications;
                      if (arguments is Map<String, dynamic> &&
                          arguments.containsKey('initialNotifications')) {
                        initialNotifications =
                            arguments['initialNotifications']
                                as List<Map<String, dynamic>>?;
                      }
                      return NotificationScreen(
                        initialNotifications: initialNotifications,
                      );
                    },
                    '/payment_success': (context) {
                      // Check if the arguments are a Booking object (from explicit navigation)
                      final args = ModalRoute.of(context)?.settings.arguments;
                      if (args is Booking) {
                        print(
                          'Navigated to /payment_success with Booking object.',
                        );
                        return PaymentSuccessPage(booking: args);
                      }
                      // Check if the arguments are a Map<String, dynamic> (from Chapa fallback)
                      else if (args is Map<String, dynamic>) {
                        print(
                          'Navigated to /payment_success with Chapa response map.',
                        );
                        // Create a dummy Booking object or handle this case
                        // This scenario implies the explicit navigation failed.
                        // You might want to fetch the booking details here using the reference from the map,
                        // or navigate to an error state, or show a generic success message.
                        // For now, let's show an error indicating unexpected arguments.
                        print(
                          'Error: /payment_success route received Chapa map, but was expecting a Booking object.',
                        );
                        // You could potentially parse the map and fetch the booking here as a fallback
                        // but the current PaymentSuccessPage is designed to receive a Booking object.
                        // Returning MainScreen or an error page is a safer fallback if the expected Booking object is not received.
                        return const MainScreen(); // Fallback to MainScreen
                      }
                      // Handle missing or incorrect arguments
                      print(
                        'Error: Missing or incorrect arguments for /payment_success route. Expected Booking object or Chapa Map, got $args',
                      );
                      return const MainScreen(); // Fallback to MainScreen
                    },
                  },
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
                  supportedLocales: [Locale('en'), Locale('am')],
                  debugShowCheckedModeBanner: false,
                  home: initialScreen,
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: _locale,
                  navigatorKey: navigatorKey,
                  routes: {
                    '/notification': (context) {
                      final arguments =
                          ModalRoute.of(context)?.settings.arguments;
                      List<Map<String, dynamic>>? initialNotifications;
                      if (arguments is Map<String, dynamic> &&
                          arguments.containsKey('initialNotifications')) {
                        initialNotifications =
                            arguments['initialNotifications']
                                as List<Map<String, dynamic>>?;
                      }
                      return NotificationScreen(
                        initialNotifications: initialNotifications,
                      );
                    },
                    '/payment_success': (context) {
                      // Check if the arguments are a Booking object (from explicit navigation)
                      final args = ModalRoute.of(context)?.settings.arguments;
                      if (args is Booking) {
                        print(
                          'Navigated to /payment_success with Booking object.',
                        );
                        return PaymentSuccessPage(booking: args);
                      }
                      // Check if the arguments are a Map<String, dynamic> (from Chapa fallback)
                      else if (args is Map<String, dynamic>) {
                        print(
                          'Navigated to /payment_success with Chapa response map.',
                        );
                        print(
                          'Error: /payment_success route received Chapa map, but was expecting a Booking object.',
                        );
                        return const MainScreen(); // Fallback to MainScreen
                      }
                      // Handle missing or incorrect arguments
                      print(
                        'Error: Missing or incorrect arguments for /payment_success route. Expected Booking object or Chapa Map, got $args',
                      );
                      return const MainScreen(); // Fallback to MainScreen
                    },
                  },
                );
              } else {
                return MaterialApp(
                  localizationsDelegates: [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  supportedLocales: [Locale('en'), Locale('am')],
                  debugShowCheckedModeBanner: false,
                  home: const SignInPage(),
                  theme: lightTheme,
                  darkTheme: darkTheme,
                  themeMode: themeProvider.themeMode,
                  locale: _locale,
                  navigatorKey: navigatorKey,
                  routes: {
                    '/notification': (context) {
                      final arguments =
                          ModalRoute.of(context)?.settings.arguments;
                      List<Map<String, dynamic>>? initialNotifications;
                      if (arguments is Map<String, dynamic> &&
                          arguments.containsKey('initialNotifications')) {
                        initialNotifications =
                            arguments['initialNotifications']
                                as List<Map<String, dynamic>>?;
                      }
                      return NotificationScreen(
                        initialNotifications: initialNotifications,
                      );
                    },
                    '/payment_success': (context) {
                      // Check if the arguments are a Booking object (from explicit navigation)
                      final args = ModalRoute.of(context)?.settings.arguments;
                      if (args is Booking) {
                        print(
                          'Navigated to /payment_success with Booking object.',
                        );
                        return PaymentSuccessPage(booking: args);
                      }
                      // Check if the arguments are a Map<String, dynamic> (from Chapa fallback)
                      else if (args is Map<String, dynamic>) {
                        print(
                          'Navigated to /payment_success with Chapa response map.',
                        );
                        // Create a dummy Booking object or handle this case
                        // This scenario implies the explicit navigation failed.
                        // You might want to fetch the booking details here using the reference from the map,
                        // or navigate to an error state, or show a generic success message.
                        // For now, let's show an error indicating unexpected arguments.
                        print(
                          'Error: /payment_success route received Chapa map, but was expecting a Booking object.',
                        );
                        // You could potentially parse the map and fetch the booking here as a fallback
                        // but the current PaymentSuccessPage is designed to receive a Booking object.
                        // Returning MainScreen or an error page is a safer fallback if the expected Booking object is not received.
                        return const MainScreen(); // Fallback to MainScreen
                      }
                      // Handle missing or incorrect arguments
                      print(
                        'Error: Missing or incorrect arguments for /payment_success route. Expected Booking object or Chapa Map, got $args',
                      );
                      return const MainScreen(); // Fallback to MainScreen
                    },
                  },
                );
              }
            },
          );
        },
      ),
    );
  }
}
