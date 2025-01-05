import 'package:disaster_management/disaster/screen/rescue/const.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VideoConferencePage extends StatefulWidget {
  final String conferenceID;

  const VideoConferencePage({
    super.key,
    required this.conferenceID,
  });

  @override
  _VideoConferencePageState createState() => _VideoConferencePageState();
}

class _VideoConferencePageState extends State<VideoConferencePage> {
  String? userID;
  String? username;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        setState(() {
          userID = currentUser.uid;
        });

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            username = userDoc['name'];
          });
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const int appID = appId;
    const String appsign = appSign;

    return Scaffold(
      body: SafeArea(
        child: userID != null && username != null
            ? ZegoUIKitPrebuiltVideoConference(
          appID: appID,
          appSign: appsign,
          userID: userID!,
          userName: username!,
          conferenceID: widget.conferenceID,
          config: ZegoUIKitPrebuiltVideoConferenceConfig(),
        )
            : const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
