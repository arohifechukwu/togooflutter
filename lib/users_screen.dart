import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'admin_bottom_navigation_menu.dart';
import 'widgets/user_tile.dart';
import 'models/user_model.dart';

class UsersScreen extends StatefulWidget {
  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<UserModel> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  /// ✅ Fetch users from Realtime Database & Firestore
  void _fetchUsers() async {
    _users.clear();

    // Validate admin role from Realtime Database
    String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      Fluttertoast.showToast(msg: "User not authenticated.");
      return;
    }

    final adminSnapshot = await _dbRef.child("admin").child(uid).get();
    if (!adminSnapshot.exists) {
      Fluttertoast.showToast(msg: "Access Denied: Only admins can fetch users.");
      return;
    }

    await _fetchUsersFromRealtimeDB("customer");
    await _fetchUsersFromRealtimeDB("driver");
    await _fetchUsersFromRealtimeDB("restaurant");
    await _fetchUsersFromRealtimeDB("admin");
    await _fetchUsersFromFirestore();

    setState(() {
      _isLoading = false;
    });
  }

  /// ✅ Fetch users from Realtime Database
  Future<void> _fetchUsersFromRealtimeDB(String node) async {
    _dbRef.child(node).onValue.listen((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        List<UserModel> fetchedUsers = [];
        data.forEach((key, value) {
          if (value is Map) {
            final user = UserModel.fromRealtimeDB(key, value).copyWith(role: node);
            fetchedUsers.add(user);
          }
        });

        setState(() {
          _users.addAll(fetchedUsers);
        });
      }
    }, onError: (error) {
      Fluttertoast.showToast(msg: "Error fetching users: $error");
    });
  }

  /// ✅ Fetch users from Firestore
  Future<void> _fetchUsersFromFirestore() async {
    try {
      final snapshot = await _firestore.collection("users").get();
      List<UserModel> firestoreUsers = snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

      setState(() {
        _users.addAll(firestoreUsers);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching Firestore users: $e");
    }
  }

  /// ✅ Update User Status
  void _updateUserStatus(UserModel user, String status) {
    _dbRef.child(user.role).child(user.userId).update({"status": status}).then((_) {
      setState(() {
        _users = _users.map((u) => u.userId == user.userId ? u.copyWith(status: status) : u).toList();
      });
      Fluttertoast.showToast(msg: "${user.name} is now $status.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Failed to update status: $error");
    });
  }

  /// ✅ Delete User
  void _deleteUser(UserModel user) {
    _dbRef.child(user.role).child(user.userId).remove().then((_) {
      setState(() {
        _users.removeWhere((u) => u.userId == user.userId);
      });
      Fluttertoast.showToast(msg: "${user.name} deleted.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Failed to delete user: $error");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Users List"), backgroundColor: Colors.orange),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _users.isEmpty
          ? Center(
        child: Text("No records found",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          return UserTile(
            user: _users[index],
            onSuspend: () => _updateUserStatus(_users[index], "suspended"),
            onReactivate: () => _updateUserStatus(_users[index], "active"),
            onDelete: () => _deleteUser(_users[index]),
          );
        },
      ),
      bottomNavigationBar: AdminBottomNavigationMenu(currentIndex: 1),
    );
  }
}