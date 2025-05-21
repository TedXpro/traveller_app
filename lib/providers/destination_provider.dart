// lib/providers/destination_provider.dart
import 'package:flutter/material.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/services/destination_api_services.dart';

class DestinationProvider with ChangeNotifier {
  List<Destination> _destinations = [];
  List<Destination> get destinations => _destinations;

  String? _selectedFromDestination;
  String? get selectedFromDestination => _selectedFromDestination;
  set selectedFromDestination(String? value) {
    _selectedFromDestination = value;
    notifyListeners();
  }

  String? _selectedToDestination;
  String? get selectedToDestination => _selectedToDestination;
  set selectedToDestination(String? value) {
    _selectedToDestination = value;
    notifyListeners();
  }

  DateTime? _departureDate;
  DateTime? get departureDate => _departureDate;
  set departureDate(DateTime? value) {
    _departureDate = value;
    notifyListeners();
  }

  DateTime? _returnDate;
  DateTime? get returnDate => _returnDate;
  set returnDate(DateTime? value) {
    _returnDate = value;
    notifyListeners();
  }

  bool _isRoundTrip = true;
  bool get isRoundTrip => _isRoundTrip;
  set isRoundTrip(bool value) {
    _isRoundTrip = value;
    notifyListeners();
  }

  final TextEditingController _fromController = TextEditingController();
  TextEditingController get fromController => _fromController;

  final TextEditingController _toController = TextEditingController();
  TextEditingController get toController => _toController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> fetchDestinations() async {
    if (_destinations.isNotEmpty) {
      // If destinations are already loaded, don't fetch again
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final destinationService = DestinationService();
      _destinations = await destinationService.fetchAllDestinations();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  void resetReturnDateIfBeforeDeparture() {
    if (_returnDate != null &&
        _departureDate != null &&
        _returnDate!.isBefore(_departureDate!)) {
      _returnDate = null;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }
}
