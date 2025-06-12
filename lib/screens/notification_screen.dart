import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import 'package:traveller_app/models/notification.dart'; // Import your CustomNotification model
import 'package:traveller_app/providers/user_provider.dart';
import 'package:traveller_app/services/notification_api_services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; // Import AppLocalizations
import 'package:intl/intl.dart'; // For date formatting

// Ensure your CustomNotification model has 'id', 'title', 'message', 'postTime', 'status' fields.
// Example:
// class CustomNotification {
//   final String id;
//   final String title;
//   final String message;
//   final DateTime postTime;
//   final String status; // 'read' or 'unread'
//
//   CustomNotification({
//     required this.id,
//     required this.title,
//     required this.message,
//     required this.postTime,
//     required this.status,
//   });
//
//   // Example fromJson if you're using json_serializable or manual parsing
//   factory CustomNotification.fromJson(Map<String, dynamic> json) {
//     return CustomNotification(
//       id: json['id'] as String,
//       title: json['title'] as String,
//       message: json['message'] as String,
//       postTime: DateTime.parse(json['postTime'] as String), // Adjust based on your API's date format
//       status: json['status'] as String,
//     );
//   }
//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'title': title,
//     'message': message,
//     'postTime': postTime.toIso8601String(),
//     'status': status,
//   };
// }

class NotificationItem {
  final CustomNotification customNotification;

  NotificationItem({required this.customNotification});

  // Ensure status is always compared in lowercase for consistency
  bool get isRead => customNotification.status.toLowerCase() == 'read';
  String get title => customNotification.title;
  String get body => customNotification.message;
  String get id => customNotification.id;
  DateTime get postTime => customNotification.postTime;
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
  bool _isLoading = true;
  String? _error;

  late UserProvider userProvider;
  String? _currentTravellerId;
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.userData;
      _currentTravellerId = user?.id;
      _jwtToken = userProvider.jwtToken;

      if (_currentTravellerId != null && _currentTravellerId!.isNotEmpty) {
        _loadNotificationsFromBackend();
      } else {
        setState(() {
          _isLoading = false;
          _error = AppLocalizations.of(context)!.noTravellerIdError;
        });
        print("Traveller ID is null or empty, cannot load notifications.");
      }

