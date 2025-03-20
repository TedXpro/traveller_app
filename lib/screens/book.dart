import 'package:flutter/material.dart';
import 'package:traveller_app/services/destination_api_services.dart';
import 'package:traveller_app/widgets/custom_app_bar.dart';
import 'package:traveller_app/widgets/custom_nav_bar.dart';
import 'package:traveller_app/models/destination.dart';

class BookPage extends StatefulWidget {
  const BookPage({super.key});

  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  bool isRoundTrip = true;
  DateTime? departureDate;
  DateTime? returnDate;
  String? selectedFromDestination;
  String? selectedToDestination;
  late Future<List<Destination>> _destinations;
  late TextEditingController _fromController;
  late TextEditingController _toController;

  @override
  void initState() {
    super.initState();
    _destinations = fetchDestinations(); // Fetch destinations once
    _fromController = TextEditingController();
    _toController = TextEditingController();
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isDeparture) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        if (isDeparture) {
          departureDate = pickedDate;
          if (returnDate != null && returnDate!.isBefore(pickedDate)) {
            returnDate =
                null; // Reset return date if it's before departure date
          }
        } else {
          returnDate = pickedDate;
        }
      });
    }
  }

  // Show the Modal Bottom Sheet for "From" field selection
  void _showFromDestinationSheet(
    BuildContext context,
    List<Destination> destinations,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          height:
              MediaQuery.of(context).size.height *
              0.75, // 75% of the screen height
          child: Column(
            children: [
              Text(
                'Select From Destination',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 10),
              // Display destinations as a row
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // Display in 3 columns
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: destinations.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFromDestination = destinations[index].name;
                          _fromController.text = selectedFromDestination!;
                        });
                        Navigator.pop(context); // Close the bottom sheet
                      },
                      child: Card(
                        child: Center(child: Text(destinations[index].name)),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // One-way and Round Trip Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ChoiceChip(
                  label: Text('One Way'),
                  selected: !isRoundTrip,
                  onSelected: (selected) {
                    setState(() {
                      isRoundTrip = !selected;
                    });
                  },
                ),
                ChoiceChip(
                  label: Text('Round Trip'),
                  selected: isRoundTrip,
                  onSelected: (selected) {
                    setState(() {
                      isRoundTrip = selected;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 20),

            // From Section
            FutureBuilder<List<Destination>>(
              future: _destinations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final destinations = snapshot.data!;

                  return DropdownButton<String>(
                    value: selectedFromDestination,
                    hint: Text('Select From'),
                    isExpanded: true, // Take up the full width
                    icon: Icon(Icons.arrow_drop_down),
                    items:
                        destinations.map((Destination destination) {
                          return DropdownMenuItem<String>(
                            value: destination.name,
                            child: Text(destination.name),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedFromDestination = newValue;
                        _fromController.text =
                            newValue ?? ''; // Retain selected destination
                      });
                    },
                  );
                } else {
                  return Text('No destinations found.');
                }
              },
            ),

            SizedBox(height: 10),

            // To Section
            FutureBuilder<List<Destination>>(
              future: _destinations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(); // Loading indicator
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final destinations = snapshot.data!;

                  return Autocomplete<Destination>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Destination>.empty();
                      }
                      return destinations.where((Destination destination) {
                        return destination.name.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        );
                      });
                    },
                    displayStringForOption: (Destination option) => option.name,
                    onSelected: (Destination selection) {
                      setState(() {
                        selectedToDestination = selection.name;
                      });
                      _toController.text = selection.name; // Retain selection
                    },
                    fieldViewBuilder: (
                      context,
                      controller,
                      focusNode,
                      onFieldSubmitted,
                    ) {
                      controller.text = selectedToDestination ?? '';
                      return TextField(
                        controller: _toController,
                        focusNode: focusNode,
                        decoration: InputDecoration(labelText: 'To'),
                        onSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                      );
                    },
                  );
                } else {
                  return Text('No destinations found.');
                }
              },
            ),

            SizedBox(height: 20),

            // Departure Date Picker
            ListTile(
              title: Text(
                departureDate == null
                    ? 'Select Departure Date'
                    : 'Departure: ${departureDate!.toLocal()}'.split(' ')[0],
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectDate(context, true),
            ),

            // Return Date Picker (Disabled if One-Way)
            ListTile(
              title: Text(
                returnDate == null
                    ? 'Select Return Date'
                    : 'Return: ${returnDate!.toLocal()}'.split(' ')[0],
              ),
              trailing: Icon(Icons.calendar_today),
              onTap: isRoundTrip ? () => _selectDate(context, false) : null,
              enabled: isRoundTrip,
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(currIndex: 1),
    );
  }
}
