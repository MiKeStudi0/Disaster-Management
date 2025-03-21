
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disaster_management/app/ui/settings/widgets/setting_card.dart';
import 'package:disaster_management/disaster/screen/bar%20charts/Charts.dart';
import 'package:disaster_management/disaster/screen/google_map/location_alert.dart';
import 'package:disaster_management/disaster/screen/rescue/vedioconf.dart';
import 'package:disaster_management/disaster/screen/sos_screen/alert_shake.dart';
import 'package:disaster_management/disaster/screen/static/static_awarness.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:disaster_management/disaster/screen/groupchat/groupchat.dart';
class OngoingScreen extends StatefulWidget {
  const OngoingScreen({super.key});

  @override
  State<OngoingScreen> createState() => _OngoingScreenState();
}

class _OngoingScreenState extends State<OngoingScreen> {
  int index = 0;
  bool _isExpanded = false;
  String? userAddress;
  String? userId;
  // List of helpline numbers
  final List<Map<String, String>> _helplineNumbers = [
    {'department': 'Police'.tr, 'number': '100'},
    {'department': 'Fire Department'.tr, 'number': '101'},
    {'department': 'Ambulance'.tr, 'number': '102'},
    {'department': 'Disaster Management Services'.tr, 'number': '108'},
    {'department': 'National Emergency Number'.tr, 'number': '112'},
    {'department': 'Women Helpline'.tr, 'number': '1091'},
    {'department': 'Child Helpline'.tr, 'number': '1098'},
    {'department': 'Senior Citizen Helpline'.tr, 'number': '14567'},
    {'department': 'Tourist Helpline'.tr, 'number': '1363'},
    {'department': 'Railway Helpline'.tr, 'number': '139'},
    {'department': 'Mental Health Helpline'.tr, 'number': '9152987821'},
    {'department': 'LPG Leak Helpline'.tr, 'number': '1906'},
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locationAlertFunction();
        _getUserAddress();

  }

 Future<String?> _getUserAddress() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  return userDoc.data()?['address'];
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Rescue Teams Nearby'.tr),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildRescueTeamSection(),
              _buildSectionTitle('Helpline Numbers'.tr),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildHelplineNumbers(),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildSectionTitle('Important Information'.tr),
              _buildStaticInformation(),
              _buildResourceInformation(),
              _buildChat(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ShakeLocationPage(),
            ),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.crisis_alert_sharp),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

 

  Widget _buildHelplineNumbers() {
    // Determine how many items to display
    int displayCount = _isExpanded ? _helplineNumbers.length : 2;

    return Column(
      children: [
        ..._helplineNumbers.take(displayCount).map((entry) =>
            _buildHelplineCard(entry['department']!, entry['number']!)),
        const SizedBox(height: 8),
        TextButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Text(
            _isExpanded ? 'Show Less'.tr : 'Show More'.tr,
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildHelplineCard(String department, String number) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 5.0,
      child: ListTile(
        leading: const Icon(Icons.phone, color: Colors.redAccent),
        title: Text(
          department,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        trailing: Text(
          number,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        onTap: () => _makePhoneCall(number),
      ),
    );
  }

  Widget _buildStaticInformation() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.book_dead_solid),
      text: 'Awareness'.tr,
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const StaticdataScreen()));
      },
    );
  }
 Widget _buildResourceInformation() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.book_dead_solid),
      text: 'Donations'.tr,
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>  Charts()));
      },
    );
  }
   Widget _buildChat() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.book_dead_solid),
      text: 'Status Updates'.tr,
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) =>  GroupChatPage()));
      },
    );
  }
Widget _buildRescueTeamSection() {
  return FutureBuilder<String?>(
    future: _getUserAddress(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data == null) {
        return const Center(child: Text('Unable to fetch your address.'));
      }
      final userAddress = snapshot.data;
      return _buildRescueTeamList(userAddress);
    },
  );
}
Widget _buildRescueTeamList(String? userAddress) {
  if (userAddress == null || userAddress.isEmpty) {
    return const Center(
      child: Text(
        'Unable to determine your address. Please update your profile.',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('rescue_teams')
        .where('area', isEqualTo: userAddress) // Filter by user's address
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(
          child: Text(
            'No rescue teams found in your area.',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      final rescueTeams = snapshot.data!.docs;

      return ListView.builder(
        shrinkWrap: true, // Ensures it fits inside the scrollable column
        physics: const NeverScrollableScrollPhysics(), // Avoid nested scroll issues
        itemCount: rescueTeams.length,
        itemBuilder: (context, index) {
          final team = rescueTeams[index].data() as Map<String, dynamic>;

          final teamName = team['name'] ?? 'Unknown Team';
          final location = team['location'] ?? 'Unknown Location';
          final area = team['area'] ?? 'Unknown Area';

          return _buildRescueTeamCard(teamName, location, area);
        },
      );
    },
  );
}

Widget _buildRescueTeamCard(String teamName, String location, String area) {
  return GestureDetector(
    onTap: () {
      _showCodeInputDialog(context, index);
      setState(() {
        index += 1;
      });
    },
    child: Card(
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  teamName,
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(location,
                        style: const TextStyle(fontSize: 14.0, color: Colors.white)),
                    const SizedBox(width: 8),
                    const Icon(Icons.track_changes_outlined, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(area,
                        style: const TextStyle(fontSize: 14.0, color: Colors.white)),
                  ],
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
          ],
        ),
      ),
    ),
  );
}


  Future<void> _makePhoneCall(String number) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: number);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch dialer')),
      );
    }
  }

  Future<void> _showCodeInputDialog(BuildContext context, int index) async {
    String enteredCode = '';
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Code to verify'),
          content: TextField(
            obscureText: true,
            decoration: const InputDecoration(hintText: 'Enter code'),
            onChanged: (value) {
              enteredCode = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _codeConfirm(enteredCode, context, index);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _codeConfirm(String enteredCode, BuildContext context, int index) {
    if (enteredCode == '1234') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const VideoConferencePage(conferenceID: '12345'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect code')),
      );
    }
  }
}
