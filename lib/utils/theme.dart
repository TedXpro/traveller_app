import 'package:flutter/material.dart';

// Function to create a MaterialColor from a single Color (remains the same)
MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map<int, Color> swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  for (var strength in strengths) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  }
  return MaterialColor(color.value, swatch);
}

// Define the primary yellow accent color from the image
const Color _primaryYellow = Color(0xFFFFD700); // Example yellow color
const Color _darkScaffoldBackground = Colors.black;
const Color _darkCardColor = Color(
  0xFF1C1C1C,
); // Slightly lighter dark grey for cards
const Color _darkButtonTextColor = Color(
  0xFF1A1A1A,
); // Very dark grey/off-black for text on yellow buttons
const Color _darkChipBackgroundColor = Color(
  0xFF2C2C2C,
); // Background for unselected chips

ThemeData lightTheme = ThemeData(
  // ... your light theme definition remains the same
  brightness: Brightness.light,
  primarySwatch: Colors.green,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
    elevation: 0, // Remove shadow for consistency
    centerTitle: true, // Center the title if desired
  ),
  scaffoldBackgroundColor: Colors.grey[200], // Background color like SignUpPage
  cardColor: Colors.white,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black87), // Slightly darker text
    bodyMedium: TextStyle(color: Colors.black87),
    bodySmall: TextStyle(color: Colors.black54), // More subtle small text
    titleLarge: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ), // Bold titles
    titleMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: Colors.black87),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.black87),
    hintStyle: const TextStyle(color: Colors.black54),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey[400]!),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.green),
      borderRadius: BorderRadius.circular(10),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.red),
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: Colors.white,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 16,
    ), // Padding
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: Colors.green,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 24,
      ), // Padding
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.green,
      textStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: Colors.green,
    unselectedItemColor: Colors.grey[600],
    backgroundColor: Colors.white, // Background color
    elevation: 8, // Add a slight shadow
    type: BottomNavigationBarType.fixed, // Fixed layout
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.all(Colors.green),
  ),
  radioTheme: RadioThemeData(fillColor: WidgetStateProperty.all(Colors.green)),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: const TextStyle(color: Colors.black87),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(Colors.white),
      surfaceTintColor: WidgetStateProperty.all(Colors.white),
      elevation: WidgetStateProperty.all(8), // Menu shadow
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[400]!),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.green),
        borderRadius: BorderRadius.circular(10),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.red),
        borderRadius: BorderRadius.circular(10),
      ),
      fillColor: Colors.white,
      filled: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: 12,
        horizontal: 16,
      ), // Padding
    ),
  ),
  cardTheme: CardTheme(
    elevation: 4, // Card shadow
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  ),
  dialogTheme: DialogTheme(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    elevation: 8,
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: createMaterialColor(_primaryYellow),
  primaryColor: _primaryYellow,
  scaffoldBackgroundColor: _darkScaffoldBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: _darkScaffoldBackground, // Match scaffold background
    foregroundColor: Colors.white, // White text and icons
    elevation: 0, // Keep it flat
    centerTitle: true,
  ),
  cardColor: _darkCardColor,
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white70),
    bodySmall: TextStyle(color: Colors.white54),
    titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    titleSmall: TextStyle(color: Colors.white70),
    labelLarge: TextStyle(
      color: Colors.white,
    ), // For text on buttons if not overridden
    labelMedium: TextStyle(color: Colors.white70),
    labelSmall: TextStyle(color: Colors.white54),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: Colors.white70),
    hintStyle: const TextStyle(color: Colors.white54),
    // Added a yellow border for the default state
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: _primaryYellow.withOpacity(0.3),
      ), // Subtle yellow border
    ),
    // Modified enabled border to use a subtle yellow
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: _primaryYellow.withOpacity(0.3), // Subtle yellow border
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    // Focused border remains the primary yellow (stronger)
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(
        color: _primaryYellow, // Primary yellow border when focused
        width: 1.5,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
    errorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent),
      borderRadius: BorderRadius.circular(10),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      borderRadius: BorderRadius.circular(10),
    ),
    fillColor: _darkCardColor, // Match card color for input background
    filled: true,
    contentPadding: const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 16,
    ), // Adjusted padding
  ),
  textSelectionTheme: TextSelectionThemeData(
    cursorColor: _primaryYellow,
    selectionColor: _primaryYellow.withOpacity(
      0.4,
    ), // Slightly more opaque selection
    selectionHandleColor: _primaryYellow,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor:
          _darkButtonTextColor, // Dark text color for contrast on yellow
      backgroundColor: _primaryYellow, // Yellow background
      textStyle: const TextStyle(
        fontWeight: FontWeight.bold, // Keep bold
        fontSize: 16, // Standard button text size
      ),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 24,
      ), // Adjusted padding
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Consistent rounded corners
      ),
      elevation: 2, // Subtle elevation
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: _primaryYellow, // Yellow text for less prominent actions
      textStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ), // Slightly bolder
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    selectedItemColor: _primaryYellow,
    unselectedItemColor: Colors.white70,
    backgroundColor:
        _darkCardColor, // Or a slightly different dark shade like Color(0xFF181818)
    elevation:
        0, // Image suggests flat bottom nav, but can add small elevation if preferred
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(fontSize: 12),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _primaryYellow;
      }
      return Colors.white38; // Border color for unchecked
    }),
    checkColor: WidgetStateProperty.all(_darkButtonTextColor), // Dark checkmark
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
  ),
  radioTheme: RadioThemeData(
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return _primaryYellow;
      }
      return Colors.white38;
    }),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: const TextStyle(color: Colors.white70),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStateProperty.all(_darkCardColor),
      surfaceTintColor: WidgetStateProperty.all(_darkCardColor),
      elevation: WidgetStateProperty.all(4), // Reduced elevation
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 8)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      // Added Input Decoration to Dropdown theme as well
      // Consistent with general input fields
      filled: true,
      fillColor: _darkCardColor,
      hintStyle: const TextStyle(color: Colors.white54),
      // Added a yellow border for the default state
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: _primaryYellow.withOpacity(0.3),
        ), // Subtle yellow border
      ),
      // Modified enabled border to use a subtle yellow
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: _primaryYellow.withOpacity(0.3),
        ), // Subtle yellow border
        borderRadius: BorderRadius.circular(10),
      ),
      // Focused border remains the primary yellow (stronger)
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: _primaryYellow,
          width: 1.5,
        ), // Primary yellow border when focused
        borderRadius: BorderRadius.circular(10),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
  ),
  cardTheme: CardTheme(
    elevation: 0, // Image suggests flat cards
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        12,
      ), // Slightly larger radius for cards
      side: BorderSide(
        color: _primaryYellow.withOpacity(0.3),
        width: 1.0,
      ), // Added subtle yellow border
    ),
    color: _darkCardColor,
    margin: const EdgeInsets.symmetric(
      horizontal: 8,
      vertical: 6,
    ), // Default card margin
  ),
  dialogTheme: DialogTheme(
    backgroundColor: _darkCardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(
        color: _primaryYellow.withOpacity(0.5),
        width: 1.0,
      ), // Added a slightly more visible yellow border for dialogs
    ),
    elevation: 4, // Subtle elevation
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
    contentTextStyle: const TextStyle(color: Colors.white70, fontSize: 16),
  ),
  iconTheme: const IconThemeData(
    color: Colors.white70, // Default icon color can be slightly off-white
  ),
  primaryIconTheme: const IconThemeData(
    color: _primaryYellow, // Icons that should strongly use the accent
  ),

  // Added ChipThemeData
  chipTheme: ChipThemeData(
    backgroundColor:
        _darkChipBackgroundColor, // Background for unselected chips
    disabledColor: Colors.grey.shade800,
    selectedColor: _primaryYellow, // Yellow background for selected chips
    secondarySelectedColor: _primaryYellow, // Also yellow
    labelStyle: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w500,
    ), // Text style for unselected chips
    secondaryLabelStyle: TextStyle(
      color: _darkButtonTextColor,
      fontWeight: FontWeight.w600,
    ), // Text style for selected chips (dark text on yellow)
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    side: BorderSide.none, // No border for a flatter look
    elevation: 0,
    pressElevation: 2,
  ),
  // Modified divider color to be yellowish
  dividerColor: _primaryYellow.withOpacity(0.4), // Subtle yellowish divider
  // Added colorScheme for consistency, though not strictly required by your components here
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primaryYellow, // Base color for generating scheme
    brightness: Brightness.dark,
    primary: _primaryYellow, // Your primary yellow
    onPrimary: _darkButtonTextColor, // Text/icons on yellow buttons
    secondary: _primaryYellow, // Using yellow as secondary accent too
    onSecondary: _darkButtonTextColor, // Text/icons on secondary yellow
    surface: _darkCardColor, // Background for cards/sheets/menus
    onSurface: Colors.white70, // Text/icons on surface color
    background: _darkScaffoldBackground, // Scaffold background
    onBackground: Colors.white, // Text/icons on background
    error: Colors.redAccent, // Error color
    onError: Colors.white, // Text/icons on error color
  ).copyWith(
    surfaceContainerHighest: _darkChipBackgroundColor,
  ), // Use chip background for container areas if applicable
);
