import 'dart:ui';
import 'package:disaster_management/disaster/screen/google_map/google_map.dart';
import 'package:disaster_management/disaster/screen/rescue/vedioconf.dart';
import 'package:disaster_management/disaster/screen/sos_screen/alert_sos.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
                         
        
           
          
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MapScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('Navigation Map'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShakeLocationPage(),
            ),
          );
        },
        child: const Icon(Icons.crisis_alert_sharp),
        backgroundColor: Colors.red,
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
      height: 400,
      child: ListView(
        scrollDirection: Axis.vertical,
        children: [
          _buildRescueTeamCard('Safe Location', 'Kozhikode', 'Koyilandy'),
          const SizedBox(height: 8),
          _buildRescueTeamCard('Rescue Camp ', 'Kozhikode', 'Ulliyeri'),
          const SizedBox(height: 8),
               _buildPoliceStationCard(), // Add police station block
        const SizedBox(height: 8),
        _buildHospitalCard(), // Add hospital block
        const SizedBox(height: 8),
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
                        builder: (context) => MapScreen(),
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
          const Icon(Icons.location_on, color: Colors.blue), // Changed color to blue
          const SizedBox(width: 4),
          Text(location, style: const TextStyle(fontSize: 14.0, color: Colors.white)),
          const SizedBox(width: 8),
          const Icon(Icons.track_changes_outlined, color: Colors.grey),
          const SizedBox(width: 4),
          Text(area, style: const TextStyle(fontSize: 14.0, color: Colors.white)),
        ],
      ),
    ],
  );
}



Widget _buildPoliceStationCard() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(keyword: 'police'),
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
            Text(
              'Police Stations Near Me',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
          ],
        ),
      ),
    ),
  );
}

Widget _buildHospitalCard() {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(keyword: 'hospital'),
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
            Text(
              'Hospital Near Me',
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.redAccent),
          ],
        ),
      ),
    ),
  );
}

}
