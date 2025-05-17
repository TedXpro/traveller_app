import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/notification.dart';
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/services/notification_api_services.dart'; // Import your models

class NotificationItem {
  final CustomNotification customNotification;

  NotificationItem({required this.customNotification});

  bool get isRead => customNotification.status == 'read';
  String get title => customNotification.title;
  String get body => customNotification.message;
  String get id => customNotification.id;
  DateTime get postTime =>
      customNotification.postTime; // Add getter for postTime for sorting
}

class NotificationScreen extends StatefulWidget {
  final List<Map<String, dynamic>>? initialNotifications;
  final RemoteMessage? foregroundMessage;

  const NotificationScreen({
    super.key,
    this.initialNotifications,
    this.foregroundMessage,
  });

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true; // State to track loading
  String? _error; // State to track errors

  late UserProvider userProvider;
  late String? _currentTravellerId;
  late String? _jwtToken;

  @override
  void initState() {
    super.initState();
    // Make sure context is available for Provider.of
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.userData;
      _currentTravellerId = user?.id; // Use nullable access
      _jwtToken = userProvider.jwtToken;

      // Only load from backend if traveller ID is available
      if (_currentTravellerId != null && _currentTravellerId!.isNotEmpty) {
        _loadNotificationsFromBackend(); // Load from backend first
      } else {
        setState(() {
          _isLoading = false;
          _error = "Traveller ID not available. Cannot load notifications.";
        });
        print("Traveller ID is null or empty, cannot load notifications.");
      }

      // Handle initial message if the app was opened from a terminated state
      _handleInitialMessage();
      // Listen for foreground messages
      _listenForForegroundNotifications();
    });
  }

  // Function to handle the initial message that opened the app from terminated state
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && initialMessage.notification != null) {
      print(
        "App opened from terminated state by notification: ${initialMessage.notification?.title}",
      );

      if (mounted) {
        // Check if the widget is still mounted before setState
        setState(() {
          // Example: Add locally if not already present (basic check)
          final basicNotification = CustomNotification(
            id:
                initialMessage.messageId ??
                DateTime.now().millisecondsSinceEpoch
                    .toString(), // Use messageId or generate
            title: initialMessage.notification!.title ?? 'New Notification',
            message: initialMessage.notification!.body ?? 'No message body',
            postTime:
                initialMessage.sentTime ??
                DateTime.now(), // Use sentTime if available
            status: 'unread',
          );
          // Prevent duplicates if backend fetch is also adding it
          if (!_notifications.any((item) => item.id == basicNotification.id)) {
            _notifications.insert(
              0,
              NotificationItem(customNotification: basicNotification),
            );
            _notifications.sort(
              (a, b) => b.postTime.compareTo(a.postTime),
            ); // Use postTime getter
          }
        });
      }
    }
  }

  // Function to fetch notifications from the backend
  Future<void> _loadNotificationsFromBackend() async {
    setState(() {
      _isLoading = true; // Set loading state
      _error = null; // Clear previous errors
    });

    try {
      // Call the updated API function that returns a List<CustomNotification>
      final List<CustomNotification> backendNotifications =
          await getNotificationsForTraveller(_currentTravellerId, _jwtToken);

      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        // Directly use the list of CustomNotification objects
        _notifications =
            backendNotifications
                .map((cn) => NotificationItem(customNotification: cn))
                .toList();
        // Sort by post time, newest first
        _notifications.sort(
          (a, b) => b.postTime.compareTo(a.postTime), // Use postTime getter
        );

        // Check if the list is empty after loading
        if (_notifications.isEmpty) {
          print("Backend returned an empty list of notifications.");
          // Optionally set a message if no notifications were found
          // _error = "No notifications found.";
        }
      });
    } catch (e) {
      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _error =
            'Failed to load notifications: ${e.toString()}'; // Set error message
        _notifications = []; // Clear notifications on error
      });
      print("Error loading notifications from backend: $e");
    } finally {
      // Check if the widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _isLoading = false; // Turn off loading state
      });
    }
  }

  // Existing Firebase Messaging logic - adapt to use CustomNotification if possible
  void _addForegroundMessage() {
    if (widget.foregroundMessage?.notification != null) {
      print(
        "Processing initial foreground message passed to widget: ${widget.foregroundMessage?.notification?.title}",
      );
      // Logic to add to list (similar to listener)
      if (mounted) {
        setState(() {
          final basicNotification = CustomNotification(
            id:
                widget.foregroundMessage!.messageId ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            title:
                widget.foregroundMessage!.notification!.title ??
                'New Notification',
            message:
                widget.foregroundMessage!.notification!.body ??
                'No message body',
            postTime: widget.foregroundMessage!.sentTime ?? DateTime.now(),
            status: 'unread',
          );
          if (!_notifications.any((item) => item.id == basicNotification.id)) {
            _notifications.insert(
              0,
              NotificationItem(customNotification: basicNotification),
            );
            _notifications.sort(
              (a, b) => b.postTime.compareTo(a.postTime),
            ); // Use postTime getter
          }
        });
      }
    } else {
      print(
        "widget.foregroundMessage or its notification is null (in _addForegroundMessage)",
      );
    }
  }

  // Existing Firebase Messaging logic - adapt to use CustomNotification if possible
  void _listenForForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(
          "Foreground notification received while on screen: ${message.notification?.title}",
        );
        // Create a basic CustomNotification for the foreground message
        final basicNotification = CustomNotification(
          id:
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch
                  .toString(), // Use messageId or generate
          title: message.notification!.title ?? 'New Notification',
          message: message.notification!.body ?? 'No message body',
          postTime:
              message.sentTime ?? DateTime.now(), // Use sentTime if available
          status: 'unread', // Assume foreground messages are unread initially
        );
        if (mounted) {
          // Check if the widget is still mounted before setState
          setState(() {
            // Prevent duplicates if backend fetch is also adding it
            if (!_notifications.any(
              (item) => item.id == basicNotification.id,
            )) {
              _notifications.insert(
                0,
                NotificationItem(customNotification: basicNotification),
              );
              // Sort again after adding a new notification
              _notifications.sort(
                (a, b) => b.postTime.compareTo(a.postTime),
              ); // Use postTime getter
            }
          });
        }
      }
    });
  }

  // Function to mark a notification as read locally and on the backend
  Future<void> _markAsRead(NotificationItem notificationItem) async {
    // Find the index of the notification in the current list
    final index = _notifications.indexWhere(
      (item) => item.id == notificationItem.id,
    );

    if (index != -1 && !_notifications[index].isRead) {
      // Optimistically update UI
      setState(() {
        // Create a new CustomNotification with updated status
        final updatedCustomNotification = CustomNotification(
          id: notificationItem.customNotification.id,
          title: notificationItem.customNotification.title,
          message: notificationItem.customNotification.message,
          postTime: notificationItem.customNotification.postTime,
          status: 'read', // Set status to read
        );
        // Replace the old NotificationItem with the updated one
        _notifications[index] = NotificationItem(
          customNotification: updatedCustomNotification,
        );
        // No need to sort here, status change doesn't affect order
      });

      // Call backend API to mark as read
      try {
        // Ensure _currentTravellerId is not null before calling
        if (_currentTravellerId != null) {
          final success = await markNotificationAsReadApi(
            _currentTravellerId!, // Use non-nullable version
            notificationItem.id,
            _jwtToken.toString()
          ); // Pass traveller ID and notification ID

          if (!success) {
            // If backend update failed, you might want to revert the UI state
            // or show an error message. For simplicity, we'll just log for now.
            print(
              "Failed to mark notification ${notificationItem.id} as read on backend.",
            );
          }
        } else {
          print(
            "Traveller ID is null, cannot mark notification as read on backend.",
          );
        }
      } catch (e) {
        print("Error calling markNotificationAsReadApi: $e");
        // Optional: Revert UI state on API call error
      }
    }
  }

  // Function to mark a notification as unread locally and on the backend
  Future<void> _markAsUnread(NotificationItem notificationItem) async {
    // Find the index of the notification in the current list
    final index = _notifications.indexWhere(
      (item) => item.id == notificationItem.id,
    );

    if (index != -1 && notificationItem.isRead) {
      // Only mark as unread if it's currently read
      // Optimistically update UI
      setState(() {
        // Create a new CustomNotification with updated status
        final updatedCustomNotification = CustomNotification(
          id: notificationItem.customNotification.id,
          title: notificationItem.customNotification.title,
          message: notificationItem.customNotification.message,
          postTime: notificationItem.customNotification.postTime,
          status: 'unread', // Set status to unread
        );
        // Replace the old NotificationItem with the updated one
        _notifications[index] = NotificationItem(
          customNotification: updatedCustomNotification,
        );
        // No need to sort here, status change doesn't affect order
      });

      // Call backend API to mark as unread
      try {
        // Ensure _currentTravellerId is not null before calling
        if (_currentTravellerId != null) {
          final success = await markNotificationAsUnreadApi(
            _currentTravellerId!, // Use non-nullable version
            notificationItem.id,
            _jwtToken.toString()
          ); // Pass traveller ID and notification ID

          if (!success) {
            // If backend update failed, you might want to revert the UI state
            // or show an error message. For simplicity, we'll just log for now.
            print(
              "Failed to mark notification ${notificationItem.id} as unread on backend.",
            );
          }
        } else {
          print(
            "Traveller ID is null, cannot mark notification as unread on backend.",
          );
        }
      } catch (e) {
        print("Error calling markNotificationAsUnreadApi: $e");
        // Optional: Revert UI state on API call error
      }
    }
  }

  void _showNotificationDetails(BuildContext context, NotificationItem item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: [
            // GestureDetector to dismiss dialog by tapping outside
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(color: Colors.black54),
            ),
            Center(
              child: Card(
                margin: const EdgeInsets.all(20.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(item.body, style: const TextStyle(fontSize: 16.0)),
                      const SizedBox(height: 16.0),
                      Row(
                        // Use a Row for multiple buttons
                        mainAxisAlignment:
                            MainAxisAlignment.end, // Align buttons to the right
                        children: [
                          // Show "Mark as Unread" button only if the notification is currently read
                          if (item.isRead)
                            TextButton(
                              onPressed: () {
                                _markAsUnread(
                                  item,
                                ); // Call the mark as unread function
                                Navigator.of(context).pop(); // Close the dialog
                              },
                              child: const Text('Mark as Unread'),
                            ),
                          const SizedBox(
                            width: 8.0,
                          ), // Add spacing between buttons
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
    // Mark as read when the details dialog is shown (if it's unread)
    if (!item.isRead) {
      _markAsRead(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Show loading indicator
              : _error != null
              ? Center(child: Text(_error!)) // Show error message
              : _notifications.isEmpty
              ? const Center(
                child: Text('No notifications yet.'),
              ) // Show empty message
              : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    // Change card color based on read status
                    color:
                        notification.isRead
                            ? Colors.grey[300]
                            : null, // Use default color if unread
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_outlined),
                          // Show red dot only if not read
                          if (!notification.isRead)
                            Positioned(
                              top: 2.0,
                              right: 2.0,
                              child: Container(
                                width: 8.0,
                                height: 8.0,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        notification.title,
                        // Optional: Style title differently if read
                        style: TextStyle(
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                          color:
                              notification.isRead
                                  ? Colors.grey[700]
                                  : Colors.black,
                        ),
                      ),
                      subtitle: Text(
                        notification.body,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // Optional: Style subtitle differently if read
                        style: TextStyle(
                          color:
                              notification.isRead
                                  ? Colors.grey[600]
                                  : Colors.black87,
                        ),
                      ),
                      onTap: () {
                        _showNotificationDetails(context, notification);
                      },
                    ),
                  );
                },
              ),
    );
  }
}
