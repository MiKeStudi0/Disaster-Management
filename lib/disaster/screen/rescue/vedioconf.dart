import 'package:disaster_management/disaster/screen/rescue/const.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_video_conference/zego_uikit_prebuilt_video_conference.dart';

class VideoConferencePage extends StatelessWidget {
  final String conferenceID;

  const VideoConferencePage({
    Key? key,
    required this.conferenceID,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace these with dynamic values or actual user data in a real application
    final String userID = '1234567752';
    final String username = 'Soorya';

    // ZEGOCLOUD app credentials (replace with actual appID and appSign)
    const int appID = appId;
    const String appsign = appSign;

    return Scaffold(
      body: SafeArea(
        child: ZegoUIKitPrebuiltVideoConference(
          appID: appID,
          appSign: appsign,
          userID: userID,
          userName: username,
          conferenceID: conferenceID,
          config: ZegoUIKitPrebuiltVideoConferenceConfig(),
        ),
      ),
    );
  }
}
