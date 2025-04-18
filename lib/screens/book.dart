import 'package:flutter/material.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/models/agency.dart';
import 'package:traveller_app/screens/travel_details.dart';
import 'package:traveller_app/services/agency_api_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class BookPage extends StatefulWidget {
  final List<Travel> travels;

  const BookPage({super.key, required this.travels});

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  double _minPrice = 0;
  double _maxPrice = double.infinity;
  Map<String, String> agencyNames = {};
  final Map<String, Agency> _agencyCache = {};
  final AgencyServices _agencyServices = AgencyServices();

  @override
  void initState() {
    super.initState();
    // _fetchAgencyNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _fetchAgencyNames() here, as the context is now ready
    _fetchAgencyNames(context);
  }

  Future<void> _fetchAgencyNames(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    for (var travel in widget.travels) {
      if (!agencyNames.containsKey(travel.agencyId)) {
        if (_agencyCache.containsKey(travel.agencyId)) {
          setState(() {
            agencyNames[travel.agencyId] = _agencyCache[travel.agencyId]!.name;
          });
          continue;
        }

        try {
          Agency? agency = await _agencyServices.fetchAgencyApi(
            travel.agencyId,
          );
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
        } catch (e) {
          print("Error fetching agency: $e");
          setState(() {
            agencyNames[travel.agencyId] = l10n.errorLoadingAgency;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    List<Travel> filteredTravels =
        widget.travels.where((travel) {
          return travel.price >= _minPrice && travel.price <= _maxPrice;
        }).toList();

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
      body: ListView.builder(
        itemCount: filteredTravels.length,
        itemBuilder: (context, index) {
          final travel = filteredTravels[index];
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
                    l10n.agency(agencyNames[travel.agencyId] ?? l10n.loading),
                  ),
                  Text(l10n.price(travel.price)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TravelDetailsPage(travel: travel),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.filterTrips),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.priceRange(_minPrice.toInt(), _maxPrice.toInt())),
                  RangeSlider(
                    values: RangeValues(_minPrice, _maxPrice),
                    min: 0,
                    max: widget.travels
                        .map((e) => e.price)
                        .reduce((a, b) => a > b ? a : b),
                    divisions: 10,
                    labels: RangeLabels(
                      _minPrice.toInt().toString(),
                      _maxPrice.toInt().toString(),
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _minPrice = values.start;
                        _maxPrice = values.end;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(l10n.apply),
              onPressed: () {
                setState(() {});
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
