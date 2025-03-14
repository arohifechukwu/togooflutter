import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'user_tile.dart';

class UserAdapter extends StatefulWidget {
  @override
  _UserAdapterState createState() => _UserAdapterState();
}

class _UserAdapterState extends State<UserAdapter> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  List<UserModel> _users = [];

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    List<UserModel> userList = [];
    await _fetchUsersFromNode("customer", userList);
    await _fetchUsersFromNode("driver", userList);
    await _fetchUsersFromNode("restaurant", userList);

    setState(() {
      _users = userList;
    });
  }

  Future<void> _fetchUsersFromNode(String node, List<UserModel> users) async {
    final snapshot = await _dbRef.child(node).get();
    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        users.add(UserModel.fromRealtimeDB(key, value));
      });
    }
  }

  void _updateUserStatus(String userNode, UserModel user, String status) {
    _dbRef.child(userNode).child(user.userId).update({"status": status}).then((_) {
      setState(() {
        _users = _users.map((u) => u.userId == user.userId ? u.copyWith(status: status) : u).toList();
      });
    });
  }

  void _deleteUser(String userNode, UserModel user) {
    _dbRef.child(userNode).child(user.userId).remove().then((_) {
      setState(() {
        _users.removeWhere((u) => u.userId == user.userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _users.isEmpty
        ? Center(child: Text("No records found"))
        : ListView.builder(
      itemCount: _users.length,
      itemBuilder: (context, index) {
        UserModel user = _users[index];
        return UserTile(
          user: user,
          onSuspend: () => _updateUserStatus(user.role, user, "suspended"),
          onReactivate: () => _updateUserStatus(user.role, user, "active"),
          onDelete: () => _deleteUser(user.role, user),
        );
      },
    );
  }
}