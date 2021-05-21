import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_tracker_flutter_course/common_widgets/profile_pic.dart';
import 'package:time_tracker_flutter_course/common_widgets/show_alert_dialog.dart';
import 'package:time_tracker_flutter_course/services/auth.dart';

class AccountPage extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<AuthBase>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final logOutConfirm = await showAlertDialog(
      context,
      title: 'Logout?',
      content: 'Are you sure you want to log out?',
      actionText: 'Logout',
      cancelActionText: 'Cancel',
    );

    if (logOutConfirm == true) {
      _signOut(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthBase>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      appBar: AppBar(
        title: Text(
          'Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange,
        actions: <Widget>[
          FlatButton(
            onPressed: () => _confirmSignOut(context),
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.red,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(140),
          child: _buildProfilePic(auth.currentUser),
        ),
      ),
    );
  }

  Widget _buildProfilePic(User user) {
    return Column(
      children: <Widget>[
        ProfilePic(
          radius: 50,
          photoUrl: user.photoURL,
        ),
        SizedBox(height: 10),
        if (user.displayName != null)
          Text(
            user.displayName,
            style: TextStyle(color: Colors.black),
          ),

          Text(
            user.email,
            style: TextStyle(color: Colors.black),
          ),
        SizedBox(height: 10),
      ],
    );
  }
}
