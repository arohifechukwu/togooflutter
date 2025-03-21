import 'package:flutter/material.dart';
import '../models/user_model.dart';

// ✅ Define color palette as global constants
const Color primaryColor = Color(0xFFF18D34); // Dark Orange
const Color primaryVariant = Color(0xFFE67E22); // Slightly Darker Orange
const Color secondaryColor = Color(0xFFFF9800); // Lighter Orange
const Color white = Color(0xFFFFFFFF);
const Color lightGray = Color(0xFFF5F5F5);
const Color darkGray = Color(0xFF757575);
const Color black = Color(0xFF000000);
const Color buttonDefault = Color(0xFFF18D34);
const Color buttonPressed = Color(0xFFE67E22);
const Color buttonDisabled = Color(0xFFFFB066);

class UserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onSuspend;
  final VoidCallback onReactivate;
  final VoidCallback onDelete;

  const UserTile({
    required this.user,
    required this.onSuspend,
    required this.onReactivate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                Icon(Icons.person, color: darkGray, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.email, color: Colors.grey[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.email,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.badge, color: darkGray, size: 18),
                const SizedBox(width: 8),
                Text(user.role,
                    style: TextStyle(fontSize: 14, color: darkGray)),
              ],
            ),
            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.info, color: primaryColor, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Status: ${user.status}",
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: user.status == "suspended"
                        ? primaryColor
                        : primaryVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Suspend Button (for "active", "approved", and "unknown" users)
                if (user.status == "active" || user.status == "approved" || user.status == "unknown")
                  TextButton.icon(
                    onPressed: onSuspend,
                    icon: Icon(Icons.pause, color: Colors.white),
                    label: Text("Suspend", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                // Reactivate Button (for "suspended" users)
                if (user.status == "suspended")
                  TextButton.icon(
                    onPressed: onReactivate,
                    icon: Icon(Icons.check, color: Colors.white),
                    label: Text("Reactivate", style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),

                const SizedBox(width: 8),

                // Delete Button (Always visible)
                TextButton.icon(
                  onPressed: onDelete,
                  icon: Icon(Icons.delete, color: Colors.white),
                  label: Text("Delete", style: TextStyle(color: Colors.white)),
                  style: TextButton.styleFrom(
                    backgroundColor: primaryVariant,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}