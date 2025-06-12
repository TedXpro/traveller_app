import 'package:flutter/material.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/models/agency.dart';
import 'package:traveller_app/screens/travel_details.dart';
import 'package:traveller_app/services/agency_api_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart'; // NEW: Import the intl package

class BookPage extends StatefulWidget {
  final List<Travel> travels;

  const BookPage({super.key, required this.travels});

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  double _minPrice = 0;
  // Initialize _maxPrice to a very large number or to the max price of available travels
  // This ensures all travels are shown by default if no max price is explicitly set.
  double _maxPrice = double.infinity;
  Map<String, String> agencyNames = {};
  final Map<String, Agency> _agencyCache = {};
  final AgencyServices _agencyServices = AgencyServices();

  // New state variable for selected agencies
  Set<String> _selectedAgencyIds = {};

  @override
  void initState() {
    super.initState();
    // _fetchAgencyNames will be called in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _fetchAgencyNames() here, as the context is now ready
    _fetchAgencyNames(context);

    // Initialize _maxPrice based on actual travel data if it's still infinity
    if (_maxPrice == double.infinity && widget.travels.isNotEmpty) {
      _maxPrice = widget.travels
          .map((e) => e.price)
          .reduce((a, b) => a > b ? a : b);
    }
  }

  Future<void> _fetchAgencyNames(BuildContext context) async {
    // Check mounted before using context after async operations
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    for (var travel in widget.travels) {
      if (!agencyNames.containsKey(travel.agencyId)) {
        if (_agencyCache.containsKey(travel.agencyId)) {
          if (mounted) {
            setState(() {
              agencyNames[travel.agencyId] =
                  _agencyCache[travel.agencyId]!.name;
            });
          }
          continue;
        }

        try {
          Agency? agency = await _agencyServices.fetchAgencyApi(
            travel.agencyId,
          );
          if (mounted) {
            if (agency != null) {
              setState(() {
                agencyNames[travel.agencyId] = agency.name;
                _agencyCache[travel.agencyId] = agency;
              });
            } else {
              setState(() {
                agencyNames[travel.agencyId] = l10n.unknownAgency;
              });
            }
          }
        } catch (e) {
          print("Error fetching agency: $e");
          if (mounted) {
            setState(() {
              agencyNames[travel.agencyId] = l10n.errorLoadingAgency;
            });
          }
        }
      }
    }
  }

  // New getter for filtered travels
  List<Travel> get filteredTravels {
    return widget.travels.where((travel) {
      final bool priceMatch =
          travel.price >= _minPrice && travel.price <= _maxPrice;
      // If _selectedAgencyIds is empty, it means "all agencies" are selected.
      // Otherwise, check if the travel's agencyId is in the selected set.
      final bool agencyMatch =
          _selectedAgencyIds.isEmpty ||
          _selectedAgencyIds.contains(travel.agencyId);
      return priceMatch && agencyMatch;
    }).toList();
  }

  // Method to reset all filters
  void _resetFilters() {
    setState(() {
      _minPrice = 0;
      _maxPrice =
          widget.travels.isNotEmpty
              ? widget.travels
                  .map((e) => e.price)
                  .reduce((a, b) => a > b ? a : b)
              : double.infinity; // Reset max price
      _selectedAgencyIds.clear(); // Clear selected agencies
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final List<Travel> currentFilteredTravels =
        filteredTravels; // Use the getter

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.availableTrips),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body:
          currentFilteredTravels.isEmpty
              ? Center(
                child: Text(
                  l10n.noTravelsFound, // Localize this
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              )
              : ListView.builder(
                itemCount: currentFilteredTravels.length,
                itemBuilder: (context, index) {
                  final travel = currentFilteredTravels[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(
                        Icons.directions_bus,
                        size: 36,
                        color: Colors.blue,
                      ),
                      title: Text(
                        '${travel.startLocation} to ${travel.destination}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.agency(
                              agencyNames[travel.agencyId] ?? l10n.loading,
                            ),
                          ),
                          Text(l10n.price(travel.price)),
                          // Display planned start time for more info
                          Text(
                            l10n.departureTime(
                              _formatDateTime(travel.plannedStartTime, l10n),
                            ),
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => TravelDetailsPage(travel: travel),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }

  // Helper function to format DateTime for display
  String _formatDateTime(DateTime dateTime, AppLocalizations l10n) {
    // NEW: Use DateFormat from intl package for user-friendly formatting
    // For "Thursday May 22, 2025" format:
    return DateFormat(
      'EEEE MMMM d, yyyy',
      l10n.localeName,
    ).format(dateTime.toLocal());
    // EEEE: Full weekday name (Thursday)
    // MMMM: Full month name (May)
    // d: Day of the month (22)
    // yyyy: Four-digit year (2025)
    // l10n.localeName ensures the format is adapted to the user's locale (e.g., "en", "am")
  }

  void _showFilterDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Store current filter values to revert if dialog is dismissed without applying
    double tempMinPrice = _minPrice;
    double tempMaxPrice = _maxPrice;
    Set<String> tempSelectedAgencyIds = Set.from(_selectedAgencyIds);

    // Determine the overall max price from all available travels for the slider max value
    final double overallMaxPrice =
        widget.travels.isNotEmpty
            ? widget.travels.map((e) => e.price).reduce((a, b) => a > b ? a : b)
            : 1000.0; // Default max if no travels

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.filterTrips),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                // Use SingleChildScrollView for potential overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Price Filter
                    Text(
                      l10n.priceRange(
                        tempMinPrice.toInt(),
                        tempMaxPrice.toInt(),
                      ),
                    ),
                    RangeSlider(
                      values: RangeValues(tempMinPrice, tempMaxPrice),
                      min: 0,
                      max: overallMaxPrice,
                      divisions: (overallMaxPrice / 10).round().clamp(
                        1,
                        100,
                      ), // Adjust divisions dynamically
                      labels: RangeLabels(
                        tempMinPrice.toInt().toString(),
                        tempMaxPrice.toInt().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          tempMinPrice = values.start;
                          tempMaxPrice = values.end;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Agency Filter
                    Text(
                      l10n.filterByAgency, // Localize this
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    // Option for "All Agencies"
                    CheckboxListTile(
                      title: Text(l10n.allAgencies), // Localize this
                      value: tempSelectedAgencyIds.isEmpty,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelectedAgencyIds
                                .clear(); // Select all by clearing the set
                          }
                        });
                      },
                    ),
                    // List of individual agencies
                    ...agencyNames.entries.map((entry) {
                      final String agencyId = entry.key;
                      final String agencyName = entry.value;
                      return CheckboxListTile(
                        title: Text(agencyName),
                        value: tempSelectedAgencyIds.contains(agencyId),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              tempSelectedAgencyIds.add(agencyId);
                            } else {
                              tempSelectedAgencyIds.remove(agencyId);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(l10n.resetFilters), // Localize this
              onPressed: () {
                setState(() {
                  // Use outer setState to update the main widget's state
                  _resetFilters();
                });
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(l10n.apply),
              onPressed: () {
                // Apply the temporary filter values to the main widget's state
                setState(() {
                  _minPrice = tempMinPrice;
                  _maxPrice = tempMaxPrice;
                  _selectedAgencyIds = tempSelectedAgencyIds;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
