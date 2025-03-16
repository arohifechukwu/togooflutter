import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_screen.dart';
import 'admin_bottom_navigation_menu.dart';

// ✅ Define color palette
const Color primaryColor = Color(0xFFF18D34); // Dark Orange
const Color primaryVariant = Color(0xFFE67E22); // Slightly Darker Orange
const Color darkGray = Color(0xFF757575); // Unselected text color

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbReference = FirebaseDatabase.instance.ref();
  String? adminUID;
  List<Map<String, dynamic>> approvedUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _validateAdminAccess();
  }

  /// ✅ **Check if user is an admin before fetching data**
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
      _fetchApprovedUsers();
    } else {
      Fluttertoast.showToast(msg: "Access Denied: Not an Admin");
      _auth.signOut();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }

  /// ✅ **Fetch only approved users from all categories**
  void _fetchApprovedUsers() async {
    setState(() {
      _isLoading = true;
      approvedUsers.clear();
    });

    await _getUsersFromNode("customer");
    await _getUsersFromNode("driver");
    await _getUsersFromNode("restaurant");
    await _getUsersFromNode("admin");

    setState(() {
      _isLoading = false;
    });
  }

  /// ✅ **Fetch users with `status: "approved"`**
  Future<void> _getUsersFromNode(String node) async {
    try {
      final snapshot = await _dbReference.child(node).get();
      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          if (value is Map && value["status"] == "approved") {
            approvedUsers.add({
              "id": key,
              "name": value["name"] ?? "Unknown",
              "email": value["email"] ?? "No Email",
              "role": value["role"] ?? node, // Assign node name if role is missing
              "status": value["status"] ?? "unknown",
            });
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching users from $node: $e");
    }
  }

  /// ✅ **Logout function**
  void _logout() {
    _auth.signOut();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Admin Dashboard"),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : approvedUsers.isEmpty
          ? Center(
        child: Text(
          "No approved users found",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkGray),
        ),
      )
          : ListView.builder(
        itemCount: approvedUsers.length,
        itemBuilder: (context, index) {
          var user = approvedUsers[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: primaryColor,
                child: Icon(Icons.person, color: Colors.white),
              ),
              title: Text(user["name"],style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user["email"]),
                  Text(user["role"],
                      style: TextStyle(color: Colors.black54)),
                  Text("Status: ${user["status"]}",
                      style: TextStyle(
                          color: user["status"] == "suspended" ? primaryVariant: primaryVariant, fontStyle: FontStyle.italic
                      )),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: AdminBottomNavigationMenu(currentIndex: 0), // ✅ Pass current index
    );
  }
}