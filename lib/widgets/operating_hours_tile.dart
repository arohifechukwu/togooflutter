import 'package:flutter/material.dart';

class OperatingHoursTile extends StatelessWidget {
  final String dayLabel;
  final TextEditingController openTimeController;
  final TextEditingController closeTimeController;
  final VoidCallback? onOpenTimeTap;
  final VoidCallback? onCloseTimeTap;

  const OperatingHoursTile({
    Key? key,
    required this.dayLabel,
    required this.openTimeController,
    required this.closeTimeController,
    this.onOpenTimeTap,
    this.onCloseTimeTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Day Header
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              dayLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Time Inputs Row
          Row(
            children: [
              // Open Time Field
              Expanded(
                child: TextField(
                  controller: openTimeController,
                  decoration: const InputDecoration(
                    hintText: 'Open (HH:mm)',
                    contentPadding: EdgeInsets.all(8),
                  ),
                  keyboardType: TextInputType.datetime,
                  onTap: onOpenTimeTap,
                ),
              ),
              // Spacer of 16dp width
              const SizedBox(width: 16),
              // Close Time Field
              Expanded(
                child: TextField(
                  controller: closeTimeController,
                  decoration: const InputDecoration(
                    hintText: 'Close (HH:mm)',
                    contentPadding: EdgeInsets.all(8),
                  ),
                  keyboardType: TextInputType.datetime,
                  onTap: onCloseTimeTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}