      _handleInitialMessage();
      _listenForForegroundNotifications();
    });
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null && initialMessage.notification != null) {
      print(
        "App opened from terminated state by notification: ${initialMessage.notification?.title}",
      );

      if (mounted) {
        final basicNotification = CustomNotification(
          id:
              initialMessage.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: initialMessage.notification!.title ?? 'New Notification',
          message: initialMessage.notification!.body ?? 'No message body',
          postTime: initialMessage.sentTime ?? DateTime.now(),
          status: 'unread', // Always assume unread when received
        );
        _addOrUpdateNotification(basicNotification);
      }
    }
  }

  void _listenForForegroundNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print(
          "Foreground notification received while on screen: ${message.notification?.title}",
        );
        final basicNotification = CustomNotification(
          id:
              message.messageId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          title: message.notification!.title ?? 'New Notification',
          message: message.notification!.body ?? 'No message body',
          postTime: message.sentTime ?? DateTime.now(),
          status: 'unread', // Always assume unread when received
        );
        _addOrUpdateNotification(basicNotification);
      }
    });
  }

  // Centralized method to add or update notifications and sort
  void _addOrUpdateNotification(CustomNotification newNotification) {
    setState(() {
      final index = _notifications.indexWhere(
        (item) => item.id == newNotification.id,
      );
      if (index != -1) {
        // Update existing notification
        _notifications[index] = NotificationItem(
          customNotification: newNotification,
        );
      } else {
        // Add new notification
        _notifications.insert(
          0,
          NotificationItem(customNotification: newNotification),
        );
      }
      _notifications.sort((a, b) => b.postTime.compareTo(a.postTime));
    });
  }

  Future<void> _loadNotificationsFromBackend() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final List<CustomNotification> backendNotifications =
          await getNotificationsForTraveller(_currentTravellerId, _jwtToken);

      if (!mounted) return;

      setState(() {
        _notifications =
            backendNotifications
                .map((cn) => NotificationItem(customNotification: cn))
                .toList();
        _notifications.sort((a, b) => b.postTime.compareTo(a.postTime));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = AppLocalizations.of(
          context,
        )!.failedToLoadNotifications(e.toString());
        _notifications = [];
      });
      print("Error loading notifications from backend: $e");
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(NotificationItem notificationItem) async {
    print(
      'Attempting to mark as read: ID=${notificationItem.id}, Current status=${notificationItem.isRead ? 'read' : 'unread'}',
    );

    final index = _notifications.indexWhere(
      (item) => item.customNotification.id == notificationItem.id,
    );

    if (index != -1 && !_notifications[index].isRead) {
      setState(() {
        final updatedCustomNotification = CustomNotification(
          id: notificationItem.customNotification.id,
          title: notificationItem.customNotification.title,
          message: notificationItem.customNotification.message,
          postTime: notificationItem.customNotification.postTime,
          status: 'read',
        );
        _notifications[index] = NotificationItem(
          customNotification: updatedCustomNotification,
        );
        print('UI updated to read for ID: ${notificationItem.id}');
      });

      try {
        if (_currentTravellerId != null && _jwtToken != null) {
          final success = await markNotificationAsReadApi(
            _currentTravellerId!,
            notificationItem.id,
            _jwtToken!,
          );
          if (!success) {
            print(
              "Backend failed to mark notification ${notificationItem.id} as read. Reverting UI.",
            );
            setState(() {
              final originalCustomNotification = CustomNotification(
                id: notificationItem.customNotification.id,
                title: notificationItem.customNotification.title,
                message: notificationItem.customNotification.message,
                postTime: notificationItem.customNotification.postTime,
                status: 'unread',
              );
              _notifications[index] = NotificationItem(
                customNotification: originalCustomNotification,
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.markReadFailed),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.markReadSuccess),
              ),
            );
          }
        } else {
          print(
            "Traveller ID or JWT Token is null, cannot mark notification as read on backend.",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.markReadLoginRequired,
              ),
            ),
          );
        }
      } catch (e) {
        print(
          "Error calling markNotificationAsReadApi for ID ${notificationItem.id}: $e",
        );
        setState(() {
          final originalCustomNotification = CustomNotification(
            id: notificationItem.customNotification.id,
            title: notificationItem.customNotification.title,
            message: notificationItem.customNotification.message,
            postTime: notificationItem.customNotification.postTime,
            status: 'unread',
          );
          _notifications[index] = NotificationItem(
            customNotification: originalCustomNotification,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.markReadError(e.toString()),
            ),
          ),
        );
      }
    } else {
      print(
        'Mark as read skipped: Notification ID=${notificationItem.id}, Is already read or not found.',
      );
    }
  }

  Future<void> _markAsUnread(NotificationItem notificationItem) async {
    print(
      'Attempting to mark as unread: ID=${notificationItem.id}, Current status=${notificationItem.isRead ? 'read' : 'unread'}',
    );

    final index = _notifications.indexWhere(
      (item) => item.customNotification.id == notificationItem.id,
    );

    if (index != -1 && _notifications[index].isRead) {
      setState(() {
        final updatedCustomNotification = CustomNotification(
          id: notificationItem.customNotification.id,
          title: notificationItem.customNotification.title,
          message: notificationItem.customNotification.message,
          postTime: notificationItem.customNotification.postTime,
          status: 'unread',
        );
        _notifications[index] = NotificationItem(
          customNotification: updatedCustomNotification,
        );
        print('UI updated to unread for ID: ${notificationItem.id}');
      });

      try {
        if (_currentTravellerId != null && _jwtToken != null) {
          final success = await markNotificationAsUnreadApi(
            _currentTravellerId!,
            notificationItem.id,
            _jwtToken!,
          );
          if (!success) {
            print(
              "Backend failed to mark notification ${notificationItem.id} as unread. Reverting UI.",
            );
            setState(() {
              final originalCustomNotification = CustomNotification(
                id: notificationItem.customNotification.id,
                title: notificationItem.customNotification.title,
                message: notificationItem.customNotification.message,
                postTime: notificationItem.customNotification.postTime,
                status: 'read',
              );
              _notifications[index] = NotificationItem(
                customNotification: originalCustomNotification,
              );
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.markUnreadFailed),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppLocalizations.of(context)!.markUnreadSuccess),
              ),
            );
          }
        } else {
          print(
            "Traveller ID or JWT Token is null, cannot mark notification as unread on backend.",
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLocalizations.of(context)!.markUnreadLoginRequired,
              ),
            ),
          );
        }
      } catch (e) {
        print(
          "Error calling markNotificationAsUnreadApi for ID ${notificationItem.id}: $e",
        );
        setState(() {
          final originalCustomNotification = CustomNotification(
            id: notificationItem.customNotification.id,
            title: notificationItem.customNotification.title,
            message: notificationItem.customNotification.message,
            postTime: notificationItem.customNotification.postTime,
            status: 'read',
          );
          _notifications[index] = NotificationItem(
            customNotification: originalCustomNotification,
          );
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.markUnreadError(e.toString()),
            ),
          ),
        );
      }
    } else {
      print(
        'Mark as unread skipped: Notification ID=${notificationItem.id}, Is already unread or not found.',
      );
    }
  }

  void _showNotificationDetails(BuildContext context, NotificationItem item) {
    // Automatically mark as read if it's currently unread.
    // This call is intentionally placed here to update the UI immediately
    // as the dialog opens, before the dialog rebuilds.
    if (!item.isRead) {
      _markAsRead(item);
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use dialogContext to avoid potential context issues
        final l10n = AppLocalizations.of(dialogContext)!;
        final theme = Theme.of(dialogContext);

        // Get the *current* state of the notification from the list, not the potentially outdated 'item'
        // This ensures the dialog reflects the most up-to-date read status after `_markAsRead` is called.
        final currentNotification = _notifications.firstWhere(
          (n) => n.id == item.id,
          orElse: () => item,
        );

        return AlertDialog(
          title: Row(
            children: [
              Icon(
                currentNotification.isRead
                    ? Icons.mark_email_read
                    : Icons.mark_email_unread,
                color:
                    currentNotification.isRead
                        ? theme.colorScheme.onSurface.withOpacity(0.6)
                        : theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  currentNotification.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color:
                        currentNotification.isRead
                            ? theme.colorScheme.onSurface
                            : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  currentNotification.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 15.0),
                Text(
                  '${l10n.postedOn}: ${DateFormat('EEEE, MMMM d, yyyy hh:mm a', l10n.localeName).format(currentNotification.postTime.toLocal())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            // ONLY show "Mark as Unread" if the notification is currently marked as read
            if (currentNotification.isRead)
              TextButton(
                onPressed: () {
                  _markAsUnread(currentNotification); // Call mark as unread
                  Navigator.of(dialogContext).pop(); // Close the dialog
                },
                child: Text(l10n.markAsUnreadButton),
              ),
            TextButton(
              onPressed:
                  () => Navigator.of(dialogContext).pop(), // Close button
              child: Text(l10n.closeButton),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.notificationsTitle)),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
              : _error != null
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.errorLoadingNotifications,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: _loadNotificationsFromBackend,
                        icon: const Icon(Icons.refresh),
                        label: Text(l10n.tryAgainButton),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _notifications.isEmpty
              ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 80,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.noNotificationsYet,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.notificationEmptyMessage,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : ListView.builder(
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    elevation: 3.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      side: BorderSide(
                        color:
                            notification.isRead
                                ? Colors.transparent
                                : theme.colorScheme.primary.withOpacity(0.5),
                        width: 1.0,
                      ),
                    ),
                    color:
                        notification.isRead
                            ? theme.cardColor
                            : theme.colorScheme.surfaceVariant,
                    child: ListTile(
                      leading: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            notification.isRead
                                ? Icons.mark_email_read_outlined
                                : Icons.mark_email_unread_outlined,
                            color:
                                notification.isRead
                                    ? theme.colorScheme.onSurface.withOpacity(
                                      0.6,
                                    )
                                    : theme.colorScheme.primary,
                            size: 28,
                          ),
                          if (!notification.isRead)
                            Positioned(
                              top: 4.0,
                              right: 4.0,
                              child: Container(
                                width: 10.0,
                                height: 10.0,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      title: Text(
                        notification.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight:
                              notification.isRead
                                  ? FontWeight.normal
                                  : FontWeight.bold,
                          color:
                              notification.isRead
                                  ? theme.colorScheme.onSurface.withOpacity(0.8)
                                  : theme.colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.body,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  notification.isRead
                                      ? theme.colorScheme.onSurface.withOpacity(
                                        0.6,
                                      )
                                      : theme.colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            DateFormat(
                              'MMM d, yyyy - hh:mm a',
                              l10n.localeName,
                            ).format(notification.postTime.toLocal()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
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
