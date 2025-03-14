import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'users_screen.dart';
import 'approvals_screen.dart';
import 'transaction_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';
import 'admin_bottom_navigation_menu.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbReference = FirebaseDatabase.instance.ref();
  String? adminUID;
  List<Map<String, dynamic>> userList = [];

  @override
  void initState() {
    super.initState();
    _validateAdminAccess();
  }

  void _validateAdminAccess() async {
    User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      Fluttertoast.showToast(msg: "Unauthorized Access!");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
      return;
    }

    adminUID = currentUser.uid;
    DatabaseReference adminRef = _dbReference.child("admin").child(adminUID!);

    final snapshot = await adminRef.get();
    if (snapshot.exists && snapshot.child("role").value == "admin") {
      _fetchUsers();
    } else {
      Fluttertoast.showToast(msg: "Access Denied: Not an Admin");
      _auth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  void _fetchUsers() {
    setState(() => userList.clear());

    _checkUsersInNode("customer");
    _checkUsersInNode("driver");
    _checkUsersInNode("restaurant");
  }

  void _checkUsersInNode(String nodeName) {
    _dbReference.child(nodeName).once().then((event) {
      final snapshot = event.snapshot;
      if (snapshot.exists) {
        Map<dynamic, dynamic> usersMap = snapshot.value as Map<dynamic, dynamic>;
        usersMap.forEach((key, value) {
          if (value["status"] == "approved") {
            userList.add({"id": key, ...value});
          }
        });
      }
      setState(() {});
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Database Error: $error");
    });
  }

  void _logout() {
    _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: userList.isEmpty
          ? Center(
        child: Text("No records found", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      )
          : ListView.builder(
        itemCount: userList.length,
        itemBuilder: (context, index) {
          var user = userList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: Icon(Icons.person, color: Colors.orange),
              title: Text(user["name"]),
              subtitle: Text(user["email"]),
              trailing: Text(user["role"]),
            ),
          );
        },
      ),
      bottomNavigationBar: AdminBottomNavigationMenu(),
    );
  }
}