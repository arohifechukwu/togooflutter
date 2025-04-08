import 'package:flutter/material.dart';

/// A widget that displays a list of driver notifications.
/// Each notification is represented as a Map with keys "orderId" and "status".
class DriverNotificationsAdapter extends StatelessWidget {
  final List<Map<String, dynamic>> notifications;
  /// Optional callback when the Delete button is pressed.
  final void Function(Map<String, dynamic> notification)? onDelete;

  const DriverNotificationsAdapter({
    Key? key,
    required this.notifications,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return DriverNotificationItem(
          notification: notification,
          onDelete: onDelete,
        );
      },
    );
  }
}

/// A widget that represents a single driver notification,
/// replicating the layout defined in item_driver_notification.xml.
class DriverNotificationItem extends StatelessWidget {
  final Map<String, dynamic> notification;
  /// Optional callback when the Delete button is pressed.
  final void Function(Map<String, dynamic> notification)? onDelete;

  const DriverNotificationItem({
    Key? key,
    required this.notification,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderId = notification["orderId"] as String? ?? "";
    final status = notification["status"] as String? ?? "";
    final displayText = "Order ID: $orderId\nStatus: $status";

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification details text
            Text(
              displayText,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            // Delete button aligned to the right
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  if (onDelete != null) {
                    onDelete!(notification);
                  }
                },
                child: const Text("Delete"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}