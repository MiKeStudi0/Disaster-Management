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
    // Placeholder values for userID and username
    String userID = 'exampleUserID';
    String username = 'exampleUsername';

    // Provide your ZEGOCLOUD appID and appSign here
    int appID = 1750915985; // Replace with your actual appID
    String appSign = 'f6f24cb8c9310b182bb1779aaa50998642697171d0cbb2d8de8fefe4de1f7a5d'; // Replace with your actual appSign

    return SafeArea(
      child: ZegoUIKitPrebuiltVideoConference(
        appID: appID, // Fill in the appID
        appSign: appSign, // Fill in the appSign
        userID: userID, // Use the placeholder userID
        userName: username, // Use the placeholder username
        conferenceID: conferenceID,
        config: ZegoUIKitPrebuiltVideoConferenceConfig(),
      ),
    );
  }
}
