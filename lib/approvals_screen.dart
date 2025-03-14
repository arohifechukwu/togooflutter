// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'admin_bottom_navigation_menu.dart';
// import 'user_model.dart';
// import 'admin_user_tile.dart';
//
// class ApprovalsScreen extends StatefulWidget {
//   @override
//   _ApprovalsScreenState createState() => _ApprovalsScreenState();
// }
//
// class _ApprovalsScreenState extends State<ApprovalsScreen> {
//   final DatabaseReference _dbReference = FirebaseDatabase.instance.ref();
//   List<UserModel> _pendingUsers = [];
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchPendingApprovals();
//   }
//
//   Future<void> _fetchPendingApprovals() async {
//     List<UserModel> userList = [];
//     await _fetchUsersFromNode("driver", userList);
//     await _fetchUsersFromNode("restaurant", userList);
//
//     setState(() {
//       _pendingUsers = userList.where((user) => user.status == "pending").toList();
//     });
//   }
//
//   Future<void> _fetchUsersFromNode(String node, List<UserModel> users) async {
//     final snapshot = await _dbReference.child(node).get();
//     if (snapshot.exists) {
//       Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
//       data.forEach((key, value) {
//         users.add(UserModel.fromRealtimeDB(key, value));
//       });
//     }
//   }
//
//   void _approveUser(UserModel user) {
//     _dbReference.child(user.role).child(user.userId).update({"status": "approved"}).then((_) {
//       setState(() {
//         _pendingUsers.remove(user);
//       });
//       Fluttertoast.showToast(msg: "${user.name} approved successfully.");
//     });
//   }
//
//   void _declineUser(UserModel user) {
//     _dbReference.child(user.role).child(user.userId).remove().then((_) {
//       setState(() {
//         _pendingUsers.remove(user);
//       });
//       Fluttertoast.showToast(msg: "${user.name} declined.");
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Pending Approvals"),
//         backgroundColor: Colors.orange,
//       ),
//       body: Column(
//         children: [
//           // No approvals text
//           if (_pendingUsers.isEmpty)
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Text(
//                 "No pending approvals.",
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//             ),
//
//           // List of pending approvals
//           if (_pendingUsers.isNotEmpty)
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _pendingUsers.length,
//                 itemBuilder: (context, index) {
//                   UserModel user = _pendingUsers[index];
//                   return AdminUserTile(
//                     user: user,
//                     onApprove: () => _approveUser(user),
//                     onDecline: () => _declineUser(user),
//                   );
//                 },
//               ),
//             ),
//         ],
//       ),
//       bottomNavigationBar: AdminBottomNavigationMenu(),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'admin_bottom_navigation_menu.dart';
import 'user_model.dart';
import 'admin_user_tile.dart';

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

  Future<void> _fetchPendingApprovals() async {
    List<UserModel> userList = [];

    await _fetchUsersFromNode("driver", userList);
    await _fetchUsersFromNode("restaurant", userList);

    setState(() {
      _pendingUsers = userList;
      _isLoading = false;
    });
  }

  Future<void> _fetchUsersFromNode(String node, List<UserModel> users) async {
    try {
      final snapshot = await _dbReference.child(node).get();

      if (snapshot.exists && snapshot.value is Map<dynamic, dynamic>) {
        Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

        data.forEach((key, value) {
          // ✅ Only add users where status is explicitly "pending"
          if (value is Map && value.containsKey("status") && value["status"] == "pending") {
            users.add(UserModel.fromRealtimeDB(key, value));
          }
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error fetching approvals: $e");
    }
  }

  void _approveUser(UserModel user) {
    // ✅ Ensure role is lowercased to avoid creating a new "Driver" node
    String userNode = user.role.toLowerCase();

    _dbReference.child(userNode).child(user.userId).update({"status": "approved"}).then((_) {
      setState(() {
        // ✅ Update only the status of the existing user
        _pendingUsers = _pendingUsers.where((u) => u.userId != user.userId).toList();
      });

      Fluttertoast.showToast(msg: "${user.name} approved successfully.");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Approval failed: $error");
    });
  }

  void _declineUser(UserModel user) {
    // ✅ Ensure role is lowercased to prevent new node creation
    String userNode = user.role.toLowerCase();

    _dbReference.child(userNode).child(user.userId).remove().then((_) {
      setState(() {
        // ✅ Remove the declined user from the pending list
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
        backgroundColor: Colors.orange,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pendingUsers.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "No pending approvals.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView.builder(
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
      bottomNavigationBar: AdminBottomNavigationMenu(),
    );
  }
}