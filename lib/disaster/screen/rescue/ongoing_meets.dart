import 'package:disaster_management/app/ui/settings/widgets/setting_card.dart';
import 'package:disaster_management/disaster/screen/google_map/google_map.dart';
import 'package:disaster_management/disaster/screen/rescue/vedioconf.dart';
import 'package:disaster_management/disaster/screen/sos_screen/alert_shake.dart';
import 'package:disaster_management/disaster/screen/static/static_awarness.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class OngoingScreen extends StatefulWidget {
  const OngoingScreen({super.key});

  @override
  State<OngoingScreen> createState() => _OngoingScreenState();
}

class _OngoingScreenState extends State<OngoingScreen> {
  int index = 0;
  bool _isExpanded = false;

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
              _buildRescueTeamList(),
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
              const SizedBox(height: 24),
              // Center(
              //   child: ElevatedButton.icon(
              //     onPressed: () {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => const MapScreen(),
              //         ),
              //       );
              //     },
              //     icon: const Icon(Icons.map),
              //     label: const Text('Navigation Map'),
              //     style: ElevatedButton.styleFrom(
              //       foregroundColor: Colors.redAccent,
              //       padding: const EdgeInsets.symmetric(
              //           horizontal: 24.0, vertical: 12.0),
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20.0),
              //       ),
              //     ),
              //   ),
              // ),
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

  Widget _buildRescueTeamList() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          _buildRescueTeamCard('Rescue Team S1'.tr, 'Kozhikode', 'Koyilandy'),
          const SizedBox(height: 8),
          _buildRescueTeamCard('Rescue Team S2'.tr, 'Kozhikode', 'Ulliyeri'),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildHelplineNumbers() {
    // Determine how many items to display
    int displayCount = _isExpanded ? _helplineNumbers.length : 3;

    return Column(
      children: [
        ..._helplineNumbers
            .take(displayCount)
            .map((entry) =>
                _buildHelplineCard(entry['department']!, entry['number']!))
            ,
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
              _buildTeamInfo(teamName, location, area),
              const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String teamName, String location, String area) {
    return Column(
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
          builder: (context) => const VideoConferencePage(conferenceID: '12345'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect code')),
      );
    }
  }
}
