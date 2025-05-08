
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:traveller_app/models/notification.dart'; // Import your notification models
import 'package:traveller_app/constants/api_constants.dart'; // Assuming your API base URL is here

/// Fetches notifications for a specific traveller.
/// Returns a UserNotification object if successful, otherwise returns null.
Future<List<CustomNotification>> getNotificationsForTraveller(
  String? travellerId, // Changed to nullable to match your usage
) async {
  // Ensure travellerId is not null or empty
  if (travellerId == null || travellerId.isEmpty) {
    print("Traveller ID is null or empty.");
    return []; // Return empty list for invalid input
  }

  final uri = Uri.http(
    // headers: {"authorization": "Bearer "}
  '/notification/$travellerId');

  try {
    final response = await http.get(uri);

    print("Get Notifications API Response Status: ${response.statusCode}");
    print(
      "Get Notifications API Response Body: ${response.body}",
    ); // Log response body for debugging

    if (response.statusCode == 200) {
      // Decode the JSON response as a List<dynamic>
      final List<dynamic> decodedResponse = jsonDecode(response.body);

      // Map each item in the list to a CustomNotification object
      return decodedResponse
          .map(
            (item) => CustomNotification.fromJson(item as Map<String, dynamic>),
          )
          .toList();
    } else if (response.statusCode == 404) {
      // Handle case where the traveller's notification document is not found
      print("Notifications not found for traveller ID: $travellerId (404)");
      return []; // Return empty list if not found
    } else {
      // Handle other non-200 status codes
      print("API error fetching notifications: ${response.statusCode}");
      // Depending on your error handling strategy, you might throw an exception
      return []; // Return empty list on API error
    }
  } catch (e) {
    // Handle network errors or other exceptions during the request
    print("Error fetching notifications: $e");
    // Re-throw the exception or return empty list based on your error handling needs
    return []; // Return empty list on exception
  }
}

Future<bool> markNotificationAsReadApi(
  String? travellerId,
  String notificationId,
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
    final response = await http.put(uri);

    print("Mark Notification Read API Response Status: ${response.statusCode}");
    print(
      "Mark Notification Read API Response Body: ${response.body}",
    ); // Log response body for debugging

    // Check if the status code indicates success (e.g., 200 OK, 204 No Content)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        "Notification $notificationId marked as read for traveller $travellerId successfully.",
      );
      return true; // Indicate success
    } else {
      // Handle non-successful status codes
      print("API error marking notification as read: ${response.statusCode}");
      return false; // Indicate failure
    }
  } catch (e) {
    // Handle network errors or other exceptions during the request
    print("Error marking notification as read: $e");
    return false; // Indicate failure
  }
}

/// Marks a specific notification as unread for a traveller on the backend.
/// Returns true if the update was successful, false otherwise.
Future<bool> markNotificationAsUnreadApi(
  String? travellerId,
  String notificationId,
) async {
  // Ensure IDs are not null or empty
  if (travellerId == null || travellerId.isEmpty || notificationId.isEmpty) {
    print("Traveller ID or Notification ID is null or empty.");
    return false;
  }

  // Construct the URI for the PUT request
  // Use your 'searchUrl' constant which is correctly formatted for Uri.http
  // And your endpoint is PUT /notification/:travellerId/:notificationId/unread
  final uri = Uri.http(
    searchUrl,
    '/notification/$travellerId/$notificationId/unread',
  );

  try {
    // Make the PUT request.
    // Assuming your backend endpoint for marking as unread doesn't require a request body.
    // If it requires a body, you would add body: jsonEncode(...)
    final response = await http.put(uri);

    print(
      "Mark Notification Unread API Response Status: ${response.statusCode}",
    );
    print(
      "Mark Notification Unread API Response Body: ${response.body}",
    ); // Log response body for debugging

    // Check if the status code indicates success (e.g., 200 OK, 204 No Content)
    if (response.statusCode >= 200 && response.statusCode < 300) {
      print(
        "Notification $notificationId marked as unread for traveller $travellerId successfully.",
      );
      return true; // Indicate success
    } else {
      // Handle non-successful status codes
      print("API error marking notification as unread: ${response.statusCode}");
      // Optionally parse the response body for error details if your backend provides them
      // try {
      //   final errorBody = jsonDecode(response.body);
      //   print("Backend error details: $errorBody");
      // } catch (e) {
      //   print("Could not decode error response body: $e");
      // }
      return false; // Indicate failure
    }
  } catch (e) {
    // Handle network errors or other exceptions during the request
    print("Error marking notification as unread: $e");
    return false; // Indicate failure
  }
}

