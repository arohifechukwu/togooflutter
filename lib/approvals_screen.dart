import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'admin_bottom_navigation_menu.dart';
import 'user_model.dart';
import 'admin_user_tile.dart';

// ✅ Define color palette
const Color primaryColor = Color(0xFFF18D34); // Dark Orange
const Color primaryVariant = Color(0xFFE67E22); // Slightly Darker Orange
const Color darkGray = Color(0xFF757575); // Unselected text color

class ApprovalsScreen extends StatefulWidget {
  @override
  _ApprovalsScreenState createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  final DatabaseReference _dbReference = FirebaseDatabase.instance.ref();
  List<UserModel> _pendingUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingApprovals();
  }

  /// ✅ **Fetch only users with `status: "pending"`**
  Future<void> _fetchPendingApprovals() async {
    List<UserModel> userList = [];

    await _fetchUsersFromNode("driver", userList);
    await _fetchUsersFromNode("restaurant", userList);

    setState(() {
      _pendingUsers = userList;
      _isLoading = false;
    });
  }

  /// ✅ **Fetch users from Realtime Database (Java Logic)**
  Future<void> _fetchUsersFromNode(String node, List<UserModel> users) async {
    try {
      final snapshot = await _dbReference.child(node).get();
      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          // ✅ Only add users with status "pending"
          if (value is Map && value.containsKey("status") && value["status"] == "pending") {
            users.add(UserModel.fromRealtimeDB(key, value).copyWith(role: node));
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching approvals: $e");
    }
  }

  /// ✅ **Approve user (updates only `status` field)**
  void _approveUser(UserModel user) {
    String userNode = user.role.toLowerCase();

    _dbReference.child(userNode).child(user.userId).update({"status": "approved"}).then((_) {
      setState(() {
        _pendingUsers = _pendingUsers.where((u) => u.userId != user.userId).toList();
      });

      Fluttertoast.showToast(msg: "${user.name} has been approved.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Approval failed: $error");
    });
  }

  /// ✅ **Decline user (removes user)**
  void _declineUser(UserModel user) {
    String userNode = user.role.toLowerCase();

    _dbReference.child(userNode).child(user.userId).remove().then((_) {
      setState(() {
        _pendingUsers = _pendingUsers.where((u) => u.userId != user.userId).toList();
      });

      Fluttertoast.showToast(msg: "${user.name} has been declined.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Decline failed: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pending Approvals"),
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No pending approvals.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        itemCount: _pendingUsers.length,
        itemBuilder: (context, index) {
          UserModel user = _pendingUsers[index];
          return AdminUserTile(
            user: user,
            onApprove: () => _approveUser(user),
            onDecline: () => _declineUser(user),
          );
        },
      ),
      bottomNavigationBar: AdminBottomNavigationMenu(currentIndex: 2), // ✅ Pass correct index
    );
  }
}