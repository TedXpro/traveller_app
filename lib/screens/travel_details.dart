import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:traveller_app/models/booking.dart';
import 'package:traveller_app/models/seat.dart';
import 'package:traveller_app/models/travel.dart';
import 'package:traveller_app/models/agency.dart';
import 'package:traveller_app/screens/booking_confirmation.dart';
import 'package:traveller_app/services/agency_api_services.dart';
import 'package:traveller_app/services/booking_api_services.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TravelDetailsPage extends StatefulWidget {
  final Travel travel;

  const TravelDetailsPage({super.key, required this.travel});

  @override
  _TravelDetailsPageState createState() => _TravelDetailsPageState();
}

class _TravelDetailsPageState extends State<TravelDetailsPage> {
  String agencyName = 'Loading...';
  final AgencyServices _agencyServices = AgencyServices();
  final Map<String, Agency> _agencyCache = {};
  final BookingServices _bookingServices = BookingServices();
  List<int> takenSeats = [];
  int? selectedSeat;

  @override
  void initState() {
    super.initState();
    _fetchAgencyName();
  }

  Future<void> _fetchAgencyName() async {
    if (_agencyCache.containsKey(widget.travel.agencyId)) {
      setState(() {
        agencyName = _agencyCache[widget.travel.agencyId]!.name;
      });
      return;
    }

    try {
      Agency? agency = await _agencyServices.fetchAgencyApi(
        widget.travel.agencyId,
      );
      if (agency != null) {
        setState(() {
          agencyName = agency.name;
          _agencyCache[widget.travel.agencyId] = agency;
        });
      } else {
        setState(() {
          agencyName = AppLocalizations.of(context)!.agencyNotFound;
        });
      }
    } catch (e) {
      print('Error fetching agency: $e');
      setState(() {
        agencyName = AppLocalizations.of(context)!.errorLoadingAgency;
      });
    }
  }

  Future<void> _bookTravel() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      String travelerId = userProvider.userData?.id ?? 'default_user_id';
      String paymentRef =
          'temp_payment_ref_${DateTime.now().millisecondsSinceEpoch}';
      DateTime now = DateTime.now().toUtc();
      DateTime bookTimeLimit = now.add(const Duration(minutes: 30));

      Seat seat = Seat(
        travelId: widget.travel.id,
        travelerId: travelerId,
        seatNo: 20,
        maxTime: bookTimeLimit,
      );

      await _bookingServices.chooseSeat(seat);
      print(AppLocalizations.of(context)!.seatChosen);

      Booking booking = Booking(
        travelId: widget.travel.id,
        travelerId: travelerId,
        seatNo: 20,
        tripType: 'One-way',
        startLocation: widget.travel.startLocation,
        paymentType: widget.travel.price,
        paymentRef: paymentRef,
        bookTime: DateTime.now().toUtc(),
        payTime: DateTime.now().toUtc(),
        bookTimeLimit: bookTimeLimit,
        status: 'Pending',
      );
      print(booking.toJson());
      print(AppLocalizations.of(context)!.bookingTravel);

      await _bookingServices.book(booking);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationPage(booking: booking),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
              context,
            )!.failedToBookTravel(e.toString()),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.travelDetails)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.agency(agencyName),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                      l10n.startLocation,
                      widget.travel.startLocation,
                    ),
                    _buildDetailRow(
                      l10n.destination,
                      widget.travel.destination,
                    ),
                    _buildDetailRow(
                      l10n.priceDisplay,
                      '\$${widget.travel.price.toStringAsFixed(2)}',
                    ),
                    _buildDetailRow(
                      l10n.departure,
                      DateFormat(
                        'MMM d, yyyy HH:mm',
                      ).format(widget.travel.plannedStartTime),
                    ),
                    _buildDetailRow(
                      l10n.arrival,
                      widget.travel.estArrivalTime != null
                          ? DateFormat(
                            'MMM d, yyyy HH:mm',
                          ).format(widget.travel.estArrivalTime!)
                          : l10n.notAvailable,
                    ),
                    _buildDetailRow(
                      l10n.driver,
                      widget.travel.driverName ?? l10n.notAssigned,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _bookTravel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(l10n.bookNow),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
