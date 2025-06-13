import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/destination.dart';
import 'package:traveller_app/models/events.dart';
import 'package:traveller_app/providers/destination_provider.dart';
import 'package:traveller_app/screens/event_card.dart';
import 'package:traveller_app/services/event_api_services.dart';

class EventPage extends StatefulWidget {
  const EventPage({super.key});

  @override
  _EventPageState createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  String title = '';
  Destination? selectedPlace;
  DateTime? fromDate;
  DateTime? toDate;

  final EventApiServices _eventApiServices = EventApiServices();
  List<Event>? events;
  late List<Destination> destinations;
  
  @override
  void initState() {
    final destinationProvider = Provider.of<DestinationProvider>(context, listen: false);
    destinations = destinationProvider.destinations;

    super.initState();
    initStateAsync();
  }

  void initStateAsync() async{
    events = await _eventApiServices.getEvents({'page' : '1'});
    setState(() {
      events = events;
    });
  }

  void _pickDate(BuildContext context, bool isFromDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });
    }
  }

  void _searchEvents() async{
    print(selectedPlace);
    var formattedFromDate = fromDate != null ? DateFormat('yyyy-MM-dd').format(fromDate!) : '';
    var formattedToDate = toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : '';
    final params = {
      'title': title,
      'destination_id': selectedPlace?.id ?? '',
      'date_min': formattedFromDate,
      'date_max': formattedToDate,
    };

    // set the page number
    params['page'] = '1';
    events = await _eventApiServices.getEvents(params);
    print(events);
    print(params['date_min']);
    print(params['date_max']);

    setState(() {
      events = events;
      print('Events updated: ${events?.length}');
    });
  }

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: AppBar(title: Text('Events')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Search by title'),
              onChanged: (val) => setState(() => title = val),
            ),
            DropdownButton<dynamic>(
              value: selectedPlace,
              hint: Text('Select place'),
              items: destinations.map((place) {
                return DropdownMenuItem<dynamic>(value: place, child: Text(place.name));
              }).toList(),
              onChanged: (val) => setState(() => selectedPlace = val),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _pickDate(context, true),
                  child: Row(children : [
                    Text(fromDate == null
                      ? 'From Date'
                      : fromDate!.toLocal().toString().split(' ')[0]),
                    SizedBox(width: 8,),
                    Icon(Icons.calendar_today)
                  ]
              )),
                Text('upto'),
                TextButton(
                  onPressed: () => _pickDate(context, false),
                  child: Row(children: [
                    Text(toDate == null
                      ? 'To Date'
                      : toDate!.toLocal().toString().split(' ')[0]
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.calendar_today),
                  ],)
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _searchEvents,
              icon: Icon(Icons.search),
              label: Text("Search"),
            ),
          
            Expanded(
              child: (events != null && events!.length > 0)?
              ListView.builder(
                itemCount: events == null ? 0 : events!.length,
                itemBuilder: (context, index) {
                  // final event = events[index];
                  return EventCard(
                    title: events![index].title,
                    location: events![index].destination_id,
                    date: events![index].date.toString(),
                    imageUrl: events![index].media, // Placeholder: use a real URL or local asset
                    description: events![index].desc,
                    // description: "In Flutter, the Expanded widget is used to make a child of a Column, Row, or Flex expand to fill the available space along the main axis (horizontal for Row, vertical for Column). In Flutter, the Expanded widget is used to make a child of a Column, Row, or Flex expand to fill the available space along the main axis (horizontal for Row, vertical for Column).",
                  );
                },
              )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          // AppLocalizations.of(context)!.tripNotSelected,
                          "No events found",
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
            )

          ],
        ),
      ),
    );
  }
}
