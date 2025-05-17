// profile_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/screens/edit_profile.dart'; // Assuming EditProfilePage is here
import 'package:traveller_app/screens/settings.dart'; // Import SettingsPage
import 'package:traveller_app/screens/signin.dart'; // Assuming SignInPage is here
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  _logout(BuildContext context) async {
    // Check mounted before using context after an await
    if (!context.mounted) return;

    await Provider.of<UserProvider>(
      context,
      listen: false,
    ).clearUserDataAndToken();

    // Check mounted again before navigating
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context); // Access the current theme
    final colorScheme = theme.colorScheme; // Access the color scheme

    return Scaffold(
      // Scaffold background will pick up theme.scaffoldBackgroundColor automatically
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.userData;
          if (user == null) {
            // Use theme's text style for loading/error messages
            return Center(
              child: Text(
                'User data not loaded.', // Consider localizing this
                style: theme.textTheme.bodyMedium,
              ),
            );
          }
          return SingleChildScrollView(
            // Added SingleChildScrollView for potential overflow
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // Use theme's primary color for the user info section
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // --- START: Profile Picture Display ---
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            colorScheme
                                .onPrimary, // Contrasting color for avatar background
                        // Use NetworkImage if profilePhoto is available, otherwise null
                        backgroundImage:
                            (user.profilePhoto != null &&
                                    user.profilePhoto!.isNotEmpty)
                                ? NetworkImage(user.profilePhoto!)
                                    as ImageProvider<Object>?
                                : null, // No background image if no photo URL
                        // Show default icon only if no profile photo is available
                        child:
                            (user.profilePhoto == null ||
                                    user.profilePhoto!.isEmpty)
                                ? Icon(
                                  Icons.person,
                                  size: 40,
                                  color:
                                      colorScheme
                                          .primary, // Icon color contrasts with avatar background
                                )
                                : null, // No child if there's a background image
                      ),
                      // --- END: Profile Picture Display ---
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              // Handle potential nulls for firstName/lastName more gracefully if needed
                              '${user.firstName ?? ''} ${user.lastName ?? ''}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                // Text color contrasts with the primary background
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold, // Keep bold
                              ),
                            ),
                            const SizedBox(height: 4), // Reduced space slightly
                            Text(
                              user.email ??
                                  l10n.notAvailable, // Display email or 'Not Available'
                              style: theme.textTheme.bodyMedium?.copyWith(
                                // Text color contrasts with the primary background, slightly less prominent
                                color: colorScheme.onPrimary.withOpacity(0.8),
                              ),
                            ),
                            // Add phone number if available
                            if (user.phoneNumber != null &&
                                user.phoneNumber!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  user.phoneNumber!,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onPrimary.withOpacity(
                                      0.8,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Profile buttons will use theme's ElevatedButtonThemeData
                _buildProfileButton(context, Icons.edit, l10n.editProfile, () {
                  // Check mounted before navigating
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfilePage(user: user),
                    ),
                  );
                }, theme), // Pass theme
                _buildProfileButton(context, Icons.settings, l10n.settings, () {
                  // Check mounted before navigating
                  if (!context.mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                }, theme), // Pass theme
                _buildProfileButton(
                  context,
                  Icons.logout,
                  l10n.logOut,
                  () => _logout(context),
                  theme, // Pass theme
                ),
                // Add more profile options here if needed
              ],
            ),
          );
        },
      ),
    );
  }

  // Pass Theme to the button builder
  Widget _buildProfileButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onPressed,
    ThemeData theme, // Accept theme
  ) {
    final colorScheme = theme.colorScheme; // Access color scheme

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            double.infinity,
            50,
          ), // Keep full width and height
          shape: RoundedRectangleBorder(
            // Keep custom shape if desired
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: colorScheme.onPrimary,
            ), // Assuming button background is primary
            const SizedBox(width: 16),
            // Use theme's text style and color, contrasting with button background
            Expanded(
              // Use Expanded to prevent text overflow
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  // Using bodyLarge for button text
                  color:
                      colorScheme
                          .onPrimary, // Text color contrasts with button background
                ),
                overflow: TextOverflow.ellipsis, // Add overflow ellipsis
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onPrimary,
            ), // Use theme color for arrow icon
          ],
        ),
      ),
    );
  }
}
