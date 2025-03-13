import 'package:flutter/material.dart';
import 'package:traveller_app/widgets/custom_app_bar.dart';
import 'package:traveller_app/widgets/custom_nav_bar.dart';

class BookPage extends StatefulWidget {
  @override
  _BookPageState createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  bool isRoundTrip = true;
  DateTime? departureDate;
  DateTime? returnDate;

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

  @override
  Widget build(BuildContext context) {
    return CustomNavBar(
      child: Scaffold(
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
              TextField(decoration: InputDecoration(labelText: 'From')),
              SizedBox(height: 10),
        
              // To Section
              TextField(decoration: InputDecoration(labelText: 'To')),
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
      ),
    );
  }
}
