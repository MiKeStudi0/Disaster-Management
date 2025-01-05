import 'package:disaster_management/app/ui/settings/widgets/setting_card.dart';
import 'package:disaster_management/disaster/screen/google_map/google_map.dart';
import 'package:disaster_management/disaster/screen/volunteer/volunteer_list.dart';
import 'package:disaster_management/disaster/screen/volunteer/volunteer_reg.dart';
import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class NavMapScreen extends StatefulWidget {
  const NavMapScreen({super.key});

  @override
  State<NavMapScreen> createState() => _NavMapScreenState();
}

class _NavMapScreenState extends State<NavMapScreen> {
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
              _buildSectionTitle('Navigation Routes'),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildRescueTeamList(),
              Divider(
                color: Colors.grey[400],
                thickness: 1,
                endIndent: 10,
              ),
              _buildSectionTitle('Volunteer Services'),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.person_booth_solid),
                text: 'Volunteer Registration',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const VolunteerReg()));
                },
              ),
              SettingCard(
                elevation: 4,
                icon: const Icon(LineAwesomeIcons.people_carry_solid),
                text: 'Volunteer List',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => VolunteerList()));
                },
              ),
            ],
          ),
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // Navigator.push(
      //     //   context,
      //     //   MaterialPageRoute(
      //     //     builder: (context) => ShakeLocationPage(),
      //     //   ),
      //     // );
      //   },
      //   child: const Icon(Icons.crisis_alert_sharp),
      //   backgroundColor: Colors.red,
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
      height: 350,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          _buildRescueTeamCard('Safe Location', 'Kozhikode', 'Koyilandy'),
          _buildRescueTeamCard('Rescue Camp ', 'Kozhikode', 'Ulliyeri'),
          const SizedBox(height: 10),
          _buildSectionTitle('Emergency Services'),
          Divider(
            color: Colors.grey[400],
            thickness: 1,
            endIndent: 10,
          ),
          _buildPoliceStationCard(), // Add police station block
          _buildHospitalCard(), // Add hospital block
          //_fireforcecard(), // Add fire force block
        ],
      ),
    );
  }

  Widget _buildRescueTeamCard(String teamName, String location, String area) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(),
          ),
        );
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
            const Icon(Icons.location_on,
                color: Colors.blue), // Changed color to blue
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

  Widget _buildPoliceStationCard() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.call_missed_outgoing),
      text: 'Police Station',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'police'),
          ),
        );
      },
    );
  }

  Widget _buildHospitalCard() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.plus_square),
      text: 'Hospital',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'hospital'),
          ),
        );
      },
    );
  }

  Widget _fireforcecard() {
    return SettingCard(
      elevation: 4,
      icon: const Icon(LineAwesomeIcons.fire_solid),
      text: 'Fire Force',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MapScreen(keyword: 'firestation'),
          ),
        );
      },
    );
  }
}
