import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:traveller_app/constants/api_constants.dart';
import 'package:traveller_app/models/events.dart';

class EventApiServices {
  Future<List<Event>?> getEvents(Map<String, String>? params) async {
    final url = Uri.https(searchUrl,'/event/all', params);

    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> eventData =
          jsonDecode(response.body) == null
              ? []
              : List<dynamic>.from(jsonDecode(response.body));

      List<Event> events =
          eventData
              .map(
                (dynamic item) => Event.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      return events;
    }

    return null;
  }
}
