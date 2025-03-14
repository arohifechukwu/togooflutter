
import 'package:flutter/material.dart';
import 'user_model.dart';


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

class AdminUserTile extends StatelessWidget {
  final UserModel user;
  final VoidCallback onApprove;
  final VoidCallback onDecline;


  const AdminUserTile({
    required this.user,
    required this.onApprove,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: white,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info
            Row(
              children: [
                Icon(Icons.person, color: primaryColor, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, color: darkGray, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user.email,
                    style: TextStyle(fontSize: 14, color: darkGray),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.badge, color: secondaryColor, size: 18),
                const SizedBox(width: 8),
                Text("Role: ${user.role}", style: TextStyle(fontSize: 14, color: primaryColor)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.info, color: darkGray, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Status: ${user.status}",
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: darkGray),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onApprove,
                  icon: Icon(Icons.check, color: white),
                  label: Text("Approve", style: TextStyle(color: white)),
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDecline,
                  icon: Icon(Icons.cancel, color: white),
                  label: Text("Decline", style: TextStyle(color: white)),
                  style: TextButton.styleFrom(
                    backgroundColor: primaryColor,
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