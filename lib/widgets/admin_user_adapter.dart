import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'admin_user_tile.dart';

class AdminUserAdapter extends StatefulWidget {
  @override
  _AdminUserAdapterState createState() => _AdminUserAdapterState();
}

class _AdminUserAdapterState extends State<AdminUserAdapter> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsersForApproval();
  }

  /// ✅ Fetch users for approval (Only pending status)
  Future<void> _fetchUsersForApproval() async {
    List<UserModel> userList = [];
    await _fetchUsersFromNode("customer", userList);
    await _fetchUsersFromNode("driver", userList);
    await _fetchUsersFromNode("restaurant", userList);

    setState(() {
      _users = userList.where((user) => user.status == "pending").toList();
    });
  }

  /// ✅ Fetch users from Firebase Realtime Database
  Future<void> _fetchUsersFromNode(String node, List<UserModel> users) async {
    final snapshot = await _dbRef.child(node).get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        users.add(UserModel.fromRealtimeDB(key, value));
      });
    }
  }

  /// ✅ Approve user (Change status to "approved")
  void _approveUser(UserModel user) {
    _dbRef.child(user.role).child(user.userId).update({"status": "approved"}).then((_) {
      setState(() {
        _users.removeWhere((u) => u.userId == user.userId);
      });
    });
  }

  /// ✅ Decline user (Remove from database)
  void _declineUser(UserModel user) {
    _dbRef.child(user.role).child(user.userId).remove().then((_) {
      setState(() {
        _users.removeWhere((u) => u.userId == user.userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _users.isEmpty
        ? Center(child: Text("No pending approvals"))
        : ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        UserModel user = _users[index];
        return AdminUserTile(
          user: user,
          onApprove: () => _approveUser(user),
          onDecline: () => _declineUser(user),
        );
      },
    );
  }
}