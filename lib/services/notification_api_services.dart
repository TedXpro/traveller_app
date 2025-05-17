import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/notification.dart'; // Import your notification models
import 'package:traveller_app/constants/api_constants.dart'; // Assuming your API base URL is here

Future<List<CustomNotification>> getNotificationsForTraveller(
  String? travellerId,
  String? jwtToken,
) async {
  if (travellerId == null || travellerId.isEmpty) {
    print("Traveller ID is null or empty.");
    return []; // Return empty list for invalid input
  }

  // Construct the URI correctly with the base URL and the unencoded path
  final uri = Uri.http(searchUrl, '/notification/$travellerId');

  print(
    "Attempting to fetch notifications from URI: $uri",
  ); // Log the constructed URI

  try {
    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken',
      },
    );

    print("Get Notifications API Response Status: ${response.statusCode}");
    print(
      "Get Notifications API Response Body: ${response.body}",
    ); // Log response body for debugging

    if (response.statusCode == 200) {
      // Decode the JSON response body
      final List<dynamic> decodedResponse = jsonDecode(response.body);

      // Map the decoded list to CustomNotification objects
      return decodedResponse
          .map(
            (item) => CustomNotification.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else if (response.statusCode == 404) {
      print("Notifications not found for traveller ID: $travellerId (404)");
      return []; // Return empty list if not found
    } else {
      // Handle other non-200 status codes
      print(
        "API error fetching notifications: Status ${response.statusCode}, Body: ${response.body}",
      );
      // You might want to return an empty list or throw an exception depending on your error handling strategy
      return [];
    }
  } catch (e) {
    // Catch any exceptions during the process (e.g., network errors, json decoding errors)
    print("Error fetching notifications: $e");
    return []; // Return empty list on exception
  }
}

Future<bool> markNotificationAsReadApi(
  String? travellerId,
  String notificationId,
  String jwtToken,
) async {
  // Ensure IDs are not empty
  if (travellerId!.isEmpty || notificationId.isEmpty) {
    print("Traveller ID or Notification ID is empty.");
    return false;
  }

  final uri = Uri.http(
    searchUrl,
    '/notification/$travellerId/$notificationId/read',
  );

  try {
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Include Authorization header
      },
    );

    print("Mark Notification Read API Response Status: ${response.statusCode}");
    print(
      "Mark Notification Read API Response Body: ${response.body}",
    ); // Log response body for debugging

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        "Notification $notificationId marked as read for traveller $travellerId successfully.",
      );
      return true; // Indicate success
    } else {
      print("API error marking notification as read: ${response.statusCode}");
      return false; // Indicate failure
    }
  } catch (e) {
    print("Error marking notification as read: $e");
    return false; // Indicate failure
  }
}

Future<bool> markNotificationAsUnreadApi(
  String? travellerId,
  String notificationId,
  String jwtToken,
) async {
  if (travellerId == null || travellerId.isEmpty || notificationId.isEmpty) {
    print("Traveller ID or Notification ID is null or empty.");
    return false;
  }

  final uri = Uri.http(
    searchUrl,
    '/notification/$travellerId/$notificationId/unread',
  );

  try {
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwtToken', // Include Authorization header
      },
    );

    print(
      "Mark Notification Unread API Response Status: ${response.statusCode}",
    );
    print(
      "Mark Notification Unread API Response Body: ${response.body}",
    ); // Log response body for debugging

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        "Notification $notificationId marked as unread for traveller $travellerId successfully.",
      );
      return true; // Indicate success
    } else {
      print("API error marking notification as unread: ${response.statusCode}");
      return false; // Indicate failure
    }
  } catch (e) {
    print("Error marking notification as unread: $e");
    return false; // Indicate failure
  }
}
