import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension AppLocalizationsX on AppLocalizations {
  String getBookingStatusLocalized(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return bookingStatusPending;
      case 'confirmed':
        return bookingStatusConfirmed;
      case 'cancelled':
        return bookingStatusCancelled;
      case 'failed':
        return bookingStatusFailed;
      // Add other status cases as needed
      default:
        return unknownStatus;
    }
  }
}
