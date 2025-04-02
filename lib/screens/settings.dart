import 'package:flutter/material.dart';
import 'package:traveller_app/utils/theme_utils.dart';
import 'package:traveller_app/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale _currentLocale = Locale('en'); // Default to English

  @override
  void initState() {
    super.initState();
    _currentLocale = Locale(
      WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(l10n.theme),
              subtitle: Text(l10n.changeAppTheme),
              onTap: () {
                showThemePickerDialog(context);
              },
            ),
            ListTile(
              title: Text(l10n.language),
              subtitle: Text(
                l10n.currentLanguage(
                  _getLanguageName(_currentLocale.languageCode),
                ),
              ),
              trailing: DropdownButton<Locale>(
                value: _currentLocale,
                items: [
                  DropdownMenuItem(
                    value: const Locale('en'),
                    child: Text(l10n.english),
                  ),
                  DropdownMenuItem(
                    value: const Locale('am'),
                    child: Text(l10n.amharic),
                  ),
                ],
                onChanged: (Locale? newLocale) {
                  if (newLocale != null) {
                    setState(() {
                      _currentLocale = newLocale;
                    });
                    _changeLocale(context, newLocale);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'am':
        return 'Amharic';
      default:
        return 'Unknown';
    }
  }

  void _changeLocale(BuildContext context, Locale locale) {
    final app = context.findAncestorStateOfType<MyAppState>();
    if (app != null) {
      app.setLocale(locale);
    }
  }
}
